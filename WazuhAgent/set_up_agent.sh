#!/bin/bash

MANAGER_IP_ADDRESS=$(hostname -I | awk '{print $1}')
LOCAL_IP_ADDRESS=$(hostname -I | awk '{print $1}')
AGENT_NAME="Agent_"$LOCAL_IP_ADDRESS""
BASH_LOG="true"
HEIDPI="true"
UFW="true"

OS_RPM_AMD="Linux RPM amd64"
OS_RPM_AARCH="Linux RPM aarch64"
OS_DEB_AMD="Linux DEB amd64"
OS_DEB_AARCH="Linux DEB aarch64"
OS_WIN="Windows MSI 32/64 bits"
OS_INTEL="macOS intel"
OS_SILLICON="macOS Apple silicon"

CMD_RUN_LINUX="sudo systemctl daemon-reload && sudo systemctl enable wazuh-agent && sudo systemctl start wazuh-agent"
CMD_RUN_WIN="NET START WazuhSvc"
CMD_RUN_MAC="sudo /Library/Ossec/bin/wazuh-control start"

CMD_RUN="$CMD_RUN_LINUX"
OS="$OS_DEB_AMD"

HELP="
Usage: set_up_agent.sh [OPTIONS]

    --manager=<ip_address>         [Optional] Set the Wazuh Manager ip address this Agent should report to.
                                   [Default] = localhost
                                   
    --name=<name>                  [Optional] Set the Agent name. This name must be unique.
                                   [Default] = Agent_<localhost>
                                   
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
                                   
    -h, --help                     [Optional] Show this help."

while [[ $# -gt 0 ]]; do
  case "$1" in
    --manager=*)
      MANAGER_IP_ADDRESS="${1#*=}"
      ;;
    --name=*)
      AGENT_NAME="${1#*=}"
      ;; 
    --use_bash_log=*)
      BASH_LOG="${1#*=}"
      ;;
    --use_heidpi=*)
      HEIDPI="${1#*=}"
      ;;
    --use_ufw=*)
      UFW="${1#*=}"
      ;;
    --os=rpm_amd)
      CMD_INSTALL="$CMD_INSTALL_RPM_AMD"
      CMD_RUN="$CMD_RUN_LINUX"
      OS="$OS_RPM_AMD"
      ;;
    --os=rpm_aarch)
      CMD_INSTALL="$CMD_INSTALL_RPM_AARCH"
      CMD_RUN="$CMD_RUN_LINUX"
      OS="$OS_RPM_AARCH"
      ;;
    --os=deb_amd)
      CMD_INSTALL="$CMD_INSTALL_DEB_AMD"
      CMD_RUN="$CMD_RUN_LINUX"
      OS="$OS_DEB_AMD"
      ;;
    --os=deb_aarch)
      CMD_INSTALL="$CMD_INSTALL_DEB_AARCH"
      CMD_RUN="$CMD_RUN_LINUX"
      OS="$OS_DEB_AARCH"
      ;;
    --os=win)
      CMD_INSTALL="$CMD_INSTALL_WIN"
      CMD_RUN="$CMD_RUN_WIN"
      OS="$OS_WIN"
      ;;
    --os=mac_intel)
      CMD_INSTALL="$CMD_INSTALL_MAC_INTEL"
      CMD_RUN="$CMD_RUN_MAC"
      OS="$OS_INTEL"
      ;;
    --os=mac_sillicon)
      CMD_INSTALL="$CMD_INSTALL_MAC_SILLICON"
      CMD_RUN="$CMD_RUN_MAC"
      OS="$OS_SILLICON"
      ;;
    -h|--help)
      echo "$HELP"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
  shift
done

CMD_INSTALL_RPM_AMD="curl -o wazuh-agent-4.11.0-1.x86_64.rpm https://packages.wazuh.com/4.x/yum/wazuh-agent-4.11.0-1.x86_64.rpm && sudo WAZUH_MANAGER='"$MANAGER_IP_ADDRESS"' WAZUH_AGENT_NAME='"$AGENT_NAME"' rpm -ihv wazuh-agent-4.11.0-1.x86_64.rpm"
CMD_INSTALL_RPM_AARCH="curl -o wazuh-agent-4.11.0-1.aarch64.rpm https://packages.wazuh.com/4.x/yum/wazuh-agent-4.11.0-1.aarch64.rpm && sudo WAZUH_MANAGER='"$MANAGER_IP_ADDRESS"' WAZUH_AGENT_NAME='"$AGENT_NAME"' rpm -ihv wazuh-agent-4.11.0-1.aarch64.rpm"
CMD_INSTALL_DEB_AMD="wget https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.11.0-1_amd64.deb && sudo WAZUH_MANAGER='"$MANAGER_IP_ADDRESS"' WAZUH_AGENT_NAME='"$AGENT_NAME"' dpkg -i ./wazuh-agent_4.11.0-1_amd64.deb"
CMD_INSTALL_DEB_AARCH="wget https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.11.0-1_arm64.deb && sudo WAZUH_MANAGER='"$MANAGER_IP_ADDRESS"' WAZUH_AGENT_NAME='"$AGENT_NAME"' dpkg -i ./wazuh-agent_4.11.0-1_arm64.deb"
CMD_INSTALL_WIN="Invoke-WebRequest -Uri https://packages.wazuh.com/4.x/windows/wazuh-agent-4.11.0-1.msi -OutFile $env:tmp\wazuh-agent; msiexec.exe /i $env:tmp\wazuh-agent /q WAZUH_MANAGER='"$MANAGER_IP_ADDRESS"' WAZUH_AGENT_NAME='"$AGENT_NAME"' "
CMD_INSTALL_MAC_INTEL="curl -so wazuh-agent.pkg https://packages.wazuh.com/4.x/macos/wazuh-agent-4.11.0-1.intel64.pkg && echo 'WAZUH_MANAGER=\""$MANAGER_IP_ADDRESS"\" && WAZUH_AGENT_NAME=\""$AGENT_NAME"\"' > /tmp/wazuh_envs && sudo installer -pkg ./wazuh-agent.pkg -target /"
CMD_INSTALL_MAC_SILLICON="curl -so wazuh-agent.pkg https://packages.wazuh.com/4.x/macos/wazuh-agent-4.11.0-1.arm64.pkg && echo 'WAZUH_MANAGER=\""$MANAGER_IP_ADDRESS"\" && WAZUH_AGENT_NAME=\""$AGENT_NAME"\"' > /tmp/wazuh_envs && sudo installer -pkg ./wazuh-agent.pkg -target /"

CMD_INSTALL="$CMD_INSTALL_DEB_AMD"

echo "Set up Agent:"
echo "OS: $OS"
echo "Agent Name: $AGENT_NAME"
echo "AGENT IP: $LOCAL_IP_ADDRESS"
echo "Manager IP: $MANAGER_IP_ADDRESS"

if [ "$MANAGER_IP_ADDRESS" == "$LOCAL_IP_ADDRESS" ]; then
  echo -e "\e[33m[Warning]:\e[0m Wazuh manager has same address as wazuh agent. Please provide the correct manager address using --manager. Ignore if manager and agent are on the same system"
fi

echo "Logging Bash: $BASH_LOG"
echo "Logging heiDPI: $HEIDPI"
echo "Logging UFW: $UFW"

echo ""
echo "Start Agent Set UP"
echo ""

echo "Downlaod Agent"
eval $CMD_INSTALL

echo ""
echo "Run Agent"
echo ""

eval $CMD_RUN

echo ""
echo "Agent Installed Succesfully"
echo ""










