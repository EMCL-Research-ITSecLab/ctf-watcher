#!/bin/bash

SYSCTL_CONF="/etc/sysctl.conf" 
IP_ADDRESS=$(hostname -I | awk '{print $1}')
RAM_MIN=8388608
RAM=$(awk '/MemTotal/ {print $2}' /proc/meminfo)

cat << "EOF"
 __          __             _       _____           _        _ _           
 \ \        / /            | |     |_   _|         | |      | | |          
  \ \  /\  / /_ _ _____   _| |__     | |  _ __  ___| |_ __ _| | | ___ _ __ 
   \ \/  \/ / _` |_  / | | | '_ \    | | | '_ \/ __| __/ _` | | |/ _ \ '__|
    \  /\  / (_| |/ /| |_| | | | |  _| |_| | | \__ \ || (_| | | |  __/ |   
     \/  \/ \__,_/___|\__,_|_| |_| |_____|_| |_|___/\__\__,_|_|_|\___|_|   
                                                                           
                                                                         
EOF


if [ $(id -u) -ne 0 ]; then
    echo "Please run this script as root or using sudo!"
    exit 0
fi

if [ $RAM -le $RAM_MIN ]; then
    echo "Not Enough Memory!"
    echo "MINIMUM: $RAM_MIN"
    echo "Current: $RAM"
    echo ""
    echo "Ignoring this warnig can cause a broken installation"
    echo "Ignore warning? [y/yes]"
    read SET_UP_APPROVED
    if [ "$SET_UP_APPROVED" != "y" ] && [ "$SET_UP_APPROVED" != "yes" ]; then
        print "Setup Aborted"
        exit 0
    fi
 fi

echo
echo --------[1/4]Set Map Count--------
echo

sysctl -w vm.max_map_count=262144

if grep -q "vm.max_map_count" "$SYSCTL_CONF"; then
    sed -i 's/^vm.max_map_count.*/vm.max_map_count=262144/' "$SYSCTL_CONF"
else
    echo "vm.max_map_count=262144" >> "$SYSCTL_CONF"
fi

echo
echo --------[2/4]Build Images--------
echo

cd wazuh-docker
git checkout v4.11.1
sudo -u $SUDO_USER ./build-docker-images/build-images.sh -v 4.11.1

echo
echo --------[3/3]Generat Certs--------
echo

cd single-node
sudo -u $SUDO_USER docker-compose -f generate-indexer-certs.yml run --rm generator

echo
echo --------[4/4]Compose Docker--------
echo


sudo -u $SUDO_USER docker-compose up -d

echo
echo --------[5/5]Set up custom rules--------
echo

cd ..
cd ..

docker cp config/local_rules.xml $(docker ps -aqf "name=single-node-wazuh.manager-1"):/var/ossec/etc/rules/local_rules.xml
docker cp config/local_decoder.xml $(docker ps -aqf "name=single-node-wazuh.manager-1"):/var/ossec/etc/decoders/local_decoder.xml
#docker cp config/ossec.conf $(docker ps -aqf "name=single-node-wazuh.manager-1"):/var/ossec/etc/decoders/local_decoder.xm


echo
echo --------[6/6]Restart Manager--------
echo

docker restart $(docker ps -aqf "name=single-node-wazuh.manager-1")


echo
echo --------Instalation Finished--------
echo

echo "Dashboard: https://$IP_ADDRESS"
echo User: admin
echo Password: SecretPassword
