# Utility Tools

## Clean Docker
```
./sudo clean_docker.sh
```
Executing this script will:
-  Stop and remove all active and inactive containers
-  Prune all Volumes
-  Delete all Images

## Install Docker
```
./install_docker.sh
```
Executing this script will:
- Install Docker
- Add a Docker group
- Add the active user to this group

If Docker is already installed, it will only create the group and add the user

## Create Container
```
./create_container <#Container>
```
Executing this script will:
- Creates `#Container` nginx containers
- With Environment Variable `ENV_CONTAINER_NAME=my_engine_#`
- With Bind `/var/log/commands.log:/var/log/commands.log`
- With Bind ` ~/command_logs/cl_#.log:/wazuh-agent/commands.log` 

## Pull Dashboard (Deprecated)
```
./pull_dashboard.sh
```
Executing this script will:
- Ask for a Grafana Dashboard ID
- Pull this Dashboard from Grafana via the API
- Write the Dashboard inside the `new_dashboard.json` file

 
