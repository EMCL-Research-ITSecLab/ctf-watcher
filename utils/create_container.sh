#!/bin/bash
NUMBER_OF_CONTAINERS=$1

for i in $(seq 1 $NUMBER_OF_CONTAINERS); do
  container_name="my-engine_$i"
  docker run \
    --name "$container_name" \
    -e ENV_CONTAINER_NAME="$container_name" \
    --mount type=bind,source=/var/log/commands.log,target=/var/log/commands.log \
    --mount type=bind,source=~/command_logs/cl_1.log,target=/wazuh-agent/commands.log \
    -d nginx
done
