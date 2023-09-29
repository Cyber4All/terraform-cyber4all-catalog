#!/usr/bin/env python3

import sys

def run():
    # Parse/validate CLI arguments

    # Get currently deployed task definition in the service

    # Assert that the requested base image is the same as the currently deployed image

    # Assert that the image:tag is valid and exists in the DockerHub registry

    # Create a new task definition with the requested image:tag

    # Assert that the service is in a stable state (not in the middle of a deployment)

    # If not stable, wait until timeout for the service to become stable

    # Update the service to use the new task definition

    # Assert that the service returns to a stable state until timeout
    return

if __name__ == "__main__":
    try:
        run()
    except Exception as e:
        sys.write.stderr(str(e) + "\n")
        exit(1)