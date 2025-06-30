#!/bin/bash

# Configuration
BACKUP_DIR="/backups" # Dir inside container
DAYS_TO_KEEP=14

# Use full paths for commands in cron
FIND="/usr/bin/find"
RM="/bin/rm"

echo "Starting backup pruning process ($(date))"
echo "Looking for backups older than $DAYS_TO_KEEP days in $BACKUP_DIR"

# Find files without using mapfile (more compatible approach)
OLD_FILES=$($FIND "$BACKUP_DIR" -name "backup_*.tgz.enc" -type f -mtime +$DAYS_TO_KEEP)

# Check if any files were found
if [ -z "$OLD_FILES" ]; then
    echo "No backups needed pruning - all files are within $DAYS_TO_KEEP days"
else
    # Count files to be deleted (one per line)
    COUNT=$(echo "$OLD_FILES" | wc -l)
    
    echo "Found $COUNT backup(s) older than $DAYS_TO_KEEP days"
    echo "Files to be deleted:"
    echo "$OLD_FILES"
    echo

    # Delete each file individually with error checking
    echo "$OLD_FILES" | while read -r file; do
        if [ -f "$file" ]; then
            if $RM -f "$file"; then
                echo "Deleted: $file"
            else
                echo "Error deleting: $file"
                exit 1
            fi
        fi
    done
    
    echo "Successfully pruned $COUNT old backup(s)"
fi

echo "Backup pruning completed ($(date))"
echo ""