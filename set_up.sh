#!/bin/bash

IP_ADDRESS=$(hostname -I | awk '{print $1}')

clear -x
cat << "EOF"
 __          __             _       _____           _        _ _           
 \ \        / /            | |     |_   _|         | |      | | |          
  \ \  /\  / /_ _ _____   _| |__     | |  _ __  ___| |_ __ _| | | ___ _ __ 
   \ \/  \/ / _` |_  / | | | '_ \    | | | '_ \/ __| __/ _` | | |/ _ \ '__|
    \  /\  / (_| |/ /| |_| | | | |  _| |_| | | \__ \ || (_| | | |  __/ |   
     \/  \/ \__,_/___|\__,_|_| |_| |_____|_| |_|___/\__\__,_|_|_|\___|_|   
                                                                           
                                                                         
EOF

function print_divider () {
    terminal=/dev/pts/1
    columns=$(stty -a <"$terminal" | grep -Po '(?<=columns )\d+')
    printf "%${columns}s\n" | tr " " "-"
}

function section_header () {
    print_divider
    echo "${1}..."
    print_divider
    sleep 1
}

function section_footer () {
    echo ""
}

function remove (){
    echo "Remove Wazuh Enviroment"
    clean_docker.sh #Todo: Only remove my containers
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

section_header "Set Up Wazuh Manager"
WazuhDocker/set_up_manager.sh
section_footer

section_header "Set Up Wazuh Agent"
WazuhAgent/set_up_agent.sh -y
section_footer

section_header "Set Up cAdvisor"
cd cAdvisorDocker
./set_up_cadvisor.sh
cd ..
section_footer

section_header "Set Up Grafana"
cd GrafanaDocker
./set_up_grafana.sh
cd ..
section_footer

clear -x

cat << "EOF"
 __          __             _       _____           _        _ _           
 \ \        / /            | |     |_   _|         | |      | | |          
  \ \  /\  / /_ _ _____   _| |__     | |  _ __  ___| |_ __ _| | | ___ _ __ 
   \ \/  \/ / _` |_  / | | | '_ \    | | | '_ \/ __| __/ _` | | |/ _ \ '__|
    \  /\  / (_| |/ /| |_| | | | |  _| |_| | | \__ \ || (_| | | |  __/ |   
     \/  \/ \__,_/___|\__,_|_| |_| |_____|_| |_|___/\__\__,_|_|_|\___|_|   
                                                                           
                                                                         
EOF
echo "Everything Installed Succsessfully!"
echo ""
echo ""
echo -e "Name \t\t ADDRESSS \t\t\t User \t\t PASSWORD"
echo "---------------------------------------------------------------------------------"
echo -e "Wazuh Manager \t https://$IP_ADDRESS \t\t admin \t\t Secret Password"
echo -e "cAdvisor \t http:///$IP_ADDRESS:8080 \t / \t\t /"
echo -e "Prometheus \t http:///$IP_ADDRESS:9090 \t / \t\t /"
echo -e "Wazuh Manager \t https://$IP_ADDRESS:3000 \t admin \t\t admin"

docker container ls 







