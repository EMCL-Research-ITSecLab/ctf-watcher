#!/bin/bash

SYSCTL_CONF="/etc/sysctl.conf" 
IP_ADDRESS=$(hostname -I | awk '{print $1}')
RAM_MIN=8388608
RAM=$(awk '/MemTotal/ {print $2}' /proc/meminfo)

function print_info()
{
echo ""
echo -e "$SET_UP_STEP_MAIN | \e[34m[Info]:\e[0m $1"
echo ""
}

function print_warning()
{
echo ""
echo -e "$SET_UP_STEP_MAIN | \e[33m[Warn]:\e[0m $1"
echo ""
}

function print_error()
{
echo ""
echo -e "$SET_UP_STEP_MAIN | \e[31m[Error]:\e[0m $1"
echo ""
}


if [ $(id -u) -ne 0 ]; then
    echo "Please run this script as root or using sudo!"
    exit 0
fi

if [ $RAM -le $RAM_MIN ]; then
    echo "Not Enough Memory!"
    echo "MINIMUM: $RAM_MIN"
    echo "Current: $RAM"
    echo ""
    echo "Ignoring this warning can cause a broken installation."
    echo "Ignore warning? [y/yes]"
    read SET_UP_APPROVED
    if [ "$SET_UP_APPROVED" != "y" ] && [ "$SET_UP_APPROVED" != "yes" ]; then
        print_info "Setup Aborted"
        exit 0
    fi
 fi


#####################################################
print_info "[1/6] Set Map Count"

sysctl -w vm.max_map_count=262144

if grep -q "vm.max_map_count" "$SYSCTL_CONF"; then
    sed -i 's/^vm.max_map_count.*/vm.max_map_count=262144/' "$SYSCTL_CONF"
else
    echo "vm.max_map_count=262144" >> "$SYSCTL_CONF"
fi

print_info "[2/6] Build Images"

cd wazuh-docker
git checkout v4.11.1

#####################################################
print_info "[3/6] Generating Certifications"


cd single-node
sudo -u $SUDO_USER docker-compose -f generate-indexer-certs.yml run --rm generator

#####################################################
print_info "[4/6] Compose Docker"


sudo -u $SUDO_USER docker-compose up -d

#####################################################
print_info "[5/6] Add Custom Rules"

cd ..
cd ..

docker cp config/local_rules.xml $(docker ps -aqf "name=single-node-wazuh.manager-1"):/var/ossec/etc/rules/local_rules.xml
docker cp config/local_decoder.xml $(docker ps -aqf "name=single-node-wazuh.manager-1"):/var/ossec/etc/decoders/local_decoder.xml

#####################################################
print_info "[6/6] Restart Manager"

docker restart $(docker ps -aqf "name=single-node-wazuh.manager-1")


echo
echo -e "$SET_UP_STEP_MAIN: Wazuh Docker Installation Finished!"
echo

echo "Dashboard: https://$IP_ADDRESS"
echo User: admin
echo Password: SecretPassword
