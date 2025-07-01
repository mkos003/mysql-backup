#!/bin/bash

# Source directory where backups are stored (inside the container)
SOURCE_DIR="/backups"

# Destination on Synology NAS
REMOTE_HOST="${SYNC_BACKUP_HOST}"
REMOTE_USER="${SYNC_BACKUP_USER}"
REMOTE_DIR="${SYNC_BACKUP_REMOTE_DIR}"

# SSH key path
SSH_KEY="/root/.ssh/id_rsa"

if [ ! -f "${SYNC_SSH_KEY}" ]; then
    echo "ERROR: SSH key not found: ${SYNC_SSH_KEY}"
    exit 1
fi

# Start logging
echo "$(date): Starting backup sync"

# Use rsync to sync only new or changed files
# Without --delte, to just transfer files from source to destination
# rsync -avz --delete -e "ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no" ${SOURCE_DIR}/ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/
rsync -avz -e "ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no" ${SOURCE_DIR}/ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/

# Log completion status
if [ $? -eq 0 ]; then
    echo "$(date): Backup sync completed successfully"
    echo ""
else
    echo "$(date): Backup sync failed with error code $?"
    echo ""
fi
