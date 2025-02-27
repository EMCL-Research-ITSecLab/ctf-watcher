#!/bin/bash
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
--mount type=bind,src=/home/fdaas/heiDPI_config.yml,dst=/usr/src/app/config.yml \
--mount type=bind,src=/tmp/city.mmdb,dst=/tmp/city.mmdb \
-d -e HOST=127.0.0.1 --net host stefan96/heidpi-consumer:main

