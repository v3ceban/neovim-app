-- Double-clicked: open nvim in the home folder
on run
    openInNvim({})
end run

-- "Open With" / dropped files and folders
on open droppedItems
    openInNvim(droppedItems)
end open

on openInNvim(input)
    set tmuxBin to "/opt/homebrew/bin/tmux"
    set nvimBin to "/opt/homebrew/bin/nvim"
    set filepaths to ""
    set dirpath to quoted form of POSIX path of (path to home folder)
    set dirSet to false

    repeat with f in input
        set posixPath to POSIX path of f
        set isDir to do shell script "/bin/test -d " & quoted form of posixPath & " && echo yes || echo no"
        if isDir is "yes" then
            set dirpath to quoted form of posixPath
            set dirSet to true
        else
            do shell script "/usr/bin/xattr -cr " & quoted form of posixPath
            set filepaths to filepaths & " " & quoted form of posixPath
            if not dirSet then
                set parentDir to do shell script "/usr/bin/dirname " & quoted form of posixPath
                set dirpath to quoted form of parentDir
                set dirSet to true
            end if
        end if
    end repeat

    if filepaths is "" then
        set nvimCmd to nvimBin & " ."
    else
        set nvimCmd to nvimBin & filepaths
    end if

    set sessionExisted to my hasSession(tmuxBin)

    -- Make sure an iTerm window exists; its zsh runs `tmux new -A -s main`,
    -- so the tmux server is always born from iTerm, never from this applet.
    if application "iTerm" is running then
        tell application "iTerm"
            if (count of windows) = 0 then create window with default profile
        end tell
    else
        tell application "iTerm" to activate -- launches and opens its startup window
    end if

    if not my waitForSession(tmuxBin, 5) then
        tell application "iTerm" to create window with default profile
        if not my waitForSession(tmuxBin, 5) then
            display alert "NeoVim" message "tmux session 'main' did not start."
            return
        end if
    end if

    -- a session iTerm just created only holds a throwaway zsh window; drop it once nvim is up
    if not sessionExisted then
        set shellWindow to do shell script tmuxBin & " display-message -p -t main: '#{window_id}'"
    end if

    -- new window in the existing session; tmux switches to it automatically
    do shell script tmuxBin & " new-window -t main: -c " & dirpath & " " & quoted form of nvimCmd

    if not sessionExisted then
        do shell script tmuxBin & " kill-window -t " & quoted form of shellWindow
    end if

    tell application "iTerm" to activate
end openInNvim

on hasSession(tmuxBin)
    return (do shell script tmuxBin & " has-session -t main 2>/dev/null && echo yes || echo no") is "yes"
end hasSession

on waitForSession(tmuxBin, timeoutSecs)
    repeat (timeoutSecs * 10) times
        if my hasSession(tmuxBin) then return true
        delay 0.1
    end repeat
    return false
end waitForSession
