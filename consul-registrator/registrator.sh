#!/bin/bash
docker run -d \
	--name registrator \
	--restart always \
	--net=host \
	--volume=/var/run/docker.sock:/tmp/docker.sock \
	gliderlabs/registrator:latest \
	-resync=0 -ip="188.93.21.146" -tags="NODE01" consul://localhost:8500
