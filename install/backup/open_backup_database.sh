#!/bin/bash

# Set env var
SERVICE=$1
BACKUP_TMP="/tmp/backups"
NAMESPACE="default"
OPEN_DATABASE_NAME="nokiaopenup-backup"

# Define a log function to log time
log() {
  currenttime=$(date +"%Y %h %d %T")
  echo "$currenttime: $*"
}

# Function to support pick type of database
backup_database() {
  local db_user=$1
  local db_password=$2
  local db_name=$3
  local db_type=$4

  case $db_type in
    mysql)
      kubectl -n "$NAMESPACE" exec "$pod_name" -- mysqldump -u "$db_user" -p"$db_password" "$db_name" > "$BACKUP_FILENAME_DIRECTORY/$db_name.sql"
      ;;
    postgres)
      kubectl -n "$NAMESPACE" exec "$pod_name" -- pg_dumpall -U "$db_user" > "$BACKUP_FILENAME_DIRECTORY/$db_name.sql"
      ;;
    *)
      log "Unsupported database type: $db_type"
      return 1
      ;;
  esac

  if [ $? -eq 0 ]; then
    log "... $db_name database dump finished!"
    log "Backup filename=$BACKUP_FILENAME_DIRECTORY/$db_name.sql"
  else
    log "Failed to backup $db_name database!"
    return 1
  fi
}

# Generate a timestamp to use in the backup file name
BACKUP_TIME=$(date +%Y-%m-%d_%H_%M)
BACKUP_FILENAME_DIRECTORY="$BACKUP_TMP/${OPEN_DATABASE_NAME}_${BACKUP_TIME}"

# Make sure the directory exists
mkdir -p "$BACKUP_FILENAME_DIRECTORY"
log "Starting database dump for service: $SERVICE"

# Start backing up with input of service name
case $SERVICE in
  drupal)
    pod_name=$(kubectl get po | grep "$SERVICE-db" | head -n 1 | awk '{print $1}')
    backup_database "$SERVICE" "$SERVICE" "$SERVICE" "mysql"
    ;;
  discourse)
    pod_name=$(kubectl get po | grep "$SERVICE-db" | head -n 1 | awk '{print $1}')
    backup_database "postgres" "" "$SERVICE" "postgres"
    ;;
  keycloak)
    pod_name=$(kubectl get po | grep "$SERVICE-mysql" | head -n 1 | awk '{print $1}')
    backup_database "$SERVICE" "$SERVICE" "$SERVICE" "mysql"
    ;;
  marketplace)
    pod_name=$(kubectl get po | grep "$SERVICE-mysql" | head -n 1 | awk '{print $1}')
    backup_database "$SERVICE" "$SERVICE" "$SERVICE" "mysql"
    ;;
  *)
    log "Please check arguments when running the script"
    ;;
esac

