#!/bin/bash

set -e

REPO="akos-sebestyen/wsl-tmux-paste-image"
BRANCH="main"
RAW_URL="https://raw.githubusercontent.com/$REPO/$BRANCH"
INSTALL_DIR="$HOME/.local/bin"
SCRIPT_NAME="tmux-paste-image.sh"
TMUX_CONF="$HOME/.tmux.conf"
BIND_LINE="bind-key v run-shell 'bash $INSTALL_DIR/$SCRIPT_NAME'"

echo "Installing wsl-tmux-paste-image..."

# Download script to ~/.local/bin
mkdir -p "$INSTALL_DIR"
curl -fsSL "$RAW_URL/$SCRIPT_NAME" -o "$INSTALL_DIR/$SCRIPT_NAME"
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
echo "  Installed $INSTALL_DIR/$SCRIPT_NAME"

# Add tmux binding if not already present
if [ ! -f "$TMUX_CONF" ]; then
    echo "# Paste image from clipboard (prefix + v)" | tee -a "$TMUX_CONF" > /dev/null
    echo "$BIND_LINE" | tee -a "$TMUX_CONF" > /dev/null
    echo "  Created $TMUX_CONF with paste-image binding"
elif grep -qF "tmux-paste-image" "$TMUX_CONF"; then
    echo "  Binding already exists in $TMUX_CONF (skipped)"
else
    echo "" | tee -a "$TMUX_CONF" > /dev/null
    echo "# Paste image from clipboard (prefix + v)" | tee -a "$TMUX_CONF" > /dev/null
    echo "$BIND_LINE" | tee -a "$TMUX_CONF" > /dev/null
    echo "  Added paste-image binding to $TMUX_CONF"
fi

# Reload tmux config if tmux is running
if tmux info &>/dev/null; then
    tmux source-file "$TMUX_CONF"
    echo "  Reloaded tmux config"
fi

echo "Done! Use prefix + v to paste clipboard images."
