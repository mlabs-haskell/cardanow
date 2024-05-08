#!/usr/bin/env bash

echo "Starting tmux session"
echo "Run 'tmux attach-session -t cardanow_monitoring' to enter it"

# Start a new tmux session named "cardanow_monitoring"
tmux new-session -d -s cardanow_monitoring

# Split the window vertically and run journalctl commands in each pane
tmux send-keys -t cardanow_monitoring:0.0 'journalctl -f -u cardanow-mainnet.service' C-m
tmux split-window -v -t cardanow_monitoring
tmux send-keys -t cardanow_monitoring:0.1 'journalctl -f -u cardanow-preprod.service' C-m
tmux split-window -v -t cardanow_monitoring
tmux send-keys -t cardanow_monitoring:0.2 'journalctl -f -u cardanow-preview.service' C-m
tmux split-window -v -t cardanow_monitoring
tmux send-keys -t cardanow_monitoring:0.3 'journalctl -f -u cardanow-cleanup-local-data' C-m

# Select the first window
tmux select-pane -t cardanow_monitoring:0.0

# Create a new window and run btop
tmux new-window -t cardanow_monitoring:1 -n 'btop'
tmux send-keys -t cardanow_monitoring:1 'btop' C-m
