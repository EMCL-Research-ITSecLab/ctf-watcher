#!/bin/bash

docker ps -q | xarg -I {} docker cp config/bash_loggin_set_up.sh {}:/wazuh-agent
docker ps -q | xarg -I {} docker cp config/bash_loggin_set_up.sh {}:/wazuh-agent

docker ps -q | xargs -I {} docker exec -i {} sh -c "/container_requirements_set_up.sh"
docker ps -q | xargs -I {} docker exec -i {} sh -c "/wazuh-agent/bash_loggin_set_up.sh"
