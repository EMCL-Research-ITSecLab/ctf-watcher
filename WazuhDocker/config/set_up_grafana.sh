#!/bin/bash
GRAFANA_URL="http://localhost:3000"
GRAFANA_PASS="admin"
DASHBOARD_JSON="wazuh_dashboard.json"


curl -X POST "$GRAFANA_URL/api/dashboards/db" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $GRAFANA_API_KEY" \
  -d @$DASHBOARD_JSON
