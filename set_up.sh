#!/bin/bash

IP_ADDRESS=$(hostname -I | awk '{print $1}')
RAM_MIN=8388608
RAM=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
HELP="
set_up.sh -h

Usage: set_up.sh [OPTIONS]

    --remove                  [Optional] Removes all containers and the Wazuh Agent."

clear -x
cat << "EOF"
   _____ _______ __  __          __   _       _               
  / ____|__   __/ _| \ \        / /  | |     | |              
 | |       | | | |_   \ \  /\  / /_ _| |_ ___| |__   ___ _ __ 
 | |       | | |  _|   \ \/  \/ / _` | __/ __| '_ \ / _ \ '__|
 | |____   | | | |      \  /\  / (_| | || (__| | | |  __/ |   
  \_____|  |_| |_|       \/  \/ \__,_|\__\___|_| |_|\___|_|   

EOF

function print_divider () {
    terminal=/dev/pts/1
    columns=$(stty -a <"$terminal" | grep -Po '(?<=columns )\d+')
    printf "%${columns}s\n" | tr " " "-"
}

function section_header () {
    clear -x
    print_divider
    echo "${1}..."
    print_divider
    sleep 5
}

function section_footer () {
    echo ""
}

function remove (){
    echo "Remove Wazuh Environment"
    ./clean_docker.sh #Todo: Only remove my containers
    WazuhAgent/set_up_agent.sh --remove
    echo "Everything removed"
}

if [ $(id -u) -ne 0 ]
then
    echo "Please run this script as root or using sudo!"
    exit 0
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --remove)
      remove
      exit 0
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

if [ $RAM -le $RAM_MIN ]; then
    echo "Not Enough Memory!"
    echo "MINIMUM: $RAM_MIN"
    echo "Current: $RAM"
    echo ""
    echo "Ignoring this warning can cause a broken installation."
    echo "Ignore warning? [y/yes]"
    read SET_UP_APPROVED
    if [ "$SET_UP_APPROVED" != "y" ] && [ "$SET_UP_APPROVED" != "yes" ]; then
        section_header "Setup Aborted"
        exit 0
    fi
 fi

print_divider
echo "Set Up Tool for Monitoring an Environment Created by the CTF-Creator. Using Wazuh, Grafana, cAdvisor, Prometheus, heiDPI, and Docker."
echo "Created by FeDaas"
print_divider
echo "Start Set Up..."
sleep 10

export SET_UP_STEP_MAIN="\e[1m [Step 1/4] Set Up Wazuh Docker\e[0m"
section_header "[1/4] Set Up Wazuh Docker"
cd WazuhDocker
./set_up_manager.sh
cd ..
section_footer
sleep 5

export SET_UP_STEP_MAIN="\e[1m [Step 2/4] Set Up Wazuh Agent\e[0m"
section_header "[2/4] Set Up Wazuh Agent"
cd WazuhAgent
./set_up_agent.sh -y
cd ..
section_footer
sleep 5

export SET_UP_STEP_MAIN="\e[1m [Step 3/4] Set Up cAdvisor\e[0m"
section_header "[3/4] Set Up cAdvisor"
cd cAdvisorDocker
./set_up_cadvisor.sh
cd ..
section_footer
sleep 5

export SET_UP_STEP_MAIN="\e[1m [Step 4/4] Set Up cAdvisor\e[0m"
section_header "[4/4] Set Up Grafana"
cd GrafanaDocker
./set_up_grafana.sh -y
cd ..
section_footer
sleep 5

clear -x

cat << "EOF"
   _____ _______ __  __          __   _       _               
  / ____|__   __/ _| \ \        / /  | |     | |              
 | |       | | | |_   \ \  /\  / /_ _| |_ ___| |__   ___ _ __ 
 | |       | | |  _|   \ \/  \/ / _` | __/ __| '_ \ / _ \ '__|
 | |____   | | | |      \  /\  / (_| | || (__| | | |  __/ |   
  \_____|  |_| |_|       \/  \/ \__,_|\__\___|_| |_|\___|_|   
                                                             
EOF

echo "Everything Installed!"
echo ""
echo ""
echo "Web Interfaces:"
echo -e "Name \t\t ADDRESS \t\t\t User \t\t PASSWORD"
echo "---------------------------------------------------------------------------------"
echo -e "Wazuh Manager \t https://$IP_ADDRESS \t\t admin \t\t Secret Password"
echo -e "cAdvisor \t http:///$IP_ADDRESS:8080 \t / \t\t /"
echo -e "Prometheus \t http:///$IP_ADDRESS:9090 \t / \t\t /"
echo -e "Wazuh Manager \t https://$IP_ADDRESS:3000 \t admin \t\t admin"
echo ""
echo ""
echo ""
echo "Show Status of installed Container (y|n)?"
read SHOW_CONTAINER
if [ "$SET_UP_APPROVED" == "y"  ]; then
  echo ""
  echo "Container:"
  docker container ls --format "table {{.Names}}:\t{{.ID}}:\t {{.Image}}:\t {{.Status}}:" 
fi
