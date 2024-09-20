# Cardanow Monitoring System

## Grafana
Grafana is used as the visualization layer for our monitoring stack. We configure various data sources to visualize machine usage and service performance. The following components are integrated into Grafana:

We are using the following data sources:
- **Loki** (for log aggregation)
- **Tempo** (for distributed tracing)
- **Pushgateway** (for custom metrics collection)

### Grafana Loki
**Loki** is a log aggregation system designed for efficiently collecting, storing, and querying logs. We are using Loki to collect **systemd logs**, which include logs from our applications.

No special setup is needed to verify logs locally. If your application outputs logs to the console, they will be automatically collected and displayed in Grafana once the application is deployed to the cloud.

### Grafana Tempo
**Tempo** is a distributed tracing backend designed to handle high volumes of traces. It supports the **OpenTelemetry (OTEL)** standard, meaning it can receive trace data from any OpenTelemetry-compatible collector or client.

#### Local Tracing with Jaeger
To test that traces are being correctly sent from your local application to Grafana Tempo, you can use **Jaeger** as a tracing tool. Follow these steps:

##### Steps:

1. **Run Jaeger locally** using the all-in-one Docker image:
   ```bash
   docker run -d --name jaeger \
     -e COLLECTOR_ZIPKIN_HTTP_PORT=9411 \
     -p 5775:5775/udp \
     -p 6831:6831/udp \
     -p 6832:6832/udp \
     -p 5778:5778 \
     -p 16686:16686 \
     -p 14268:14268 \
     -p 14250:14250 \
     -p 9411:9411 \
     jaegertracing/all-in-one:latest
   ```

2. **Run your application locally**. Ensure that tracing is enabled in your application by configuring it to send traces to the OpenTelemetry-compatible Jaeger instance running on your machine.

3. **Verify that traces are being sent**:
   - Open Jaeger’s UI in your browser at `http://localhost:16686`.
   - Search for your application’s traces and confirm that they are being correctly reported.

### Grafana Pushgateway
**Pushgateway** allows ephemeral and batch jobs to push their metrics to Prometheus. We use Pushgateway to push metrics related to service startups and other custom events that can help trigger alerts.

#### Local Pushgateway Setup
To test your application's metrics locally, you can use the official **Pushgateway** Docker image to push custom metrics from your application.

##### Steps:

1. **Run Pushgateway locally**:
   ```bash
   docker run -d -p 9094:9091 prom/pushgateway
   ```

2. **Run your application locally**. Ensure your application is configured to push metrics to `http://localhost:9091` (the Pushgateway endpoint).

3. **Verify that metrics are being pushed**:
   - Navigate to `http://localhost:9094/metrics` in your browser to see the metrics being pushed by your application.
   
4. **Check custom metrics**:
   - You can manually push a metric for testing purposes using the following `curl` command:
     ```bash
     echo "custom_metric_name 1" | curl --data-binary @- http://localhost:9091/metrics/job/test_job
     ```

---

## Manual monitoring

A rudimentary monitoring system implemented using tmux and systemd unit on a Linux system was implemented to give a rapid overview of the system while connected to it in ssh

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

