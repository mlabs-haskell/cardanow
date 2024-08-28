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

## Prometheus

### Local Pushgateway Setup

To test the metrics while running the application locally, you can use the official Pushgateway Docker image.

#### Steps:

1. Pull the Pushgateway Docker image:
   ```bash
   docker pull prom/pushgateway
   ```

2. Run the Pushgateway container:
   ```bash
   docker run -d -p 9091:9091 prom/pushgateway
   ```

3. Navigate to the following URL to view the metrics:
   - [http://localhost:9091/metrics](http://localhost:9091/metrics)

This setup allows you to verify that your metrics are being pushed to the Pushgateway.
