#!/bin/bash

# List of databases to back up
STORAGE_ACCOUNT_FILE="/opt/open-db-backup"
SERVICES=("drupal" "discourse" "keycloak" "marketplace")
BACKUP_LOCAL_ROLLING=30
BACKUP_TMP="/tmp/backups"

# Function to perform backup for a single service
backup_database() {
  local service=$1
  # Add your backup commands here for each service
  bash -x open_backup_database.sh "$service"
}

# Execute the backup function in parallel for each service
for service in "${SERVICES[@]}"; do
  backup_database "$service" &
done

# Wait for all background jobs to finish
wait

echo "All database backups completed."

# Check backup files exist befor zipping them
BACKUP_DIRECTORY_NAME=$(ls -t $BACKUP_TMP | grep -v /$ | head -n 1)
BACKUP_PATH="$BACKUP_TMP/$BACKUP_DIRECTORY_NAME"
BACKUPS_EXIST=$(ls $BACKUP_PATH | wc -l)

if [ $BACKUPS_EXIST -eq 4 ]; then
    echo "... All backed up database dump are ready to zip!"
    zip -r "$BACKUP_PATH-dump.zip" "$BACKUP_PATH"
    echo "Backup filename zip = $BACKUP_PATH-dump.zip"
    mv "$BACKUP_PATH-dump.zip"  "$STORAGE_ACCOUNT_FILE"
    echo "Sent the zip file to Storage Account..."
else
    echo "Failed to backup database you have to check the $BACKUP_PATH directory !"
    return 1
fi

# ****************************************************
# Remove deprecated backup files locally
# ****************************************************
# we remove the oldest backup files and keep only BACKUP_LOCAL_ROLLING files

# first we count the existing backup files
BACKUPS_EXIST_LOCAL=$(ls -l $STORAGE_ACCOUNT_FILE/*-dump.zip | grep -v ^l | wc -l)
# now we can remove the files if we have more than defined...
if [ "$BACKUPS_EXIST_LOCAL" -gt "$BACKUP_LOCAL_ROLLING" ] 
  then 
     # remove the deprecated backup files...
     echo "        ...clean deprecated local dumps..."
     ls $STORAGE_ACCOUNT_FILE/*-dump.zip | head -n -$BACKUP_LOCAL_ROLLING | xargs rm -f
fi

echo " Backup completed and sent to Storage Account successfully ."