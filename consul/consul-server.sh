#!/bin/bash
docker stop consul
docker rm consul
docker run -d \
	-e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' \
	--name consul \
	--publish <host_ip>:8500:8500 \
	--publish 0.0.0.0:8501:8500 \
	-h consul \
	--restart always \
	progrium/consul \
	consul agent \
	-client=0.0.0.0 \
	-node=consul \
	-encrypt="z*" \
	-server \
        -bootstrap \
	-ui-dir /ui \
	-ui \
	-config-dir=/consul/config

echo "==== pausing ===="
sleep 2

docker cp /home/alex/docker/consul/acl.json consul:/consul/config/acl.json
