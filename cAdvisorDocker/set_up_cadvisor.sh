#!/bin/bash
VERSION=v0.49.1 # use the latest release version from https://github.com/google/cadvisor/releases
LOCAL_IP_ADDRESS=$(hostname -I | awk '{print $1}')

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

sed -i "s/<cadvisor_ip>/$LOCAL_IP_ADDRESS/g" prometheus.yaml

docker compose -f docker-compose.yaml up -d

echo ""
echo "cAdvisor setup complete. You can visit the web interface"
echo "cAdvisor: $LOCAL_IP_ADDRESS:8080"
echo "Prometheus: $LOCAL_IP_ADDRESS:9090"
