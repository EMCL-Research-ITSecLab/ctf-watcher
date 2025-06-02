#!/bin/bash

EXCLUDED_IMAGES=("grafana" "prom" "gcr.io" "stefan96/heidpi" "wazuh" "openvpn")
IP_ADDRESS=$(hostname -I | awk '{print $1}')
RAM_GB_MIN=8
RAM=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
RAM_GB=$(awk "BEGIN {print int($RAM/1048576)}")
DISK_GB_MIN=10
DISK_GB_FREE=$(df --block-size=1G / | awk 'NR==2 {print $4}' | sed 's/[^0-9]*//g')
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
  \_____|  |_| |_|       \/  \/ \__,_|\__\___|_| |_|\___|_| Created by FeDaas
EOF
#echo "Created by FeDaas"

function print_divider () {
    columns=$(tput cols)
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
    utils/clean_docker.sh #Todo: Only remove my containers
    WazuhAgent/set_up_agent.sh --remove
    echo "Everything removed"
}

function is_excluded_image() {
  for prefix in "${EXCLUDED_IMAGES[@]}"; do
    if [[ "$1" == "$prefix"* ]]; then
      return 0
    fi
  done
  return 1
}

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

print_divider
echo "Set Up Tool for Monitoring an Environment Created by the CTF-Creator"
echo "Using Wazuh, Grafana, cAdvisor, Prometheus, heiDPI, and Docker"
print_divider
echo ""
echo -ne "Checking Requirements...\r"

if [ $(id -u) -ne 0 ]
then
    echo ""
    echo ""
    echo "Please run this script as root or using sudo!"
    exit 0
fi

if ! docker info &> /dev/null; then
  echo ""
  echo ""
  echo "Docker not installed or not installed correctly. Please run sudo ./utils/install_docker.sh"
  exit 0
fi

REQUIREMENTS_FULLFILLED="true"

if [ "$DISK_GB_FREE" -ge "$DISK_GB_MIN" ]; then
    DISK_STATUS="[\033[32mO\033[0m]"  
else
    DISK_STATUS="[\033[31mX\033[0m]"
    REQUIREMENTS_FULLFILLED="false"
fi
if [ "$RAM_GB" -ge "$RAM_GB_MIN" ]; then
    RAM_STATUS="[\033[32mO\033[0m]"  
else
    RAM_STATUS="[\033[31mX\033[0m]"
     REQUIREMENTS_FULLFILLED="false"
fi

CONTAINER_COUNT=0
CONTAINER_EXCLUDED_COUNT=0

for container_id in $(docker ps -q); do
  IMAGE_NAME=$(docker inspect --format='{{.Config.Image}}' "$container_id")
  if is_excluded_image "$IMAGE_NAME"; then
    ((CONTAINER_EXCLUDED_COUNT++))
  else
     ((CONTAINER_COUNT++))
  fi
done

MIN_BASE=10
MIN_PER_CON=2
MIN_TOTAL=$((MIN_BASE + MIN_PER_CON * CONTAINER_COUNT))
ETA_HOURS=$((MIN_TOTAL / 60))
ETA_MIN=$((MIN_TOTAL % 60))

echo " Set up Components:                                                          Requirements:"
echo "+------------------------+---------------------------------------------+    +------------------------------------------+"
echo -e "| [1] Wazuh Docker       | - Wazuh Manager Container                   |    | Disk Space:    $DISK_GB_FREE GB / $DISK_GB_MIN GB\t$DISK_STATUS\t|"
echo -e "|                        | - Wazuh Indexer Container                   |    | Memory:        $RAM_GB GB / $RAM_GB_MIN GB\t$RAM_STATUS\t|"
echo "|                        | - Wazuh Dashboard Container                 |    +------------------------------------------+"
echo "+------------------------+---------------------------------------------+    +------------------------------------------+"
echo "| [2] Wazuh Agent        | - Wazuh Agent installation                  |    | The Setup Time Depends on:               |"
echo "|                        | - Bash Logging Setup                        |    |     - Internet Connection                |"
echo "|                        | - heiDPID Producer and Consumer Containers  |    |     - Number of Containers               |"
echo "|                        | - UFW enabled and rules added               |    |                                          |"
echo "|                        | - Bash Logging Setup inside Containers      |    | Container:                               |"
echo -e "+------------------------+---------------------------------------------+    |     - $CONTAINER_COUNT ($CONTAINER_EXCLUDED_COUNT excluded)\t\t\t|"
echo "| [3] cAdvisor           | - cAdvisor Container                        |    |                                          |"
echo "|                        | - Prometheus Container                      |    | ETA:                                     |"
echo -e "+------------------------+---------------------------------------------+    |             [ $ETA_HOURS H : $ETA_MIN m ]  \t\t|"
echo "| [4] Grafana            | - Grafana Container                         |    |       (10min + 2min x #Container)        |"
echo "+------------------------+---------------------------------------------+    +------------------------------------------+"
echo ""
echo -n "Start Setup"

if [ "$REQUIREMENTS_FULLFILLED" == "false" ]; then
    echo -ne "\033[31m even with unfulfilled requirements\033[0m"
fi
echo -n " (y|n)?"


read SET_UP_APPROVED
if [ "$SET_UP_APPROVED" != "y" ] && [ "$SET_UP_APPROVED" != "yes" ]; then
    section_header "Setup Aborted"
    exit 0
fi

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

export SET_UP_STEP_MAIN="\e[1m [Step 3/4] Set Up Container Monitoring\e[0m"
section_header "[3/4] Set Up Container Monitoring"
cd cAdvisorDocker
./set_up_cadvisor.sh
cd ..
section_footer
sleep 5

export SET_UP_STEP_MAIN="\e[1m [Step 4/4] Set Up Grafana\e[0m"
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
echo -e "Wazuh \t\t https://$IP_ADDRESS \t\t admin \t\t Secret Password"
echo -e "cAdvisor \t http:///$IP_ADDRESS:8080 \t / \t\t /"
echo -e "Prometheus \t http:///$IP_ADDRESS:9090 \t / \t\t /"
echo -e "Grafana \t http://$IP_ADDRESS:3000 \t admin \t\t admin"
echo ""
echo ""
echo ""
echo "Show Status of installed Container (y|n)?"
read SHOW_CONTAINER
if [ "$SHOW_CONTAINER" == "y"  ]; then
  echo ""
  echo "Container:"
  docker container ls --format "table {{.Names}}:\t{{.ID}}:\t {{.Image}}:\t {{.Status}}:" 
fi
