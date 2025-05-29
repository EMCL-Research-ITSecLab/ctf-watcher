#!/bin/bash

function print_info()
{
echo ""
echo -e "\e[34m[Info]:\e[0m  $SET_UP_STEP_MAIN: $SET_UP_STEP_SUB:\e[2m $1"
echo ""
}

print_info "Create /wazuh-agent directory in containers...  1/4"

docker ps -q | xargs -I {} docker exec -i {} mkdir wazuh-agent


print_info "Copy set up scripts into containers...  2/4"

docker ps -q | xargs -I {} docker cp config/container_requirements_set_up.sh {}:/wazuh-agent/
docker ps -q | xargs -I {} docker cp config/bash_loggin_set_up.sh {}:/wazuh-agent/

print_info "Install requirements on containers...  3/4"

for container_id in $(docker ps -q); do
  docker exec "$container_id" sh -c "/wazuh-agent/container_requirements_set_up.sh" &
  pids+=($!)
done
for pid in "${pids[@]}"; do
  wait "$pid"
done

print_info "Set up bash logging in containers...  4/4"

docker ps -q | xargs -I {} docker exec -i {} sh -c "/wazuh-agent/bash_loggin_set_up.sh --privat_log=/wazuh-agent/commands.log"
