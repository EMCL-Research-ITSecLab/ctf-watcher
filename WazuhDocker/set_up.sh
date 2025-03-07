#!/bin/bash


cat << "EOF"

                               __                    
 \ \        / /            | |     |   |         | |      | | |
  \ \  /\  / /  __   | |__     | |     _| | __ | | |    
   \ /  / / ` |  / | | | ' \    | | | ' / | / ` | | |/  \ '|
    \  /\  / (| |/ /| || | | | |  | || | | _ \ || (| | | |  / |
     /  / _,/|_,|| || |__|| ||/__,|||_|_|


EOF


if [ $(id -u) -ne 0 ]
then
    echo "Please run this script as root or using sudo!"
    exit 0
fi


echo
echo --------[1/4]Set Map Count--------
echo

sysctl -w vm.max_map_count=262144

echo
echo --------[2/4]Build Images--------
echo

cd wazuh-docker
git checkout 4.11.1
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
