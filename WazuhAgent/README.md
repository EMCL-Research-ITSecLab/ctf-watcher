# Manual Wazuh Agent Set Up
You can manually set up a Wazuh Agent or install it on a different machine by running 
```
set_up_agent.sh
```

If the Wazuh Manager is on a different address you need to provide it
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
set_up_agent.sh --use_system_health=false --use_bash_log=false --use_heidpi=false --use_use_ufw=false
```
These can also be manually set up after the Agent is installed by running their corresponding script
```
sudo ./config/bash_loggin_set_up.sh
sudo ./config/heiDPI_set_up.sh
sudo ./config/ufw_set_up.sh
```


To get all the available script options, use the -h or --help option:
```
set_up_agent.sh -h

Usage: set_up_agent.sh [OPTIONS]

    --manager=<ip_address>          [Optional] Set the Wazuh Manager ip address this Agent should report to.
                                    [Default] = localhost

    --name=<name>                   [Optional] Set a custom Wazuh Agent name. This name must be unique.
                                    [Default] = Agent_<localhost>

   --use_system_health=<true/false> [Optional] Set if system health should be logged
                                    [Default] = true
    
    --use_bash_log=<true/false>     [Optional] Set if bash commands should be logged
                                    [Default] = true

    --use_heidpi=<true/false>       [Optional] Set if heiDPId should be installed, set up and logged
                                    [Default] = true

    --use_ufw=<true/false>          [Optional] Set if UFW should be set up and logged
                                    [Default] = true

    --os=<                          [Optional] Set the OS the Agent should run on. Supported OSs are:
          rpm_amd/                     Linux RPM amd64                (Not tested)
          rpm_aarch/                   Linux RPM aarch64              (Not tested)
          deb_amd/                     Linux DEB amd64                (Not tested)
          deb_aarch/                   Linux DEB aarch64              (Full functionality)
          win/                         Windows MSI 32/64 bits         (Only base functinality)
          mac_intel/                   macOS intel                    (Only base functinality)
          mac_sillicon                 macOS Apple silicon            (Only base functinality)
          >
                                    [Default] = Linux DEB amd64

    --remove                        [Optional] Remove the installed Wazuh Agent

    -y, --yes                       [Optional] Skip Setup Confirmation

    -h, --help                      [Optional] Show this help.

```
