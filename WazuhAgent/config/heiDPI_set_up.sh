#!/bin/bash
ABSOLUTE_PATH_CONFIG=$(realpath heiDPI_config.yml)

function print_info()
{
echo ""
echo -e "\e[34m[Info]:\e[0m  $SET_UP_STEP_MAIN: $SET_UP_STEP_SUB:\e[2m $1"
echo ""
}

print_info "Get Geolite2-City.mmdb...  1/3"
curl -O https://cdn.jsdelivr.net/npm/geolite2-city/GeoLite2-City.mmdb.gz
gunzip GeoLite2-City.mmdb.gz
mkdir -p /var/lib/GeoLite2/
mv GeoLite2-City.mmdb /var/lib/GeoLite2/city.mmdb 

print_info "Set heiDPI config file...  2/3"
sed -i "s|<config_absolute_path>|$ABSOLUTE_PATH_CONFIG|g" docker-compose.yaml

print_info "Compose heiDPI Docker...  3/3"
docker compose -p heidpi -f docker-compose.yaml up -d
