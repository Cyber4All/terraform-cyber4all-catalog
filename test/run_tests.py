"""
This file is used to run tests for the Terraform examples. It provides a CLI interface to run the tests and set up role assumption.

This script should be used when running tests. Specifically when you are running MongoDB Module tests, since this cli script will set up role assumption for you.

Usage:
    python run_tests.py test [OPTIONS]
    python run_tests.py setup-role-assumption [OPTIONS]

Options:
    --skip-role-assumption, -s: Skip role assumption. Default: False
    --arn TEXT: The role arn to assume
    --save, -s: Save the credentials to a file. Default: True
    --force-creds, -f: Force creating new credentials, if credentials already exist. Default: False
    --skip-validate: Skip validation of the module. Default: False
    --skip-destroy: Skip destroying the resources. Default: False
    --skip-apply: Skip applying the module. Default: False

Commands:
    test: Run the go tests within the test directory. If the --skip-role-assumption flag is not set, role assumption will be set up.
    setup-role-assumption: Set up role assumption and export the credentials as environment variables.
"""

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
@click.option('--arn', type=str, help='The role arn to assume')
@click.option('--save', '-s', is_flag=True, default=True, help='Save the credentials to a file. Default: True')
@click.option('--force-creds', '-f', is_flag=True, help='Force creating new credentials, if credentials already exist. Default: False')
@click.option('--skip-validate', is_flag=True, help='Skip validation of the module. Default: False')
@click.option('--skip-destroy', is_flag=True, help='Skip destroying the resources. Default: False')
@click.option('--skip-apply', is_flag=True, help='Skip applying the module. Default: False')
def run_tests(skip_role_assumption, arn, save, force_creds, skip_validate, skip_destroy, skip_apply):
    """ Run the go tests within the test directory. If the --skip-role-assumption flag is not set, role assumption will be set up. """
    if not skip_role_assumption and arn is not None:
        setup_role_assumption.callback(
            save=save, arn=arn, force_creds=force_creds)
    else:
        logging.info(
            "Skipping role assumption... Arn is not set or skip-role-assumption flag is set")
    # Check if arn is set
    if arn is None:
        logging.warning(
            "ARN not set. This could lead to tests failing if running MongoDB tests.")
    else:
        os.environ['TF_VAR_mongodb_role_arn'] = arn

    # Check that secret arn for mongodb is set
    if 'MONGODB_SECRET_ARN' not in os.environ:
        logging.warning(
            "MONGODB_SECRET_ARN not set. This could lead to tests failing if running MongoDB tests.")

    # Add flags to skip validation, destroy and apply
    if skip_validate:
        os.environ['SKIP_validate'] = 'true'
    if skip_destroy:
        os.environ['SKIP_destroy'] = 'true'
    if skip_apply:
        os.environ['SKIP_apply'] = 'true'

    # Run the tests
    logging.info("Running tests")

    error_thrown = False
    try:
        subprocess.run(
            ['go', 'test', '.', '-v', '--timeout', '2h'], check=True)
    except subprocess.CalledProcessError:
        error_thrown = True

    # Reset skip flags
    os.environ['SKIP_validate'] = 'false'
    os.environ['SKIP_destroy'] = 'false'
    os.environ['SKIP_apply'] = 'false'

    if error_thrown:
        sys.exit(1)


@cli.command("setup-role-assumption")
@click.option('--save', '-s', is_flag=True, default=True, help='Save the credentials to a file. Default: True')
@click.option('--arn', type=str, required=True, help='The role arn to assume')
@click.option('--force-creds', '-f', is_flag=True, help='Force creating new credentials, if credentials already exist. Default: False')
def setup_role_assumption(save, arn, force_creds):
    """ Set up role assumption and export the credentials as environment variables. """
    # Check if the credentials are still valid
    if not force_creds and check_existing_credentials():
        return

    logging.info("Setting up role assumption")
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
