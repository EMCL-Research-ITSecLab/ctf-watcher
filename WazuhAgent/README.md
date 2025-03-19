# Manuel Wazuh Agent SetUp
You can manually set up a Wazuh Agent or install it on a different maschine by running 
```
set_up_agent.sh
```
To get all the available script options use the -h or --help option:

```
set_up_agent.sh -h

Usage: set_up_agent.sh [OPTIONS]

    -d, --dev <ref>                [Optional] Set the development stage you want to build, example rc1 or beta1, not used by default.
    --manager=<ip_address>         [Optional] Set the Wazuh Manager ip address this Agent should report to.
                                   [Default] = localhost
    --use_bash_log=<true/false>    [Optional] Set if bash commands should be logged
                                   [Default] = true
    --use_heidpi=<true/false>      [Optional] Set if heiDPId should be installed, set up and logged
                                   [Default] = true
    --use_ufw=<true/false>         [Optional] Set if UFW should be set up and logged
                                   [Default] = true
    --os=<                         [Optional] Set the os the Agent should run on. Supportet os are:
          rpm_amd/                     Linux RPM amd64
          rpm_aarch/                   Linux RPM aarch64
          deb_amd/                     Linux DEB amd64
          deb_aarch/                   Linux DEB aarch64
          win/                         Windows MSI 32/64 bits
          mac_intel/                   macOS intel
          mac_sillicon                 macOS Apple silicon
          >
                                   [Default] = Linux DEB amd64
    -h, --help                     [Optional] Show this help.

```
