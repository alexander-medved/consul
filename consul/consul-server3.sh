#!/bin/bash
docker stop {node0,agent0}
docker rm {node0,agent0}
echo "==== creating encryption key ===="
KEY="z*"
export HOST_IP=$(ifconfig eno2 | grep 'inet ' |  cut -d: -f2 | awk '{ print $2 }')
export DOCKER_BRIDGE_IP=$(ifconfig docker0 | grep 'inet ' |  cut -d: -f2 | awk '{ print $2 }')

echo "==== creating server ===="
docker run -d -h $HOSTNAME --name=node0 -v /mnt:/data \
        -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' \
        -p $HOST_IP:20526:8301/udp \
        -p $HOST_IP:20526:8301/tcp \
	consul agent -server -node node0 -encrypt $KEY -advertise $HOST_IP \
        -advertise-wan=$HOST_IP \
        -retry-join-wan=*.*.*.*:20526 \
        -retry-join-wan=*.*.*.*:20526 \
        -bootstrap 
export NODE0_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' node0)

echo "==== starting agent ===="
docker run -d -h $HOSTNAME --name=agent0 \
        -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' \
        -p $HOST_IP:8500:8500 \
	-p $HOST_IP:20926:8302/udp \
        -p $HOST_IP:20926:8302/tcp \
        -p $HOST_IP:53:8600/tcp \
        -p $HOST_IP:53:8600/udp \
        consul agent \
        -node=agent0 \
        -encrypt=$KEY \
	-advertise $HOST_IP \
        -client=0.0.0.0 \
        -advertise-wan=$HOST_IP \
        -serf-wan-bind=$HOST_IP \
        -retry-join=$NODE0_IP \
	-ui-dir /ui
echo "==== pausing ===="
sleep 2

echo "==== docker processes ===="
docker ps --format "table {{ .Names }}\t{{ .Status }}\t{{ .Ports }}"

echo "==== consul members ===="
docker exec -t node0 consul members

echo "==== consul node catalog ===="
curl $HOST_IP:8500/v1/catalog/nodes?pretty

echo "==== consul agent location ===="
echo "http://$HOST_IP:8500"

