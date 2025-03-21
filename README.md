This is the Git Repository for the Master Practical:
Evaluating XDR applications to protect Training Environments for the next Generation of Cybersecurity Specialists
at the EMCL Research Group at University Heidelberg

# Set up a Wazuh enviroment with Wazuh Manager, Wazuh Agent visualised with Grafana

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

Edit GrafanaDocker/config/wazuh_datasource.json to provide the Managers IP: (ToDo: make this automatic in set_up_grafana.sh)
```
"url": "https://<manager_ip_address>:9200",
```
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

