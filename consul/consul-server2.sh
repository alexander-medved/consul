#!/bin/bash
docker stop {consul0,consul1,consul2,agent0,registrator}
docker rm {consul0,consul1,consul2,agent0}

SERVER_COUNT=3
#eval $(docker-machine env default)
DOCKER_IP=$(ifconfig eno2 | grep 'inet ' |  cut -d: -f2 | awk '{ print $2 }')

echo "==== creating encryption key ===="
KEY="z*"

echo "==== starting servers ===="
docker run -d --name=consul0 \
	-e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' \
	-e 'CONSUL_LOCAL_CONFIG={"translate_wan_addrs" : true}' \
	-p 8301:8301/udp \
        -p 8301:8301 \
        -p 8302:8302/udp \
        -p 8302:8302 \
	-p 8400:8400 \
        -p 8600:8600 \
        -p 8600:8600/udp \
	consul agent \
	-server \
	-node=consul0 \
	-datacenter=office-msk \
	-encrypt=$KEY \
        -advertise-wan=$DOCKER_IP \
	-retry-join-wan=*.*.*.*:20526 \
	-retry-join-wan=*.*.*.*:20526 \
	-bootstrap \
	-config-dir=/consul/config 

CONSUL0=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' consul0)

for ((i=1; i<SERVER_COUNT; i++))
do
docker run -d --name=consul$i \
-e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' \
consul agent \
-server \
-node=consul$i \
-datacenter=office-msk \
-encrypt=$KEY \
-retry-join=$CONSUL0
done

echo "==== starting agent ===="
docker run -d --name=agent0 \
	-e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' \
	-p 8500:8500 \
	-p $DOCKER_IP:20526:8301/udp \
        -p $DOCKER_IP:20526:8301 \
        -p $DOCKER_IP:20926:8302/udp \
        -p $DOCKER_IP:20926:8302 \
	-p $DOCKER_IP:53:8600 \
        -p $DOCKER_IP:53:8600/udp \
	consul agent \
	-node=agent0 \
	-datacenter=office-msk \
	-encrypt=$KEY \
	-client=0.0.0.0 \
        -advertise-wan=$DOCKER_IP \
	-retry-join=$CONSUL0 \
	-ui
echo "==== pausing ===="
sleep 2

echo "==== copyeing configs to containers ===="
docker cp /home/alex/docker/consul/acl_srv.json consul0:/consul/config/acl.json
docker cp /home/alex/docker/consul/acl_srv1.json consul1:/consul/config/acl.json
docker cp /home/alex/docker/consul/acl_srv2.json consul2:/consul/config/acl.json
docker cp /home/alex/docker/consul/acl.json agent0:/consul/config/acl.json

echo "==== restarting containers  ===="
docker restart {consul0,consul1,consul2,agent0,registrator}

sleep 2

echo "==== docker processes ===="
docker ps --format "table {{ .Names }}\t{{ .Status }}\t{{ .Ports }}"

echo "==== consul members ===="
docker exec -t consul0 consul members

echo "==== consul node catalog ===="
curl $DOCKER_IP:8500/v1/catalog/nodes?pretty

echo "==== consul agent location ===="
echo "http://$DOCKER_IP:8500"
