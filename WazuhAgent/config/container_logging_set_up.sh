#!/bin/bash

EXCLUDED_IMAGES=("grafana" "prom" "gcr.io" "stefan96/heidpi" "wazuh" "openvpn")
function is_excluded_image() {
  for prefix in "${EXCLUDED_IMAGES[@]}"; do
    if [[ "$1" == "$prefix"* ]]; then
      return 0
    fi
  done
  return 1
}
function print_info()
{
echo ""
echo -e "\e[34m[Info]:\e[0m  $SET_UP_STEP_MAIN: $SET_UP_STEP_SUB:\e[2m $1\e[0m"
echo ""
}

print_info "Create /wazuh-agent directory in containers...  1/4"
for container_id in $(docker ps -q); do
  IMAGE_NAME=$(docker inspect --format='{{.Config.Image}}' "$container_id")
  if is_excluded_image "$IMAGE_NAME"; then
    continue
  fi
  docker exec "$container_id" sh -c "mkdir -p /wazuh-agent"
done



print_info "Copy set up scripts into containers...  2/4"
for container_id in $(docker ps -q); do
  IMAGE_NAME=$(docker inspect --format='{{.Config.Image}}' "$container_id")
  if is_excluded_image "$IMAGE_NAME"; then
    continue
  fi
  docker cp config/container_requirements_set_up.sh "$container_id":/wazuh-agent/
  docker cp config/bash_loggin_set_up.sh "$container_id":/wazuh-agent/
done

print_info "Install requirements on containers...  3/4"
pids=()
for container_id in $(docker ps -q); do
  IMAGE_NAME=$(docker inspect --format='{{.Config.Image}}' "$container_id")
  if is_excluded_image "$IMAGE_NAME"; then
    continue
  fi
  docker exec "$container_id" sh -c "/wazuh-agent/container_requirements_set_up.sh" &
  pids+=($!)
done
for pid in "${pids[@]}"; do
  wait "$pid"
done

print_info "Set up bash logging in containers...  4/4"
for container_id in $(docker ps -q); do
  IMAGE_NAME=$(docker inspect --format='{{.Config.Image}}' "$container_id")
  if is_excluded_image "$IMAGE_NAME"; then
    CONTAINER_NAME=$(docker inspect --format='{{.Name}}' "$container_id" | sed 's/^\/\?//')
    echo -e "\e[34m[Info]:\e[0m $CONTAINER_NAME: Bash logging set up \e[33m[Skipped]\e[0m: \e[2m(Image is Excluded: $IMAGE_NAME)\e[0m"
    continue
  fi
  docker exec "$container_id" sh -c "/wazuh-agent/bash_loggin_set_up.sh --privat_log=/wazuh-agent/commands.log"
done
