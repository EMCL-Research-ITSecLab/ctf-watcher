#!/bin/bash

function print_info()
{
echo ""
echo -e "\e[34m[Info]:\e[0m  $SET_UP_STEP_MAIN | $SET_UP_STEP_SUB | $1"
echo ""
}

print_info "[1/4] Create /wazuh-agent directory in containers"

docker ps -q | xargs -I {} docker exec -i {} mkdir wazuh-agent


print_info "[2/4] Copy set up scripts into containers"

docker ps -q | xargs -I {} docker cp config/container_requirements_set_up.sh {}:/wazuh-agent/
docker ps -q | xargs -I {} docker cp config/bash_loggin_set_up.sh {}:/wazuh-agent/

print_info "[3/4] Install requirements on containers"

for container_id in $(docker ps -q); do
  docker exec "$container_id" sh -c "/wazuh-agent/container_requirements_set_up.sh" &
  pids+=($!)
done
for pid in "${pids[@]}"; do
  wait "$pid"
done

print_info "[4/4] Set up bash logging in containers"

docker ps -q | xargs -I {} docker exec -i {} sh -c "/wazuh-agent/bash_loggin_set_up.sh --privat_log=/wazuh-agent/commands.log"
