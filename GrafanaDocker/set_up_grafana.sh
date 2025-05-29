#!/bin/bash
GRAFANA_URL="http://localhost:3000"
LOCAL_IP_ADDRESS=$(hostname -I | awk '{print $1}')
MANAGER_IP_ADDRESS="$LOCAL_IP_ADDRESS"
MANAGER_PORT="9200"
CADVISOR_IP_ADDRESS="$LOCAL_IP_ADDRESS"
CADVISOR_PORT="9090"
GRAFANA_PASSWORD="admin"
GRAFANA_USERNAME="admin"
DASHBOARD_WAZUH_JSON="config/wazuh_dashboard.json"
DASHBOARD_CADVISOR_JSON="config/cadvisor_dashboard.json"
DASHBOARD_COMMANDS_JSON="config/commands_dashboard.json"
DATASOURCE_WAZUH_JSON="config/wazuh_datasource.json"
DATASOURCE_CADVISOR_JSON="config/cadvisor_datasource.json"
SKIP_CONFIRMATION="false"
HELP="
set_up_grafana.sh -h

Usage: set_up_grafana.sh [OPTIONS]

    --manager=<ip_address>         [Optional] Set the Wazuh Manager ip address this Grafana dashboard should get data from.
                                   [Default] = localhost

    --manager_port=<port>          [Optional] Set the Wazuh Manager API port.
                                   [Default] = 9200

    --cadvisor=<ip_address>        [Optional] Set the cAdvisor Prometheus ip address this Grafana dashboard should get data from.
                                   [Default] = localhost

    --cadvisor_port=<port>         [Optional] Set the cAdvisor Prometheus API port.
                                   [Default] = 9090

    --remove                       [Optional] Remove the installed Grafana Dashboard.

    -y, --yes                      [Optional] Skip Set Up Confirmation.

    -h, --help                     [Optional] Show this help.
"

delete_grafana()
{
  echo "Deleting not implemented"
}
is_grafana_responding()
{
  GRAFANA_HEALTH=$(curl -s -u "$GRAFANA_USERNAME:$GRAFANA_PASSWORD" "$GRAFANA_URL/api/health" 2>/dev/null)
  if [ "$GRAFANA_HEALTH" == "" ]; then
    return 1
  else
    return 0
  fi
}
wait_for_grafana() {
  print_info "[3/] Wait for Grafana Responce"
  echo "If this lasts too long, something went wrong and the program exits."
  local wait_time_ds=2400
  local current=0
  local progress
  local start_time=$(date +%s)  
  local bar_length=50 

  while [ $current -le $wait_time_ds ]; do
    progress=$((current * bar_length / wait_time_ds))
    bar=$(printf "%0.s=" $(seq 1 $progress)) 
    spaces=$(printf "%0.s " $(seq 1 $((bar_length - progress))))
        
    local elapsed_time=$(( $(date +%s) - start_time ))
    local minutes=$((elapsed_time / 60))
    local seconds=$((elapsed_time % 60))
    
    printf "\r[${bar}${spaces}] %02d:%02d" $minutes $seconds

    sleep 0.1
    
    is_grafana_responding
   
    IS_GRAFANA_RUNNING=$?
    if [ "$IS_GRAFANA_RUNNING" == "0" ]; then
        return
    fi  
   
    ((current++))
  done

  print_warning "Grafana Boot Up took longer than expected."
  echo ""
  echo "Grafana Responce:"
  echo "$GRAFANA_HEALTH"
  echo ""
  echo "Wait longer? <y/yes> "
  read WAIT_APPROVED
  if [ "$WAIT_APPROVED" != "y" ] && [ "$WAIT_APPROVED" != "yes" ]; then
      section_header "Grafana Setup Aborted"
      exit 1
  fi
  
  wait_for_grafana || {exit 1}
}

function print_info()
{
echo ""
echo -e "\e[34m[Info]:\e[0m $SET_UP_STEP_MAIN |  $1"
echo ""
}

function print_warning()
{
echo ""
echo -e "\e[33m[Warn]:\e[0m $SET_UP_STEP_MAIN | $1"
echo ""
}

function print_error()
{
echo ""
echo -e "\e[31m[Error]:\e[0m $SET_UP_STEP_MAIN | $1"
echo ""
}
function print_divider () {
    terminal=/dev/pts/1
    columns=$(stty -a <"$terminal" | grep -Po '(?<=columns )\d+')
    printf "%${columns}s\n" | tr " " "-"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --manager=*)
      MANAGER_IP_ADDRESS="${1#*=}"
      ;;
    --manager_port=*)
      MANAGER_PORT="${1#*=}"
      ;;
    --cadvisor=*)
      CADVISOR_IP_ADDRESS="${1#*=}"
      ;;
    --cadvisor_port=*)
      CADVISOR_PORT="${1#*=}"
      ;;
    --remove)
      delete_grafana
      exit 0
      ;;
    -y|--yes)
      SKIP_CONFIRMATION="true"
      ;;
    -h|--help)
      echo "$HELP"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
  shift
done

echo "Set up Grafana Dashboard"
echo "Grafana Dashboard: $LOCAL_IP_ADDRESS"
echo "Wazuh Manager Ip: $MANAGER_IP_ADDRESS"
echo "Wazuh Manager Port: $MANAGER_PORT"

SET_UP_APPROVED="y"
if [ "$SKIP_CONFIRMATION" == "false" ]; then
  echo "Set up Grafana Dashboard with these settings? [y/yes]"
  read SET_UP_APPROVED
fi
if [ "$SET_UP_APPROVED" != "y" ] && [ "$SET_UP_APPROVED" != "yes" ]; then
  print_info "Setup Aborted"
  exit 0
fi

print_info "Start set up  Grafana Dashboard"
print_info "[1/] Set the Datasources' IP addresses."

sed -i "s/ \"url\": \"https:\/\/<wazuh_manager_ip>:9200\",/ \"url\": \"https:\/\/$MANAGER_IP_ADDRESS:$MANAGER_PORT\",/" config/wazuh_datasource.json
sed -i "s/<cadvisor_ip>/$CADVISOR_IP_ADDRESS/g" config/cadvisor_datasource.json


print_info "[2/] Start Grafana Docker"

docker run -d --restart unless-stopped -p 3000:3000 --name=grafana grafana/grafana-enterprise

wait_for_grafana

print_info "[4/] Upload Datasources"

curl -X POST "$GRAFANA_URL/api/datasources" \
  -u "$GRAFANA_USERNAME:$GRAFANA_PASSWORD" \
  -H "Content-Type: application/json" \
  -d @$DATASOURCE_WAZUH_JSON

curl -X POST "$GRAFANA_URL/api/datasources" \
  -u "$GRAFANA_USERNAME:$GRAFANA_PASSWORD" \
  -H "Content-Type: application/json" \
  -d @$DATASOURCE_CADVISOR_JSON

print_info "[5/] Request Datasources UID"
##Get the UID Grafana assigned to the new Wazuh datasource 
echo "Get Wazuh Datasource uid"
DATASOURCE_WAZUH_UID=$(curl -X GET "http://localhost:3000/api/datasources/1" -u admin:admin 2>/dev/null | grep -o '"uid":"[^"]*' | sed 's/"uid":"//')
echo "Wazuh UID: $DATASOURCE_WAZUH_UID"

##Get the UID Grafana assigned to the new cAdvisor datasource 
echo "Get cAdvisor Datasource uid"
DATASOURCE_CADVISOR_UID=$(curl -X GET "http://localhost:3000/api/datasources/2" -u admin:admin 2>/dev/null | grep -o '"uid":"[^"]*' | sed 's/"uid":"//')
echo "cAdvisor UID: $DATASOURCE_CADVISOR_UID"

print_info "[6/] Set Datasource UID in Dashboards"

sed -i "s/\${DS_CADVISOR}/$DATASOURCE_CADVISOR_UID/g" "$DASHBOARD_WAZUH_JSON"
sed -i "s/\${DS_WAZUH-2}/$DATASOURCE_CADVISOR_UID/g" "$DASHBOARD_WAZUH_JSON"

sed -i "s/\${DS_CADVISOR}/$DATASOURCE_CADVISOR_UID/g" "$DASHBOARD_CADVISOR_JSON"
sed -i "s/\${DS_WAZUH-2}/$DATASOURCE_CADVISOR_UID/g" "$DASHBOARD_CADVISOR_JSON"

sed -i "s/\${DS_CADVISOR}/$DATASOURCE_CADVISOR_UID/g" "$DASHBOARD_COMMANDS_JSON"
sed -i "s/\${DS_WAZUH-2}/$DATASOURCE_CADVISOR_UID/g" "$DASHBOARD_COMMANDS_JSON"

print_info "[7/] Upload Dashboard"
echo "Upload Wazuh Dashboard"
print_divider

curl -v -X POST "$GRAFANA_URL/api/dashboards/db" \
  -u "$GRAFANA_USERNAME:$GRAFANA_PASSWORD" \
  -H "Content-Type: application/json" \
  -d @$DASHBOARD_WAZUH_JSON

print_divider
echo ""


echo "Upload cAdvisor Dashboard"
print_divider

curl -v -X POST "$GRAFANA_URL/api/dashboards/db" \
  -u "$GRAFANA_USERNAME:$GRAFANA_PASSWORD" \
  -H "Content-Type: application/json" \
  -d @$DASHBOARD_CADVISOR_JSON

print_divider
echo ""

echo "Upload Commands Dashboard"
print_divider

curl -v -X POST "$GRAFANA_URL/api/dashboards/db" \
  -u "$GRAFANA_USERNAME:$GRAFANA_PASSWORD" \
  -H "Content-Type: application/json" \
  -d @$DASHBOARD_COMMANDS_JSON

print_divider
echo ""

echo
echo -e "$SET_UP_STEP_MAIN: Grafana Installation Finished!"
echo

echo "Grafana Dashboard: http://$LOCAL_IP_ADDRESS:3000"
echo "User: admin"
echo "Password: admin"
