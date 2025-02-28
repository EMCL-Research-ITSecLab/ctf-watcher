FROM nginx

COPY config /usr
COPY wazuh-docker /usr

EXPOSE 5601/tcp
EXPOSE 5601/udp 

CMD ["docker-compose", "up", "-d"]
