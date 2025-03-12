#!/bin/bash
GRAFANA_URL="http://localhost:3000"
GRAFANA_USERNAME="admin"
GRAFANA_PASSWORD="admin"
DASHBOARD_JSON="wazuh_dashboard.json"
DATASOURCE_JSON="wazuh_datasource.json"


curl -v -X POST "$GRAFANA_URL/api/dashboards/db" \
  -u "$GRAFANA_USERNAME:$GRAFANA_PASSWORD" \
  -H "Content-Type: application/json" \
  -d @$DASHBOARD_JSON

curl -X POST http://localhost:3000/api/datasources \
  -u "$GRAFANA_USERNAME:$GRAFANA_PASSWORD" \ 
  -H "Content-Type: application/json" \
  -d @DATASOURCE_JSON

