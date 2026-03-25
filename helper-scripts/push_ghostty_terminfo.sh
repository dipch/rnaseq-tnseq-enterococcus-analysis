#!/bin/zsh

# When using Ghostty terminal in local machine, if remote machine connected via ssh that don't have Ghostty's terminfo entry, using Nano/Vim produces following error: "Error opening terminal: xterm-ghostty"
# This script pushes the Ghostty terminal terminfo profile to the remote server.

# Replace uppmax-pelle with user@hostname 
echo "Sending Ghostty terminfo..."
# Extract Ghostty terminfo and pipe it to the server
infocmp -x xterm-ghostty | ssh uppmax-pelle -- tic -x -

if [ $? -eq 0 ]; then
    echo "Success"
else
    echo "Failed"
    exit 1
fi