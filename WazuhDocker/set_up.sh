#!/bin/bash


cat << "EOF"

 __          __             _       _____           _        _ _           
 \ \        / /            | |     |_   _|         | |      | | |          
  \ \  /\  / /_ _ _____   _| |__     | |  _ __  ___| |_ __ _| | | ___ _ __ 
   \ \/  \/ / _` |_  / | | | '_ \    | | | '_ \/ __| __/ _` | | |/ _ \ '__|
    \  /\  / (_| |/ /| |_| | | | |  _| |_| | | \__ \ || (_| | | |  __/ |   
     \/  \/ \__,_/___|\__,_|_| |_| |_____|_| |_|___/\__\__,_|_|_|\___|_|   
                                                                       

EOF


echo
echo --------[1/3]Set Map Count--------
echo

sysctl -w vm.max_map_count=262144

cd wazuh-docker
cd single-node

echo
echo --------[2/3]Generat Certs--------
echo

docker-compose -f generate-indexer-certs.yml run --rm generator

echo
echo --------[3/3]Compose Docker--------
echo

docker-compose up -d
