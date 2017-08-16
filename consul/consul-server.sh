#!/bin/bash
docker stop consul
docker rm consul
docker run -d \
	-e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' \
	--name consul \
	--publish 188.93.21.146:8500:8500 \
	--publish 0.0.0.0:8501:8500 \
	-h consul \
	--restart always \
	progrium/consul \
	consul agent \
	-client=188.93.21.146 \
	-node=consul \
	-encrypt="zCawwRq6P/NTUNX1j3HMeQ==" \
	-server \
        -bootstrap \
	-ui-dir /ui \
	-ui \
	-config-dir=/consul/config

echo "==== pausing ===="
sleep 2

docker cp /home/alex/docker/consul/acl.json consul:/consul/config/acl.json

#docker run -d --name=consul0 \
#        -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' \
#        consul agent \
#        -server \
#        -node=consul0 \
#        -encrypt=$KEY \
#        -advertise-wan=46.39.225.69 \
#        -advertise-wan=46.254.18.198 \
#        -retry-join-wan=46.39.225.69:20526 \
#        -retry-join-wan=46.254.18.198:20526 \
#        -bootstrap \
#        -config-dir=/consul/config

#CONSUL0=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' consul0)

#echo "==== starting agent ===="
#docker run -d --name=agent0 \
#        -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' \
#        -p 8500:8500 \
#        -p $DOCKER_IP:20526:8300/udp \
#        -p $DOCKER_IP:20526:8300/tcp \
#        -p $DOCKER_IP:20926:8302/udp \
#        -p $DOCKER_IP:20926:8302/tcp \
#        -p $DOCKER_IP:53:8600/tcp \
#        -p $DOCKER_IP:53:8600/udp \
#        consul agent \
#        -node=agent0 \
#        -encrypt=$KEY \
#        -client=0.0.0.0 \
#        -advertise-wan=46.39.225.69 \
 #       -advertise-wan=46.254.18.198 \
#        -serf-wan-bind=$DOCKER_IP \
#        -retry-join=$CONSUL0 \
#        -retry-join=46.254.18.198 \
#        -ui
#
