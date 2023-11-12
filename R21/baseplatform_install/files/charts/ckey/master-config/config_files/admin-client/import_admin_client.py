#!/usr/bin/env python3
"""
Importing keycloak configuration
"""

import copy
import json
import pathlib

from security_common import logger

LOGGER = logger.Logger.get_logger('keycloak-config-importer')


def import_admin_client(keycloak_controller, realm, data_dir):
    LOGGER.info('Keycloak config import started')
    LOGGER.info('Adding client master-admin in realm %s', realm)
    partial_content = _load_json(pathlib.Path(data_dir, 'partial.json'))
    response = keycloak_controller.keycloak_admin.partial_import(realm, partial_content)
    response_copy = copy.deepcopy(response)
    if response_copy.text:
        LOGGER.info(response_copy.text)
    response_copy.raise_for_status()
    LOGGER.info('Keycloak config import finished')


def _load_json(path):
    with open(path) as stream:
        return json.load(stream)