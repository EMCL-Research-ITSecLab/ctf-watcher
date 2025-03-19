#!/bin/bash
GRAFANA_URL="http://localhost:3000"
GRAFANA_PASSWORD="admin"
GRAFANA_USERNAME="admin"
DASHBOARD_JSON="config/wazuh_dashboard.json"
DATASOURCE_JSON="config/wazuh_datasource.json"

curl -X POST "$GRAFANA_URL/api/datasources" \
  -u "$GRAFANA_USERNAME:$GRAFANA_PASSWORD" \
  -H "Content-Type: application/json" \
  -d @$DATASOURCE_JSON

##Get The uid Grafana assigned to the new datasource and replace the old uid in DASHBOARD_JSON so the Dashboard is connected to the datasource  
DATASOURCE_UID=(curl -X GET "http://localhost:3000/api/datasources/1" -u admin:admin 2>/dev/null | grep -o '"uid":"[^"]*' | sed 's/"uid":"//')
sed 's/"uid": "\${DS_WAZUH-2}"/"uid": "'$DATASOURCE_UID'"/' $DASHBOARD_JSON > temp.json && mv temp.json $DASHBOARD_JSON

curl -v -X POST "$GRAFANA_URL/api/dashboards/db" \
  -u "$GRAFANA_USERNAME:$GRAFANA_PASSWORD" \
  -H "Content-Type: application/json" \
  -d @$DASHBOARD_JSON


