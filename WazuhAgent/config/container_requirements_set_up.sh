#!/bin/bash

DEPENDENCY_FAILED="false"
CONTAINER_NAME="${ENV_CONTAINER_NAME}"
if [ -z "$CONTAINER_NAME" ]; then CONTAINER_NAME=$(hostname); fi

echo -e "\e[34m[Info]:\e[0m $CONTAINER_NAME: Start Requirements set up"

install_dependency()
{
if ! output=$(apt install -y "$1" 2>&1 > /dev/null); then
  DEPENDENCY_FAILED="true"
  echo -e " $CONTAINER_NAME: \e[31m[FAILED]\e[0m installing dependency $1:"
  echo "---------<ERROR MESSAGE>---------"
  echo "$output"
  echo "---------<ERROR MESSAGE>---------"
  echo ""
fi
}

apt update > /dev/null 2>&1
apt upgrade -y > /dev/null 2>&1

install_dependency sudo
install_dependency systemctl
install_dependency wget
install_dependency lsb-release
install_dependency procps
install_dependency rsyslog
install_dependency shwupdiwupdiluppy

if [ "$DEPENDENCY_FAILED" = "true" ]; then
  echo -e "\e[34m[Info]:\e[0m $CONTAINER_NAME: Requirements set up with \e[31m[ERROR]\e[0m"
else
 echo -e "\e[34m[Info]:\e[0m $CONTAINER_NAME: Requirements set up \e[32m[SUCCESSFULLY]\e[0m"
fi
