# Manual Wazuh Agent Set Up
You can manually set up a Wazuh Agent or install it on a different machine by running 
```
set_up_agent.sh
```

If the Wazuh Manager is on a different address, you need to provide it
```
set_up_agent.sh --manager=<manager_ip_address>
```

The name of the Wazuh Agent can be set with
```
set_up_agent.sh --name=<name>
```
but must be unique.

Some logging features can be disabled 
```
set_up_agent.sh \
--use_system_health=false \
--use_bash_log=false \
--use_heidpi=false \
--use_ufw=false \
--use_container_logging=false
```
These can also be manually set up after the Agent is installed by running their corresponding script
```
sudo ./config/bash_loggin_set_up.sh --privat_log=<path_to_private_log>
sudo ./config/heiDPI_set_up.sh
sudo ./config/ufw_set_up.sh
sudo ./config/container_logging_set_up.sh
```
Bash logging can also write its logs into a private log file, in addition to `/var/log/commands.log`.
This is used in container logging where each container writes its bash logs into a global and a local file.

## Logging Containers from the host
Container logging allows the Agent to supervise users inside containers.

After the setup, the container will write its bash logs into `/var/log/commands.log` and `wazuh-agent/commands.log`.
The  `/var/log/commands.log` file is the log for all containers and is read by the Wazuh Agent.
The `wazuh-agent/commands.log` file only logs the container's own bash commands and is intended for further custom analysis.
They need to be bound to the host to be read by the agent and to be locally accessible.
```
docker run -d \
  -v /var/log/commands.log:/var/log/commands.log \
  -v <path_to_private_log>:wazuh-agent/commands.log \
   <image_name>
```

By default, the Agent logs the container's name as its ID. If you want to log its given name, provide it to the container as the environment variable `ENV_CONTAINER_NAME`.

```
docker run --name <container_name> -e ENV_CONTAINER_NAME="<container_name>" -d <image_name>
```



## Set Up Inside Docker Container 
The Agent can also be set up inside a Docker container.
```
set_up_agent.sh --manager=<manager_ip_address> --docker=<container_id/container_name>
```
The ```--docker``` flag ignores other settings flags and only installs and sets up the base agent, user, and bash command logging.


## Help
To get all the available script options, use the -h or --help option:
```
set_up_agent.sh -h

Usage: set_up_agent.sh [OPTIONS]

    --manager=<ip_address>                  [Optional] Set the Wazuh Manager ip address this Agent should report to.
                                            [Default] = localhost

    --name=<name>                           [Optional] Set a custom Wazuh Agent name. This name must be unique.
                                            [Default] = Agent_<localhost>

   --use_system_health=<true/false>         [Optional] Set if system health should be logged
                                            [Default] = true
    
    --use_bash_log=<true/false>             [Optional] Set if bash commands should be logged
                                            [Default] = true

    --use_heidpi=<true/false>               [Optional] Set if heiDPId should be installed, set up, and logged
                                            [Default] = true

    --use_ufw=<true/false>                  [Optional] Set if UFW should be set up and logged
                                            [Default] = true
                                            
    --use_container_logging=<true/false>    [Optional] Set if container logging should be set up and logged
                                            [Default] = true

    --os=<                                  [Optional] Set the os the Agent should run on. Supported os are:
          rpm_amd/                             Linux RPM amd64
          rpm_aarch/                           Linux RPM aarch64
          deb_amd/                             Linux DEB amd64
          deb_aarch/                           Linux DEB aarch64
          win/                                 Windows MSI 32/64 bits
          mac_intel/                           macOS intel
          mac_sillicon                         macOS Apple silicon
          >
                                            [Default] = Linux DEB amd64

    --docker=<container_id/name>            [Optional] Set Up the Agent inside the Docker container

    --remove                                [Optional] Remove the installed Wazuh Agent

    -y, --yes                               [Optional] Skip Setup Confirmation

    -h, --help                              [Optional] Show this help."

```
