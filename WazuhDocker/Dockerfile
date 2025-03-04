FROM ubuntu

COPY config /usr


EXPOSE 5601/tcp
EXPOSE 5601/udp 
EXPOSE 9200/tcp
EXPOSE 9200/udp

RUN bash /usr/wazuh-install.sh --generate-config-files
RUN bash /usr/wazuh-install.sh --wazuh-indexer node-1
RUN bash /usr/wazuh-install.sh --start-cluster
RUN curl -k -u admin:$(tar -axf wazuh-install-files.tar wazuh-install-files/wazuh-passwords.txt -O | grep -P "\'admin\'" -A 1) https://10.20.30.57:9200
RUN curl -k -u admin:$(tar -axf wazuh-install-files.tar wazuh-install-files/wazuh-passwords.txt -O | grep -P "\'admin\'" -A 1) https://10.20.30.57:9200/_cat/nodes?v
