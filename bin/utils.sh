#!/usr/bin/env bash

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

  # Define the metric data to be sent to the Pushgateway
  # In this case, we're pushing a simple counter metric with a value of 1
    # Check if the NETWORK environment variable is set and construct metric data accordingly
  if [ -z "$NETWORK" ]; then
    # No network label if the NETWORK variable is not set
    METRIC_DATA="$METRIC_NAME 1"
  else
    # Add the network label if NETWORK is set
    METRIC_DATA="$METRIC_NAME{network=\"$NETWORK\"} 1"
  fi

  # Use the curl command to push the metric to the Pushgateway
  # The --data-binary flag sends the metric data as a POST request
  cat <<EOF | curl --data-binary @- "$PUSHGATEWAY_URL/metrics/job/cardanow"
# TYPE $METRIC_NAME counter
$METRIC_DATA
EOF
}
