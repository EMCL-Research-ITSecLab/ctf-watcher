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
  print "Wait for Grafana. If this takes longer than a minute something went wrong and the programm exits"
  local wait_time_ds=600
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

  echo ""
  print "Grafana not correctly installed, not set up or error in updloading datasource"
  
  print "Status:"
  echo "$GRAFANA_HEALTH"
  exit 1
}

print()
{
echo ""
echo $1
echo ""
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
  print "Set up Grafana Dashboard with these settings? [y/yes]"
  read SET_UP_APPROVED
fi
if [ "$SET_UP_APPROVED" != "y" ] && [ "$SET_UP_APPROVED" != "yes" ]; then
  print "Setup Aborted"
  exit 0
fi

print "Start set up  Grafana Dashboard"
print "Set Wazuh Manager Datasource ip address"

sed -i "s/ \"url\": \"https:\/\/<wazuh_manager_ip>:9200\",/ \"url\": \"https:\/\/$MANAGER_IP_ADDRESS:$MANAGER_PORT\",/" config/wazuh_datasource.json

print "Set cAdvisor Datasource ip address"
sed -i "s/ \"url\": \"https:\/\/<cadvisor_ip>:9090\",/ \"url\": \"https:\/\/$CADVISOR_IP_ADDRESS:$CADVISOR_PORT\",/" config/cadvisor_datasource.json


print "Run Docker Grafana Dashbaord"

docker run -d -p 3000:3000 --name=grafana grafana/grafana-enterprise

wait_for_grafana

print "Upload Wazuh Datasource"

curl -X POST "$GRAFANA_URL/api/datasources" \
  -u "$GRAFANA_USERNAME:$GRAFANA_PASSWORD" \
  -H "Content-Type: application/json" \
  -d @$DATASOURCE_WAZUH_JSON

print "Upload cAdvisor Datasource"

curl -X POST "$GRAFANA_URL/api/datasources" \
  -u "$GRAFANA_USERNAME:$GRAFANA_PASSWORD" \
  -H "Content-Type: application/json" \
  -d @$DATASOURCE_CADVISOR_JSON

print "Get Wazuh Datasource uid"
##Get The uid Grafana assigned to the new datasource and replace the old uid in DASHBOARD_WAZUH_JSON so the Dashboard is connected to the datasource  
DATASOURCE_WAZUH_UID=$(curl -X GET "http://localhost:3000/api/datasources/1" -u admin:admin 2>/dev/null | grep -o '"uid":"[^"]*' | sed 's/"uid":"//')
echo "uid: $DATASOURCE_WAZUH_UID"
sed 's/"uid": "\${DS_WAZUH-2}"/"uid": "'$DATASOURCE_WAZUH_UID'"/' $DASHBOARD_WAZUH_JSON > temp.json && mv temp.json $DASHBOARD_WAZUH_JSON

print "Get cAdvisor Datasource uid"
##Get The uid Grafana assigned to the new datasource and replace the old uid in DASHBOARD_WAZUH_JSON so the Dashboard is connected to the datasource  
DATASOURCE_CADVISOR_UID=$(curl -X GET "http://localhost:3000/api/datasources/2" -u admin:admin 2>/dev/null | grep -o '"uid":"[^"]*' | sed 's/"uid":"//')
echo "uid: $DATASOURCE_CADVISOR_UID"
sed -i "s/<cadvisor_ip>/$CADVISOR_IP_ADDRESS:$CADVISOR_PORT/g" "$DASHBOARD_CADVISOR_JSON"

print "Upload Wazuh Dashboard"

curl -v -X POST "$GRAFANA_URL/api/dashboards/db" \
  -u "$GRAFANA_USERNAME:$GRAFANA_PASSWORD" \
  -H "Content-Type: application/json" \
  -d @$DASHBOARD_WAZUH_JSON


print "Upload cAdvisor Dashboard"

curl -v -X POST "$GRAFANA_URL/api/dashboards/db" \
  -u "$GRAFANA_USERNAME:$GRAFANA_PASSWORD" \
  -H "Content-Type: application/json" \
  -d @$DASHBOARD_CADVISOR_JSON

print "Grafana setup complete"
echo "Grafana Dashboard: https://$LOCAL_IP_ADDRESS:3000"
echo "User: Admin"
echo "Password: Admin"
