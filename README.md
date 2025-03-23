This is the Git Repository for the Master Practical:
Evaluating XDR applications to protect Training Environments for the next Generation of Cybersecurity Specialists
at the EMCL Research Group at University Heidelberg

# Set up a Wazuh enviroment with extended monitoring specialized in supervising cybersecurity training environments visaualised in Grafana OSS

Wazuh:    [Wazuh Website](https://wazuh.com/)

Grafana:  [Grafana Website](https://grafana.com/)


## Complete setup on one system:
```
Todo
```

## Manual setup:

Set up the components on the same or different systems

1) Install and set up Wazuh Manager:
```
sudo bash WazuhDocker/set_up.sh
```
more info: [Wazuh Manager](https://github.com/FeDaas/Master-Practical-Evaluating-XDR-applications/tree/main/WazuhDocker)

2) Install and set up Wazuh Agent:
```
sudo bash WazuhAgent/set_up_agent.sh
```
If the Agent is on a differnet system than the Manager you need to provide the Managers IP:
```
set_up_agent.sh --manager=<manager_ip_address>
```

more info: [Wazuh Agent](https://github.com/FeDaas/Master-Practical-Evaluating-XDR-applications/tree/main/WazuhAgent)

3) Install and set up Grafana

Exchange the url in *GrafanaDocker/config/wazuh_datasource.json* with your Managers ip: (ToDo: make this automatic in set_up_grafana.sh)
```
"url": "https://<manager_ip_address>:9200",
```
Then set up Grafana Dashboard:
```
sudo bash GrafanaDocker/set_up_grafana.sh
```
more info: [Grafana Dashboard](https://github.com/FeDaas/Master-Practical-Evaluating-XDR-applications/tree/main/GrafanaDocker) 

4) Now you can visit the wazuh and grafana dashboard in your browser via:

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

1) Life survailance of the Wazuh Manager System resources

### Users

1) Number of current active users aswell as an active user timeline
2) All curently active user and from where there are connected
3) All commands executed by users. Filterable by user. Sudo commands are highlighted.

### SSH
1) A life graph tracking the number of successfull, unsuccesfull and suspicious ssh requests

### UFW
1) A list of all active UFW Rules
2) A List of Blcoked UFW Events

### heiDPId
1) A list of heiDPId flow events. Traffic ooutside is highlighted.
2) A list of heiDPId packed events. Traffic ooutside is highlighted.
3) Traffic outside is visualised and pinpointed on a world map

## Additional Wazuh Alerts

The added Wazuh Alerts. These can be further extended as described in the [Wazuh Documentation](https://documentation.wazuh.com/current/user-manual/ruleset/rules/custom.html).
Note that the mentioned files and commands must be altered and executed inside the corresponding docker container. You can easily work inside a container with 
```
docker exec -it <container_id_or_name>
```

### SSH

| Describtion      | Rule ID      | Level |
| ------------- | ------------- | ------|
| sshd: authentication failed &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| 100001 | 5 |

### UFW

| Describtion      | Rule ID      | Level |
| ------------- | ------------- | ------|
| Firewall block event | 104102 | 5 |
| Multiple Firewall block events from same source | 104151 | 5 |
| UFW Status | 100301 | 1 |

### heiDPId

| Describtion      | Rule ID      | Level |
| ------------- | ------------- | ------|
| heiDPI flow event &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | 100011 | 1 |
| heiDPI packet event | 100012 | 1 |

### Bash Logging

| Describtion      | Rule ID      | Level |
| ------------- | ------------- | ------|
| Bash command used &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| 100201 | 1 |


### Active User

| Describtion      | Rule ID      | Level |
| ------------- | ------------- | ------|
| Active user check &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| 100101 | 1 |
| Active user number check | 100102 | 1 |

### Performance

| Describtion      | Rule ID      | Level |
| ------------- | ------------- | ------|
| Memory usage is high &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| 100055 | 12 |
| CPU usage is high | 100056 | 12 |
| Disk space is running low | 100057 | 12 |
| Load average metrics | 100058 | 3 |
| Memory metrics | 100059 | 3 |
| Disk metrics | 100060 | 3 |






