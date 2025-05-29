#!/bin/bash

function print_divider () {
    columns=$(tput cols)
    printf "%${columns}s\n" | tr " " "-"
}

echo ""
echo "Enter Dashbaord UID:"
read DASHBOARD_UID


echo "Print Dashboard Json"
print_divider
curl -u "admin:admin" -X GET "http://localhost:3000/api/dashboards/uid/$DASHBOARD_UID" > new_dashboard.json
echo ""
print_divider
DATASOURCE_WAZUH_UID=$(curl -X GET "http://localhost:3000/api/datasources/1" -u admin:admin 2>/dev/null | grep -o '"uid":"[^"]*' | sed 's/"uid":"//')
echo "Datasource wazuh uid $DATASOURCE_WAZUH_UID"
sed -i 's/ee5oyzl487bwga/<wazuh_ip>/g' new_dashboard.json
