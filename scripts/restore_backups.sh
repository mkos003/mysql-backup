# restore_backup.sh
# Usage: ./restore_backup.sh <backup_file> <database_name>
#!/bin/bash

# Usage function
usage() {
    echo "Usage: $0 <backup_file> <database_name>"
    exit 1
}

# Check arguments
if [ "$#" -ne 2 ]; then
    usage
fi

BACKUP_FILE=$1
DATABASE_NAME=$2
BACKUP_DIR="/backups"
MYSQL_HOST="${MYSQL_HOST}" 
MYSQL_USER="${DB_BACKUP_USER}"
MYSQL_PASSWORD="${DB_BACKUP_PASSWORD}"
ENCRYPTION_KEY="${ENCRYPTION_KEY}"

# Create temporary directory
TMP_DIR=$(mktemp -d)

# Decrypt the backup
openssl enc -aes-256-cbc -salt -pbkdf2 -d -in "$BACKUP_DIR/$BACKUP_FILE" -out "$TMP_DIR/backup.tgz" -k "$ENCRYPTION_KEY"

# Extract the archive
tar -xzf "$TMP_DIR/backup.tgz" -C "$TMP_DIR"

# Restore the database
mariadb -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$DATABASE_NAME" < "$TMP_DIR/${DATABASE_NAME}_backup_"*.sql

# Clean up
rm -rf "$TMP_DIR"

echo "Restore completed for database: $DATABASE_NAME"
echo ""
