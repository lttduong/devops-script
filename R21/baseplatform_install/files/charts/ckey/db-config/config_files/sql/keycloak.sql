CREATE DATABASE IF NOT EXISTS db4keycloak;
CREATE USER IF NOT EXISTS 'keycloak'@'%' IDENTIFIED BY "{{ .Values.mariadb.keycloak_db_password }}";
ALTER USER 'keycloak'@'%'  IDENTIFIED BY "{{ .Values.mariadb.keycloak_db_password }}";
GRANT ALL PRIVILEGES ON db4keycloak.* TO 'keycloak'@'%' REQUIRE SSL;
FLUSH PRIVILEGES;
