# Manual Grafana Set up
You can manually set up a Grafana Dashboard or install it on a different machine by running 
```
set_up_grafana.sh
```
If the Wazuh Manager or cAdvidor are installed on a different system, you need to provide their address
```
set_up_agent.sh --manager=<manager_ip_address> --cadvisor=<cadvisor_ip_address>
```


To get all the available script options, use the ```-h``` or ```--help``` flag:
```
set_up_grafana.sh -h

Usage: set_up_grafana.sh [OPTIONS]

    --manager=<ip_address>         [Optional] Set the Wazuh Manager IP address the Grafana dashboard should get data from.
                                   [Default] = localhost

    --manager_port=<port>          [Optional] Set the Wazuh Manager API port.
                                   [Default] = 9200

    --cadvisor=<ip_address>        [Optional] Set the cAdvisor Prometheus IP address the Grafana dashboard should get data from.
                                   [Default] = localhost

    --cadvisor_port=<port>         [Optional] Set the cAdvisor Prometheus API port.
                                   [Default] = 9090

    --remove                       [Optional] Remove the installed Grafana Dashboard.

    -y, --yes                      [Optional] Skip Set Up Confirmation.

    -h, --help                     [Optional] Show this help.
```
