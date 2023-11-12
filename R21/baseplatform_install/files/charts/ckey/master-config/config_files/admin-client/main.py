#!/usr/bin/env python3

import argparse
import requests
import sys
import urllib3
from pathlib import Path

from security_keycloak.keycloak_user_connector import KeycloakUserConnector
from security_keycloak.keycloak_controller import KeycloakController
from keycloak_loader.service.configuration_settings_reader import ConfigurationSettingsReader
from keycloak_loader.settings import status
from import_admin_client import import_admin_client


def run(args):
    urllib3.disable_warnings()
    requests.packages.urllib3.disable_warnings()
    requests.packages.urllib3.disable_warnings(UserWarning)

    configuration_settings = ConfigurationSettingsReader().get_settings(Path(args.config_dir))
    if not configuration_settings:
        return status.INPUT_PARAM_ERROR
    verify_certs = args.ca_path if args.verify_certs and args.ca_path is not None else args.verify_certs
    keycloak_host = '{}:{}'.format(configuration_settings.keycloak.host, configuration_settings.keycloak.port)

    keycloak_user_connector = KeycloakUserConnector(host=keycloak_host,
                                                    realm=configuration_settings.keycloak.auth_realm,
                                                    username=configuration_settings.keycloak.admin_username,
                                                    password=configuration_settings.keycloak.admin_password,
                                                    client_id=configuration_settings.keycloak.admin_client_id,
                                                    verify_certs=verify_certs)

    keycloak_controller = KeycloakController(keycloak_user_connector)
    import_admin_client(keycloak_controller, args.realm, args.data_dir)


def main():
    parser = argparse.ArgumentParser(description='Keycloak configuration importer')
    parser.add_argument('-c', '--config',
                        dest='config_dir',
                        help='Config dir')
    parser.add_argument('-d', '--data',
                        dest='data_dir',
                        help='Data dir')
    parser.add_argument('-r', '--realm',
                        dest='realm',
                        help='Realm name')
    parser.add_argument('--ca',
                        dest='ca_path',
                        help='path to Certificate Authority file')
    parser.add_argument('--verify-certs',
                        dest='verify_certs',
                        action='store_true',
                        help='ca certs verification')
    parser.set_defaults(data_dir='/import/data',
                        config_dir='/import/config',
                        verify_certs=False)
    args = parser.parse_args()
    sys.exit(run(args))


if __name__ == "__main__":
    main()
