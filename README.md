Monitoring tool for CTF-Creator 

# Set up a Wazuh environment with extended monitoring, specialized in supervising cybersecurity training environments created by the CTF-Creator

Wazuh:    [Wazuh Website](https://wazuh.com/)

Grafana:  [Grafana Website](https://grafana.com/)

CTF-Creator: [GitHub Page](https://github.com/EMCL-Research-ITSecLab/ctf-creator)


## Complete setup on one system:
```
sudo set_up.sh
```

## Manual setup:

Set up the components on the same or different systems
1) Install and set up Docker on Systems where the Wazuh Manager and Grafana should run.
```
sudo bash set_up_docker.sh
```
If you have Docker already installed, make sure the current user is inside a Docker group:
```
sudo groupadd docker
sudo usermod -aG docker $user
```

2) Install and set up Wazuh Manager:
```
sudo bash WazuhDocker/set_up.sh
```
more info: [Wazuh Manager](https://github.com/EMCL-Research-ITSecLab/ctf-watcher/tree/main/WazuhDocker)

3) Install and set up Wazuh Agent:
```
sudo bash WazuhAgent/set_up_agent.sh
```
If the Agent is on a different system than the Manager, you need to provide the Manager's IP:
```
sudo bash WazuhAgent/set_up_agent.sh --manager=<manager_ip_address>
```

more info: [Wazuh Agent](https://github.com/EMCL-Research-ITSecLab/ctf-watcher/tree/main/WazuhAgent)

4) Install and set up Grafana
```
sudo bash GrafanaDocker/set_up_grafana.sh
```
If Grafana is on a different system than the Manager, you need to provide the Manager's IP:
```
sudo bash GrafanaDocker/set_up_grafana.sh --manager=<manager_ip_address>
```
more info: [Grafana Dashboard](https://github.com/EMCL-Research-ITSecLab/ctf-watcher/tree/main/GrafanaDocker) 

5) Now you can visit the Wazuh and Grafana dashboards in your browser via:

Wazuh:
```
 https://<wazuh_ip>
```
Default user is **Admin** and password is **SecretPassword** 

Grafana:
```
 https://<grafana_ip>:3000
```
Default user is **Admin** and password is **Admin** 


## Grafana Dashboard Features

Incomplete list of Grafana Dashboard Features

### Performance

1) Live surveillance of the Wazuh Manager System resources

### Users

1) Number of current active users, as well as an active user timeline
2) All currently active users and from where they are connected
3) All commands executed by users. Filterable by user. Sudo commands are highlighted.

### SSH
1) A life graph tracking the number of successful and unsuccessful SSH requests

### Firewall
1) A list of all active UFW Rules
2) A List of Blocked UFW Events

### Network Flow
1) A list of heiDPId flow events. Traffic outside is highlighted.
2) A list of heiDPId packed events. Traffic outside is highlighted.
3) Traffic outside is visualized and pinpointed on a world map.

## Additional Wazuh Alerts

The custom Wazuh alerts, their ID, and level. 
### Performance

| Description      | Rule ID      | Level |
| ------------- | ------------- | ------|
| CPU / MEMORY / DISK usage metrics | 100100 | 3 |
| Memory usage is high &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| 100101 | 12 |
| CPU usage is high | 100102 | 12 |
| Disk space is running low | 100103 | 12 |
| Load average metrics | 100104 | 3 |
| Memory metrics | 100105 | 3 |
| Disk metrics | 100106 | 3 |

### Active User

| Description      | Rule ID      | Level |
| ------------- | ------------- | ------|
| Active user check &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| 100201 | 3 |
| Active user number check | 100202 | 1 |


### SSH

| Description     | Rule ID      | Level |
| ------------- | ------------- | ------|
| sshd: authentication failed &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| 100301 | 5 |

### Bash Logging

| Description      | Rule ID      | Level |
| ------------- | ------------- | ------|
| Bash command used &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| 100401 | 3 |

### heiDPId

| Description      | Rule ID      | Level |
| ------------- | ------------- | ------|
| heiDPI flow event &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | 100501 | 3 |
| heiDPI packet event | 100502 | 3 |


### UFW

| Description      | Rule ID      | Level |
| ------------- | ------------- | ------|
| UFW Status | 100600 | 3 |
| Firewall block event | 100601 | 5 |
| Multiple Firewall block events from same source | 100602 | 5 |

### OpenVPN

| Description      | Rule ID      | Level |
| ------------- | ------------- | ------|
| OpenVPN access server messages grouped &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| 100701 | 1 |
| OpenVPN remote connection established | 100702 | 3 |

## Modify the project

If you want to make changes to the setup, change the following files:
### Wazuh
Custom Wazuh Rules can be created as described in the [Wazuh Documentation](https://documentation.wazuh.com/current/user-manual/ruleset/rules/custom.html).
If you only want to change them in a running setup, keep in mind that the mentioned files and commands must be altered and executed inside the corresponding Docker container. You can easily work inside a container with 
```
docker exec -it <container_id_or_name>
```
Else, modify [local_file_ossec_conf](https://github.com/EMCL-Research-ITSecLab/ctf-watcher/blob/main/WazuhAgent/config/localfile_ossec_config), [local_decoder.xml](https://github.com/EMCL-Research-ITSecLab/ctf-watcher/blob/main/WazuhDocker/config/local_decoder.xml) and [local_rules.xml](https://github.com/EMCL-Research-ITSecLab/ctf-watcher/blob/main/WazuhDocker/config/local_rules.xml) and use this project as usual.

### Grafana
Simply modify the dashboard via the Grafana UI.\
If you want to use your custom dashboard in this project, export it via the Grafana UI. Make sure to use the 'Export the dashboard to use in another instance' setting and encase the output in a dashboard key: ```{"dashboard":<outuput>}```\
Then override the [wazuh_dashboard.json](https://github.com/EMCL-Research-ITSecLab/ctf-watcher/blob/main/GrafanaDocker/config/wazuh_dashboard.json) and use this project as usual.

### Excluded Container
The setup ignores containers created from specific images. They are defined by the `EXCLUDED_IMAGES` array at the top of the files
[set_up.sh](https://github.com/EMCL-Research-ITSecLab/ctf-watcher/blob/main/set_up.sh) and 
[container_logging_set_up.sh](https://github.com/EMCL-Research-ITSecLab/ctf-watcher/blob/main/WazuhAgent/config/container_logging_set_up.sh). Add or remove image names to include or exclude their containers.








