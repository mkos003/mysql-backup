#!/bin/bash
# backup_databases.sh

# Configuration
BACKUP_DIR="/backups" # Dir inside container
MYSQL_HOST="mariadb" 
MYSQL_USER="${DB_BACKUP_USER}"
MYSQL_PASSWORD="${DB_BACKUP_PASSWORD}"
ENCRYPTION_KEY="${ENCRYPTION_KEY}"
DATABASES=("data" "app") # List your databases here

# Get current date in YYYY-MM-DD format
CURRENT_DATE=$(date +%d-%m-%Y_%H-%M)

# Create temporary directory for SQL files
TMP_DIR=$(mktemp -d)

# Backup each database
for DB in "${DATABASES[@]}"; do
    echo "Backing up database: $DB"
    
    # Create SQL dump
    mariadb-dump -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$DB" > "$TMP_DIR/${DB}_backup_${CURRENT_DATE}.sql"
    echo "Backup completed for database to directory: $TMP_DIR/${DB}_backup_${CURRENT_DATE}.sql"
    
    if [ $? -ne 0 ]; then
        echo "Error backing up $DB"
        continue
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
    echo "No SQL files found to backup. Skipping tar and encryption."
    echo ""
fi

# Clean up temporary files
rm -rf "$TMP_DIR"