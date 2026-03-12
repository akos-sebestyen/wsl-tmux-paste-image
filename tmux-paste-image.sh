#!/bin/bash

# Paste clipboard image into tmux pane.
# WSL version: uses PowerShell to grab the Windows clipboard image.

SCREENSHOT_DIR="${1:-$HOME/.cache/tmux-paste-image}"
mkdir -p "$SCREENSHOT_DIR"

FILENAME="image_$(date +%Y-%m-%d_%H-%M-%S)_$$.png"
FILE_PATH="$SCREENSHOT_DIR/$FILENAME"

# Use PowerShell to save Windows clipboard image to a temp Windows path,
# then copy it to the WSL filesystem.
WIN_TEMP=$(powershell.exe -NoProfile -Command '[System.IO.Path]::GetTempPath()' 2>/dev/null | tr -d '\r')
WIN_FILE="${WIN_TEMP}${FILENAME}"

RESULT=$(powershell.exe -NoProfile -Command "
Add-Type -AssemblyName System.Windows.Forms
\$img = [System.Windows.Forms.Clipboard]::GetImage()
if (\$img -ne \$null) {
    \$img.Save('${WIN_FILE}', [System.Drawing.Imaging.ImageFormat]::Png)
    \$img.Dispose()
    Write-Output 'OK'
} else {
    Write-Output 'NOIMAGE'
}
" 2>/dev/null | tr -d '\r')

if [ "$RESULT" != "OK" ]; then
    tmux display-message -d 2000 "[paste-image] No image in clipboard."
    exit 0
fi

# Convert Windows temp path to WSL path and copy
WIN_PATH_WSL=$(wslpath -u "$WIN_FILE" 2>/dev/null || echo "/mnt/c/$(echo "$WIN_FILE" | sed 's|C:\\|/|;s|\\|/|g')")
cp "$WIN_PATH_WSL" "$FILE_PATH" 2>/dev/null

# Clean up Windows temp file
powershell.exe -NoProfile -Command "Remove-Item -Path '${WIN_FILE}' -ErrorAction SilentlyContinue" &>/dev/null &

if [ ! -s "$FILE_PATH" ]; then
    tmux display-message -d 2000 "[paste-image] Failed to save image."
    exit 1
fi

# Detect if current pane is running Claude Code
PANE_CONTENT=$(tmux capture-pane -p | tail -5)

if echo "$PANE_CONTENT" | grep -qE "^(›|>) |claude[ ->]"; then
    tmux send-keys "/image \"$FILE_PATH\"" Enter
    tmux display-message -d 2000 "[paste-image] Image sent to Claude: $FILENAME"
else
    tmux send-keys "\"$FILE_PATH\""
    tmux display-message -d 2000 "[paste-image] Path pasted: $FILE_PATH"
fi
