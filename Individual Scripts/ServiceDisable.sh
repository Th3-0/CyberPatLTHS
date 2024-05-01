#!/bin/bash

services=("ftp" "nginx" "vpn" "snmp" "telnet")

for (( i=0; i<${#services[@]}; i++ ));
do
    service --status-all | grep ${services[i]} >> service.txt
done