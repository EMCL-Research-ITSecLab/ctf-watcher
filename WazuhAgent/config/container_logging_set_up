#!/bin/bash

docker ps -q | xargs -I {} docker exec -w /wazuh-agent -i {} bash < config/container_requirements_set_up.sh
docker ps -q | xargs -I {} docker exec -w /wazuh-agent -i {} bash < config/bash_loggin_set_up.sh
