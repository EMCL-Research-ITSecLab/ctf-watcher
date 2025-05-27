#!/bin/bash

function print_info()
{
echo ""
echo -e "\e[34m[Info]:\e[0m $1"
echo ""
}

print_info "Create /wazuh-agent directory in containers [1/4]"

docker ps -q | xargs -I {} docker exec -i {} mkdir wazuh-agent


print_info "Copy set up scripts into containers [2/4]"

docker ps -q | xargs -I {} docker cp config/container_requirements_set_up.sh {}:/wazuh-agent/
docker ps -q | xargs -I {} docker cp config/bash_loggin_set_up.sh {}:/wazuh-agent/

print_info "Install requirements on containers [3/4]"

docker ps -q | xargs -I {} docker exec -i {} sh -c "/wazuh-agent/container_requirements_set_up.sh"


print_info "Set up bash logging in containers [4/4]"

docker ps -q | xargs -I {} docker exec -i {} sh -c "/wazuh-agent/bash_loggin_set_up.sh --privat_log=/wazuh-agent/commands.log"
