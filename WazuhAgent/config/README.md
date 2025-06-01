# Manual Logging Set Up
The actual logging mechanism can be set up independently from the Agent. 

## Bash Logging
Logs executed bash commands

Usage:
```
sudo ./bash_loggin_set_up.sh --private_log=<path_to_private_log>
```
The Optional `--private_log` flag defines an additional log where only the personal bash logs are stored.

Logs:
- Timestamp
- Environment
- User
- Working Directory
- Exit code
- Excluded Command

Log File:
- /var/log/commands.log
- <private_file>

## Container Logging
Sets up Bash logging inside the specified container

Usage:
```
sudo ./container_logging_set_up.sh
```

Logs:
- Same as Bash Logging

Log File:
- /var/log/commands.log (Inside the Container)
- /wazuh-agent/commands.log (Inside the Container)

To provide logging to the host and Wazuh, the supervised containers need to be started with binds:
```
docker run \
  --name <name> \
  -e ENV_CONTAINER_NAME="<name>" \
  --mount type=bind,source=/var/log/commands.log,target=/var/log/commands.log \
  --mount type=bind,source=<path_to_private_log>,target=/wazuh-agent/commands.log \
  -d <Image>
```

## Network Traffic Logging

Usage:
```
sudo ./heiDPI_set_up.sh
```

Logs:
- Flow Events
- Packet Events

Log FIle:
- /var/log/syslog

## Firewall Logging

Usage:
```
sudo ./ufw_set_up.sh
```

Logs:
- Firewall Events
- UFW Status

Log FIle:
- /var/log/syslog
