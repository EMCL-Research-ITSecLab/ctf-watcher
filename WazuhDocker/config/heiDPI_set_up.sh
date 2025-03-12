#!/bin/bash
ABSOLUTE_PATH_CONFIG=$(realpath heiDPI_config.yml)

curl -O https://cdn.jsdelivr.net/npm/geolite2-city/GeoLite2-City.mmdb.gz
gunzip GeoLite2-City.mmdb.gz
mv GeoLite2-City.mmdb /tmp/city.mmdb 

sudo rm -f /var/lib/docker/volumes/heiDPI_tmp/_data/nDPIsrvd-daemon-distributor.sock
sudo rm -f /var/lib/docker/volumes/heiDPI_tmp/_data/nDPIsrvd-daemon-collector.sock

sudo docker run --name heiDPI_producer \
--mount type=volume,src=heiDPI_var_log,dst=/var/log \
--mount type=volume,src=heiDPI_tmp,dst=/tmp \
-d -p 127.0.0.1:7000:7000 --net host stefan96/heidpi-producer:main

sudo docker run --name heiDPI_consumer \
-e SHOW_ERROR_EVENTS=1 -e SHOW_DAEMON_EVENTS=1 -e SHOW_PACKET_EVENTS=1 -e SHOW_FLOW_EVENTS=1 \
--mount type=volume,src=heiDPI_var_log,dst=/var/log \
--mount type=volume,src=heiDPI_tmp,dst=/tmp \
--mount type=bind,src="$ABSOLUTE_PATH_CONFIG",dst=/usr/src/app/config.yml \
--mount type=bind,src=/tmp/city.mmdb,dst=/tmp/city.mmdb \
-d -e HOST=127.0.0.1 --net host stefan96/heidpi-consumer:main
