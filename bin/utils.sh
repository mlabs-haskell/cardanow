#!/usr/bin/env bash


# The 'trace' function to trace a command with OpenTelemetry spans using otel-cli
trace() {
    # Capture the component name, command, and its arguments
    local component_name="$1"
    local cmd="$2"
    shift 2
    local args=("$@")

    # Generate a unique Span ID for the root span
    local span_id
    span_id=$(openssl rand -hex 8) # 8 bytes (16 characters) for Span ID

    # Check for required environment variables
    if [[ -z "${OTEL_CLI_FORCE_TRACE_ID-}" && -z "${OTEL_CLI_FORCE_PARENT_SPAN_ID-}" ]]; then
        # Both variables are not set, we are creating a root span
        OTEL_CLI_FORCE_TRACE_ID=$(openssl rand -hex 16) # 16 bytes (32 characters) for Trace ID
        export OTEL_CLI_FORCE_TRACE_ID
        echo "Generated Trace ID: $OTEL_CLI_FORCE_TRACE_ID"

        # Use the same Span ID for the root span
        local parent_span_id="0000000000000000" # Root span has no parent
        export OTEL_CLI_FORCE_PARENT_SPAN_ID="$span_id" # Export for child spans
        echo "Exported Root Span ID: $OTEL_CLI_FORCE_PARENT_SPAN_ID"

    elif [[ -n "${OTEL_CLI_FORCE_TRACE_ID-}" && -n "${OTEL_CLI_FORCE_PARENT_SPAN_ID-}" ]]; then
        # Both variables are set, use them
        local parent_span_id="$OTEL_CLI_FORCE_PARENT_SPAN_ID"
        echo "Using Provided Trace ID: $OTEL_CLI_FORCE_TRACE_ID"
        echo "Using Provided Parent Span ID: $parent_span_id"
    else
        # If one of them is set and the other is not, fail
        echo "Error: Both OTEL_CLI_FORCE_TRACE_ID and OTEL_CLI_FORCE_PARENT_SPAN_ID must be set together or not at all."
        return 1
    fi

    # Create the traceparent header
    local traceparent
    traceparent="00-${OTEL_CLI_FORCE_TRACE_ID}-${parent_span_id}-00"
    echo "Traceparent Header: $traceparent"

    # Get the current timestamp in Unix epoch format with nanoseconds
    local start
    start=$(date +%s%N) # Unix epoch time in nanoseconds
    echo "Start Timestamp (ns): $start"

    # Run the actual command and capture its exit status
    "$cmd" "${args[@]}"
    local cmd_status=$?

    local status_code
    status_code=$([ $cmd_status -eq 0 ] && echo "ok" || echo "error")

    # Get the end timestamp in Unix epoch format with nanoseconds
    local end
    end=$(date +%s%N) # Unix epoch time in nanoseconds
    echo "End Timestamp (ns): $end"

    # Convert timestamps to ISO 8601 format with milliseconds
    local start_iso
    local end_iso
    start_iso=$(date -d @$((start / 1000000000)) -u +'%Y-%m-%dT%H:%M:%S.%3NZ')
    end_iso=$(date -d @$((end / 1000000000)) -u +'%Y-%m-%dT%H:%M:%S.%3NZ')
    echo "Start Timestamp (ISO 8601): $start_iso"
    echo "End Timestamp (ISO 8601): $end_iso"

    if [[ "$parent_span_id" == "0000000000000000" ]]; then
        # If it's a root span (no parent), unset OTEL_CLI_FORCE_PARENT_SPAN_ID
        unset OTEL_CLI_FORCE_PARENT_SPAN_ID
        echo "Unset OTEL_CLI_FORCE_PARENT_SPAN_ID since this is a root span"
    fi

    # Send the span to OpenTelemetry collector using otel-cli
    attrs="network=none"
    if [[ -n "${NETWORK-}" ]]; then
        attrs="network=$NETWORK"
    fi

    OTEL_CLI_FORCE_SPAN_ID=$span_id TRACEPARENT="$traceparent" otel-cli span \
        -n "$component_name" \
        -s "cardanow" \
        --start "$start_iso" \
        --end "$end_iso" \
        --status-code "$status_code" \
        --attrs "$attrs"

    # Return the command's exit status to the caller
    return $cmd_status
}

# This function pushes a counter metric to a Prometheus Pushgateway.
# The metric name will be prepended with 'cardanow' followed by the 
# metric name provided as an argument.
push_metric_to_prometheus() {
  
  # Check if the user provided a metric name as an argument
  if [ -z "$1" ]; then
    echo "Error: Metric name required"
    return 1  # Exit the function with an error code if no metric name is provided
  fi

  METRIC_NAME="cardanow_$1"

  # Get the current timestamp in seconds since the epoch
  TIMESTAMP=$(date +%s)

  # Define the metric data to be sent to the Pushgateway
  # Check if the NETWORK environment variable is set and construct metric data accordingly
  if [ -z "${NETWORK:-}" ]; then
    # No network label if the NETWORK variable is not set
    METRIC_DATA="$METRIC_NAME $TIMESTAMP"
  else
    # Add the network and timestamp labels if NETWORK is set
    METRIC_DATA="${METRIC_NAME}_${NETWORK} $TIMESTAMP"
  fi

  # Use the curl command to push the metric to the Pushgateway
  # The --data-binary flag sends the metric data as a POST request

  cat <<EOF | curl --data-binary @- "$PUSHGATEWAY_URL/metrics/job/cardanow" || true
# TYPE $METRIC_NAME counter
$METRIC_DATA
EOF
}
