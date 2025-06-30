#!/bin/sh
# entrypoint.sh

# Create the log file
touch /var/log/cron.log

# Setup SSH key from environment variable
chmod 600 /root/.ssh/synology_backup_key
echo "SSH key permissions set"

# Start crond in foreground
crond -f & 

# Watch the logs
tail -f /var/log/cron.log