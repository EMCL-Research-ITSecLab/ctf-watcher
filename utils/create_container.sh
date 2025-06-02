#!/bin/bash
NUMBER_OF_CONTAINERS=$1

for i in $(seq 1 $NUMBER_OF_CONTAINERS); do
  CONTAINER_NAME="my-engine_$i"
  mkdir -p command_logs
  touch "command_logs/cl_$CONTAINER_NAME"
  ABSOLUTE_PATH="$(realpath command_logs/cl_$CONTAINER_NAME)"
  docker run \
    --name "$CONTAINER_NAME" \
    -e ENV_CONTAINER_NAME="$CONTAINER_NAME" \
    --mount type=bind,source=/var/log/commands.log,target=/var/log/commands.log \
    --mount type=bind,source="$ABSOLUTE_PATH",target=/wazuh-agent/commands.log \
    -d nginx
done
