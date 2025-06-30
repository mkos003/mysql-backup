#!/bin/sh
# entrypoint.sh

# Create the log file
touch /var/log/cron.log

# Check if SSH key file exists
if [ ! -f /root/.ssh/id_rsa ]; then
  echo "Error: SSH key file /root/.ssh/id_rsa not found"
  exit 1
fi

chmod 600 /root/.ssh/id_rsa
echo "SSH key permissions set"

# Start crond in foreground
crond -f & 

# Watch the logs
tail -f /var/log/cron.log
