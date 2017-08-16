#!/bin/bash
docker run -d \
	--name portainer \
	--publish 9000:9000 \
	--restart always \
	-v /var/run/docker.sock:/var/run/docker.sock \
	portainer/portainer \
	--admin-password '$2y$05$WhuX/As7Z4h2ZVR2IOHvietwcDdOFoTvD3ypvBQl/dHCEoLMyfJBC'
