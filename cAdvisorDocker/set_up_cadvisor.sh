#!/bin/bash
VERSION=v0.49.1 # use the latest release version from https://github.com/google/cadvisor/releases
LOCAL_IP_ADDRESS=$(hostname -I | awk '{print $1}')

function print_info()
{
echo ""
echo -e "\e[34m[Info]:\e[0m $SET_UP_STEP_MAIN | $1"
echo ""
}

print_info "[1/2] Start cAdvisor Docker"

sudo docker run \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:ro \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --volume=/dev/disk/:/dev/disk:ro \
  --publish=8080:8080 \
  --detach=true \
  --name=cadvisor \
  --restart unless-stopped \
  --privileged \
  --device=/dev/kmsg \
  gcr.io/cadvisor/cadvisor:$VERSION

print_info "[2/2] Start Prometheus Docker"
sed -i "s/<cadvisor_ip>/$LOCAL_IP_ADDRESS/g" prometheus.yaml
docker compose -f docker-compose.yaml up -d

echo
echo -e "$SET_UP_STEP_MAIN: cAdvisor Instalation Finished!"
echo

echo "Web interfaces:"
echo "cAdvisor: $LOCAL_IP_ADDRESS:8080"
echo "Prometheus: $LOCAL_IP_ADDRESS:9090"
