#!/bin/bash
ABSOLUTE_PATH_CONFIG=$(realpath heiDPI_config.yml)

curl -O https://cdn.jsdelivr.net/npm/geolite2-city/GeoLite2-City.mmdb.gz
gunzip GeoLite2-City.mmdb.gz
mkdir -p /var/lib/GeoLite2/
mv GeoLite2-City.mmdb /var/lib/GeoLite2/city.mmdb 

sed -i "s|<config_absolute_path>|$ABSOLUTE_PATH_CONFIG|g" docker-compose.yaml

docker compose -p heidpi -f docker-compose.yaml up -d
