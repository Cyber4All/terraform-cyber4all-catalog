'''
This script sets up role assumption for the MongoDB Module
'''

import datetime
import json
import os
import subprocess
import logging
import click
import sys

# Set up logging, formatting and log level
logging.basicConfig(
    format='%(asctime)s [%(levelname)s] %(message)s', level=logging.INFO)


@click.group()
def cli():
    pass


@cli.command("test")
@click.option('--skip-role-assumption', '-s', is_flag=True, help='Skip role assumption. Default: False')
@click.option('--dir', type=click.Path(exists=True), default='test', help='The directory containing the tests. Default: test')
@click.option('--arn', type=str, required=True, help='The role arn to assume')
@click.option('--save', '-s', is_flag=True, help='Save the credentials to a file. Default: True')
def run_tests(skip_role_assumption, dir, arn, save):
    """ Run the go tests within the test directory. If the --skip-role-assumption flag is not set, role assumption will be set up. """
    if not skip_role_assumption:
        setup_role_assumption.callback(save=save, arn=arn)
    # Change directory to the test directory
    os.chdir(dir)
    # Run the tests
    logging.info("Running tests")
    os.environ['TF_VAR_mongodb_role_arn'] = arn
    try:
        subprocess.run(['go', 'test', '.', '-v'], check=True)
    except subprocess.CalledProcessError:
        sys.exit(1)


@cli.command("setup-role-assumption")
@click.option('--save', '-s', is_flag=True, help='Save the credentials to a file. Default: True')
@click.option('--arn', type=str, required=True, help='The role arn to assume')
def setup_role_assumption(save, arn):
    """ Set up role assumption and export the credentials as environment variables. """
    # Check if the credentials are still valid
    if check_existing_credentials():
        return

    logging.info("No existing credentials. Setting up role assumption")
    res = subprocess.run(['aws', 'sts', 'assume-role', '--role-arn', arn,
                          '--role-session-name', 'terratest-session', '--output', 'json'], capture_output=True, check=True)
    res_json = res.stdout.decode('utf-8')
    res_dict = json.loads(res_json)

    # Store the credentials in json file
    if save:
        with open('credentials.json', 'w') as f:
            json.dump(res_dict, f)
            logging.info("Credentials stored in credentials.json. Expiration: " +
                         res_dict['Credentials']['Expiration'])
    else:
        logging.info("Skipping saving credentials")

    logging.info("Setting up environment variables")
    # Export the environment variables
    export_credentials(res_dict)


def check_existing_credentials():
    """ Check if there are existing credentials and if they are still valid. """
    if not os.path.exists('credentials.json'):
        return False

    logging.info("Found existing credentials")
    with open('credentials.json', 'r') as f:
        res_dict = json.load(f)
        expiration = datetime.datetime.strptime(
            res_dict['Credentials']['Expiration'], "%Y-%m-%dT%H:%M:%S+00:00")
        if expiration > datetime.datetime.now():
            logging.info(
                "Credentials still valid. Using existing credentials.")
            # Export the environment variables
            export_credentials(res_dict)
        else:
            logging.info(
                "Credentials expired. Setting up role assumption again.")
            return False

    return True


def export_credentials(creds):
    """ Export the credentials as environment variables. """
    os.environ['AWS_ACCESS_KEY_ID'] = creds['Credentials']['AccessKeyId']
    os.environ['AWS_SECRET_ACCESS_KEY'] = creds['Credentials']['SecretAccessKey']
    os.environ['AWS_SESSION_TOKEN'] = creds['Credentials']['SessionToken']


if __name__ == '__main__':
    cli()
