#!/bin/bash
echo "ECS_CLUSTER=${CLUSTER_NAME}" >> /etc/ecs/ecs.config

# For ECS to properly deregister the container instance from
# the cluster when the instance is terminated a SIGTERM is sent
# to the task followed by a SIGKILL after the stop timeout.
# Decreasing the default timeout value of 30 seconds allows
# for faster instance termination.
echo "ECS_CONTAINER_STOP_TIMEOUT=5" >> /etc/ecs/ecs.config

# ECS agent will pull the latest image one time and cache it for
# re-use between similar tasks. The default behavior is to always
# attempt a pull and use cache only on failure. This causes unneeded
# requests taking 10-20 seconds.
echo "ECS_IMAGE_PULL_BEHAVIOR=once" >> /etc/ecs/ecs.config