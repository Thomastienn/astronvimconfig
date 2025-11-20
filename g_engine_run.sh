#!/usr/bin/env bash
# g_engine_run.sh - open file in kitty running nvim

# use full paths to avoid PATH issues when Godot runs it from desktop
KITTY=/home/thomas/.local/kitty.app/bin/kitty
NVIM=/home/linuxbrew/.linuxbrew/bin/nvim
FILE="$1"

# $1 is the file path passed by Godot
"$KITTY" -- "$NVIM" --server /tmp/godot.pipe --remote "$FILE"
