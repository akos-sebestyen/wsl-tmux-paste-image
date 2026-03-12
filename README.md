# wsl-tmux-paste-image

Paste Windows clipboard images into tmux panes. Built for WSL.

Uses PowerShell to grab the image from the Windows clipboard, saves it to `~/.cache/tmux-paste-image/`, and either:

- **Claude Code detected**: sends `/image <path>` automatically
- **Otherwise**: pastes the file path into the pane

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/akos-sebestyen/wsl-tmux-paste-image/main/install.sh | bash
```

## Usage

Press `prefix + v` in any tmux pane to paste a clipboard image.

## Requirements

- WSL (Windows Subsystem for Linux)
- tmux
- PowerShell (available by default in WSL via `powershell.exe`)
