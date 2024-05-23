# Cardanow Monitoring System

## Introduction

This document outlines the setup and usage of the Cardanow Monitoring System, a rudimentary monitoring system implemented using tmux and systemd unit on a Linux system.

## Components

### Nix Package: start-cardanow-monitoring-tmux

The monitoring system is packaged as a Nix package called `start-cardanow-monitoring-tmux`. This package includes a Bash script that starts a tmux session with predefined windows for monitoring Cardanow services.

To run the monitoring system using Nix, execute the following command:

nix run .#start-cardanow-monitoring-tmux

### Systemd Unit

A systemd unit is configured to start the monitoring system as a one-shot service. When activated, the systemd unit executes the Nix command to start the tmux session.

## Interacting with the Tmux Window

Once the tmux session is started, you can interact with it using various tmux commands. Here are some common interactions:

### Attaching to the Tmux Session

To attach to the tmux session and interact with the monitoring windows, use the following command:

```bash
tmux attach-session -t cardanow_monitoring
```

### Detaching from the Tmux Session

To detach from the tmux session without closing it, press `Ctrl + b` followed by `d`.

### Killing the Tmux Session

To kill the tmux session and close all monitoring windows, execute the following command:

```bash
tmux kill-session -t cardanow_monitoring
```

## Notes

- This monitoring system is partial and rudimentary, providing basic monitoring of cardanow services via journalctl and a system resource monitor (btop).
- Additional monitoring features and enhancements will be added based on specific requirements and use cases in the future.
