#!/bin/bash
# backup_databases.sh

set -e  # Optional: Exit immediately on errors

# Configuration
BACKUP_DIR="/backups" # Dir inside container
MYSQL_HOST="${MYSQL_HOST}" 
MYSQL_USER="${MYSQL_BACKUP_USER}"
MYSQL_PASSWORD="${MYSQL_BACKUP_PASSWORD}"
ENCRYPTION_KEY="${ENCRYPTION_KEY}"

# Convert comma-separated list to bash array
IFS=',' read -r -a DATABASES <<< "$MYSQL_DATABASES_LIST"

# Get current date in YYYY-MM-DD format
CURRENT_DATE=$(date +%d-%m-%Y_%H-%M)

# Create temporary directory for SQL files
TMP_DIR=$(mktemp -d)

# Backup each database
for DB in "${DATABASES[@]}"; do
    echo "Backing up database: $DB"
    
    # Create SQL dump
    mariadb-dump -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$DB" > "$TMP_DIR/${DB}_backup_${CURRENT_DATE}.sql"
    
    if [ $? -ne 0 ]; then
        echo "Error backing up $DB"
        continue
    else
        echo "Backup completed: $TMP_DIR/${DB}_backup_${CURRENT_DATE}.sql"
    fi
done

# Check if there are any .sql files before creating the archive
if ls "$TMP_DIR"/*.sql 1> /dev/null 2>&1; then
    # Create tar archive
    BACKUP_FILE="backup_${CURRENT_DATE}"
    cd "$TMP_DIR" && tar -czf "$BACKUP_FILE.tgz" *.sql

    # Encrypt the archive
    openssl enc -aes-256-cbc -salt -pbkdf2 -in "$TMP_DIR/$BACKUP_FILE.tgz" -out "$BACKUP_DIR/$BACKUP_FILE.tgz.enc" -k "$ENCRYPTION_KEY"

    echo "Backup completed: $BACKUP_DIR/$BACKUP_FILE.tgz.enc"
    echo ""
else
    echo "No SQL files found to backup. Skipping archive and encryption."
    echo ""
fi

# Clean up temporary files
rm -rf "$TMP_DIR"
