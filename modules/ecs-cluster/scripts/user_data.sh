#!/bin/bash
echo "ECS_CLUSTER=${CLUSTER_NAME}" >> /etc/ecs/ecs.config

# ECS agent will wait for 10 minutes before deleting the old
# stopped tasks that remain on the container instance.
echo "ECS_ENGINE_TASK_CLEANUP_WAIT_DURATION=10m" >> /etc/ecs/ecs.config

# For ECS to properly deregister the container instance from
# the cluster when the instance is terminated a SIGTERM is sent
# to the task followed by a SIGKILL after the stop timeout.
# Decreasing the default timeout value of 30 seconds allows
# for faster instance termination.
echo "ECS_CONTAINER_STOP_TIMEOUT=5s" >> /etc/ecs/ecs.config

# ECS agent will wait for 1 minute before timing out on container
# startup. This is to allow the container to download the image
# and start up.
echo "ECS_CONTAINER_START_TIMEOUT=1m" >> /etc/ecs/ecs.config

# ECS agent will wait for timeout before giving up on creating a container.
echo "ECS_CONTAINER_CREATE_TIMEOUT=1m" >> /etc/ecs/ecs.config

# ECS agent will pull the latest image one time and cache it for
# re-use between similar tasks. The default behavior is to always
# attempt a pull and use cache only on failure. We are staying
# with this behavior because if the same tag is updated in
# the repository, the ECS agent will not pull the new image.
# (i.e when staging tag is updated)
echo "ECS_IMAGE_PULL_BEHAVIOR=default" >> /etc/ecs/ecs.config
