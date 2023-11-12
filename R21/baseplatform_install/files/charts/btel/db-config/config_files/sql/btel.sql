CREATE DATABASE IF NOT EXISTS grafana CHARACTER SET UTF8 COLLATE utf8_general_ci;
CREATE DATABASE IF NOT EXISTS calm_alma CHARACTER SET UTF8 COLLATE utf8_general_ci;
CREATE USER IF NOT EXISTS 'grafana'@'%' IDENTIFIED BY "{{ .Values.mariadb.grafana_db_password }}";
ALTER USER 'grafana'@'%'  IDENTIFIED BY "{{ .Values.mariadb.grafana_db_password }}";
GRANT ALL PRIVILEGES ON grafana.* TO 'grafana'@'%' REQUIRE SSL;
CREATE USER IF NOT EXISTS 'alma_dbuser'@'%' IDENTIFIED BY "{{ .Values.mariadb.calm_db_password }}";
ALTER USER 'alma_dbuser'@'%'  IDENTIFIED BY "{{ .Values.mariadb.calm_db_password }}";
GRANT ALL PRIVILEGES ON calm_alma.* TO 'alma_dbuser'@'%' REQUIRE SSL;
FLUSH PRIVILEGES;
