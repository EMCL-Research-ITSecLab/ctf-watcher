#Manuel Grafana Set up
You can manually set up a Wazuh Agent or install it on a different machine by running 
```
set_up_grafana.sh
```
If the Wazuh Manager is on a different address you need to provide it
```
set_up_agent.sh --manager=<manager_ip_address>
```

To get all the available script options, use the -h or --help option:
```
set_up_grafana.sh -h

Usage: set_up_grafana.sh [OPTIONS]

    --manager=<ip_address>         [Optional] Set the Wazuh Manager ip address this Grafana dashboard should get data from.
                                   [Default] = localhost

    --port=<port>                  [Optional] Set the Wazuh Manager API port.
                                   [Default] = 9200

    --remove                       [Optional] Remove the installed Grafana Dashboard.

    -y, --yes                      [Optional] Skip Set Up Confirmation.

    -h, --help                     [Optional] Show this help.

```
