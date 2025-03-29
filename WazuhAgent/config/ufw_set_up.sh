#!/bin/bash

ufw enable

ufw allow 22/tcp

ufw allow 443/tcp

ufw allow 1514/tcp

ufw allow 1514/udp
ufw allow 1515/tcp

ufw allow 7000/tcp
ufw allow 7000/udp

ufw allow 8080/tcp
ufw allow 8080/udp

ufw allow 9090/tcp
ufw allow 9090/udp

ufw allow 9200/tcp
