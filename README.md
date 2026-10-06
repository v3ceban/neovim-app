# NeoVim.app

A tiny macOS app that opens files and folders in Neovim inside a tmux session (`main`) in iTerm2. Use it with Finder's "Open With", drag-and-drop, or as the default app for a file type.

- If the `main` session is already running, the file opens in a new tmux window.
- If not, the app launches iTerm and opens the file once iTerm's shell has created the session.

## Requirements

- iTerm2
- `tmux` and `nvim` from Homebrew on Apple silicon (`/opt/homebrew/bin`)
- A shell that auto-attaches to the `main` session, e.g. in `~/.zshrc`:

  ```zsh
  if [[ -z $TMUX && $- == *i* ]] && command -v tmux > /dev/null; then
    exec tmux new -A -s main
  fi
  ```

## Install

```sh
./install.sh
```

This builds the app from `NeoVim.applescript` and installs it to `/Applications/NeoVim.app`. To install somewhere else, set `DEST`, e.g. `DEST=~/Applications ./install.sh`. Run the same command again after editing the script.

The first time you open a file, macOS asks for permission to control iTerm. Allow it.

To change the icon, replace `icon.icns` and run `./install.sh` again.

## Credits

The app icon is the [Neovim logo](https://neovim.io) by Jason Long, licensed under [CC BY 3.0](https://creativecommons.org/licenses/by/3.0/).
