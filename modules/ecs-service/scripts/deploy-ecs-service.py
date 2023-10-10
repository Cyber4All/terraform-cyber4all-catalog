#!/usr/bin/env python3

import argparse
import time
import boto3
import logging
import re
import sys

logger = logging.getLogger(__name__)
logging.StreamHandler(sys.stdout)
logging.basicConfig(level=logging.INFO, format='[%(levelname)s] %(asctime)s - %(message)s', datefmt='%Y-%m-%d %H:%M:%S')


def parseArguments() -> argparse.Namespace:
    """Parse CLI arguments and validate them.

    Raises:
        Exception: If any of the arguments are invalid.

    Returns:
        argparse.Namespace: The parsed CLI arguments.
    """
    parser = argparse.ArgumentParser(description="Deploy a new docker image tag to an existing ECS service.")

    # Required arguments
    parser.add_argument("-c", "--cluster", required=True, help="The name of the ECS cluster.")
    parser.add_argument("-i", "--image", required=True, help="The image:tag to deploy to the service. The image must exist in the DockerHub registry.")
    parser.add_argument("-s", "--service",required=True, help="This is the name of the ECS service that will be updated.")

    # Optional arguments
    parser.add_argument("-r", "--region", required=False, default="us-east-1", help="The AWS region where the ECS cluster exists.")
    parser.add_argument("-t", "--timeout", required=False, default=1200, type=int, help="The number of seconds to wait to update the service. Default is 1200 seconds (20 minutes).")

    args = parser.parse_args()

    # The cluster name can have up to 255 characters, and can only contain alphanumeric characters,
    # hyphens, and underscores.
    if not isAlNumHyphenUnderscore(args.cluster) or len(args.cluster) > 255:
        raise Exception("The ECS cluster name cannot be longer than 255 characters and can only contain alphanumeric characters, hyphens, and underscores.")
    
    # The image name can have up to 255 characters, and can only contain alphanumeric characters, 
    # hyphens, underscores, colons, periods, forward slashes, and number signs.
    if not re.match("^[a-zA-Z0-9-_:./#]+$", args.image) or len(args.image) > 255:
        raise Exception("The ECS image name cannot be longer than 255 characters, and can only contain alphanumeric characters, hyphens, underscores, colons, periods, forward slashes, and number signs.")
    
    # The service name can have up to 255 characters, and can only contain alphanumeric characters,
    # hyphens, and underscores.
    if args.service and (not isAlNumHyphenUnderscore(args.service) or len(args.service) > 255):
        raise Exception("The ECS service name cannot be longer than 255 characters and can only contain alphanumeric characters, hyphens, and underscores.")

    # The region must be from the authorized list of regions.
    if args.region not in ["us-east-1", "us-east-2", "us-west-1", "us-west-2"]:
        raise Exception("The region must be one of the following: us-east-1, us-east-2, us-west-1, us-west-2")
    
    # Timeout must be greater than 0.
    if args.timeout <= 0:
        raise Exception("The timeout must be greater than 0.")
    
    return args


def isAlNumHyphenUnderscore(string) -> bool:
    """Return True if string is alphanumeric, hyphen, or underscore.

    Args:
        string (_type_): the string to validate

    Returns:
        bool: True if string is alphanumeric, hyphen, or underscore. False otherwise.
    """
    pattern = "^[a-zA-Z0-9-_]+$"
    return re.match(pattern, string)


def getCurrentTaskDefinition(client: any, cluster: str, service: str) -> (dict, str):
    """Get the currently deployed task definition in the service.

    Args:
        client (boto3.ECS.Client): the low level boto3 ECS client
        cluster (str): the name of the ECS cluster
        service (str): the name of the ECS service

    Raises:
        Exception: if the service does not exist in the cluster
        Exception: if more than one service was found in the cluster with the same name

    Returns:
        (dict, str): the currently deployed task definition, and image
    """

    res = client.describe_services(
        cluster=cluster,
        services=[service]
    )

    # Assert that the service exists in the cluster
    if len(res['services']) == 0:
        raise Exception("The service does not exist in the cluster")
    elif len(res['services']) > 1:
        raise Exception("More than one service was found in the cluster with the same name")
    logger.info(f"Service {service} found in {cluster} cluster")
    
    # Log the current task definition
    current_task_definition = res['services'][0]['taskDefinition']
    logger.info(f"Active task definition: {current_task_definition}")

    # Log the last deployment time
    last_deployment_time = res['services'][0]['deployments'][0]['createdAt']
    latest_revision = res['services'][0]['deployments'][0]['taskDefinition'].split(':')[-1]
    logger.info(f"Latest completed deployment: {last_deployment_time} to deploy revision {latest_revision}")

    # Get the task definition details
    res = client.describe_task_definition(
        taskDefinition=current_task_definition
    )

    # Log the image name and tag
    image = res['taskDefinition']['containerDefinitions'][0]['image']
    logger.info(f"Task definition revision {latest_revision} uses image: {image}")

    return res['taskDefinition'], image


def registerNewTaskDefinition(client: any, task_definition: dict, image: str) -> str:
    """Register a new task definition with the requested image:tag.

    Args:
        client (boto3.ECS.Client): the low level boto3 ECS client
        task_definition (dict): the currently deployed task definition
        image (str): the image:tag to deploy to the service
    
    Returns:
        str: the new task definition ARN
    """
    register_task_definition_params = {}

    attributes = [
        "family",
        "taskRoleArn",
        "executionRoleArn",
        "networkMode",
        "containerDefinitions",
        "volumes",
        "placementConstraints",
        "requiresCompatibilities",
        "cpu",
        "memory",
        "tags",
        "pidMode",
        "ipcMode",
        "proxyConfiguration"
        "inferenceAccelerators",
        "ephemeralStorage",
        "runtimePlatform"
    ]

    for attribute in attributes:
        if attribute in task_definition:
            register_task_definition_params[attribute] = task_definition[attribute]
    
    register_task_definition_params["containerDefinitions"][0]["image"] = image

    # res = client.register_task_definition(**register_task_definition_params)

    # return res['taskDefinition']['taskDefinitionArn']


def updateServiceTaskRevision(client: any, cluster: str, service: str, task_definition_arn: str, timeout: int) -> None:
    """Update the service to use the new task definition.

    Args:
        client (any): the low level boto3 ECS client
        cluster (str): the name of the ECS cluster
        service (str): the name of the ECS service
        task_definition_arn (str): the family and revision (family:revision) or full ARN of the task definition to update in your service. 
        timeout (int): the number of seconds to wait to update the service

    Raises:
        Exception: Timeout exceeded, service never reached a stable state to perform deployment of _task_definition_arn_...
        Exception: Timeout exceeded, service never reached a stable state AFTER deploying _task_definition_arn_, manually check service status...
        Exception: Deployment Failed: _deployment['failedTasks']_ of tasks have failed!
        Exception: Deployment Failed: _deployment['rolloutStateReason']_
    """
    endtime = time.time() + timeout
    while True:
        if time.time() > endtime:
            raise Exception(f"Timeout exceeded, service never reached a stable state to perform deployment of {task_definition_arn}...")

        # Assert that the service is in a stable state (not in the middle of a deployment)
        res = client.describe_services(
            cluster=cluster,
            services=[service]
        )

        # Creates a list of unique deployment statuses. Using set notation should result in a list of
        # length 1 if the service is stable. If the service is not stable, the list will contain more
        # than one unique deployment status.
        deployment_statuses = list(set([deployment["status"] for deployment in res['services'][0]['deployments']]))
        if deployment_statuses == ["PRIMARY"]:
            break

        logger.info(f"Service {service} is in {deployment_statuses} states. Waiting for service deployment to become stable.")
        
        # Wait 15 seconds before checking the service status again
        time.sleep(15)
    
    # Update the service to use the new task definition
    res = client.update_service(
        cluster=cluster,
        service=service,
        taskDefinition=task_definition_arn
    )

    # Assert that the service returns to a stable state until timeout
    while True:
        if time.time() > endtime:
            raise Exception(f"Timeout exceeded, service never reached a stable state AFTER deploying {task_definition_arn}, manually check service status...")

        # Assert that the service finished updating to the new task definition
        res = client.describe_services(
            cluster=cluster,
            services=[service]
        )

        for deployment in res['services'][0]['deployments']:
            # If the deployment is the one we just created, check statuses
            if deployment["taskDefinition"] == task_definition_arn:
                # If the deployment is the primary deployment, the deployment was successful
                if deployment["status"] == "PRIMARY":
                    logger.info(f"Deployment Successful: {service} updated to task definition {task_definition_arn}")
                    return
                
                if deployment["runningCount"] > 0 or deployment["pendingCount"] > 0:
                    logger.info(f"Deployment in Progress: {deployment['runningCount']} running, {deployment['pendingCount']} pending, {deployment['desiredCount'] - deployment['runningCount']} more desired!")
                if deployment["failedTasks"] > 0:
                    raise Exception(f"Deployment Failed: {deployment['failedTasks']} of tasks have failed!")

                if "rolloutState" in deployment:
                    if deployment["rolloutState"] == "COMPLETED":
                        logger.info(f"Deployment Successful: {deployment['rolloutStateReason']}")
                        return
                    elif deployment["rolloutState"] == "IN_PROGRESS":
                        logger.info(f"Deployment in Progress: {deployment['rolloutStateReason']}")
                    elif deployment["rolloutState"] == "FAILED":
                        raise Exception(f"Deployment Failed: {deployment['rolloutStateReason']}")


def run():
    # Parse/validate CLI arguments
    args = parseArguments()

    # Create a low level boto3 ECS client
    client = boto3.client('ecs', region_name=args.region)

    # Get currently deployed task definition in the service
    task_definition, image = getCurrentTaskDefinition(client, args.cluster, args.service)

    # Assert that the requested base image is the same as the currently deployed image
    current_image_delimiter = "@" if "@" in image else ":"
    requested_image_delimiter = "@" if "@" in args.image else ":"
    if image.split(current_image_delimiter)[0] != args.image.split(requested_image_delimiter)[0]:
        raise Exception(f"The requested image ({args.image}) is not the same as the currently deployed image ({image})")

    # Create a new task definition with the requested image:tag
    new_task_definition = registerNewTaskDefinition(client, task_definition, args.image)

    # Update the service to use the new task definition
    updateServiceTaskRevision(client, args.cluster, args.service, new_task_definition, args.timeout)

    client.close()


if __name__ == "__main__":
    try:
        run()
    except Exception as e:
        logger.error(e)
        exit(1)