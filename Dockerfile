FROM alpine:3.21

# Install necessary packages
RUN apk add --no-cache \
    bash \
    nano \
    mysql-client \
    openssl \
    dcron \
    tzdata \
    rsync \
    openssh-client

# Create directories
RUN mkdir -p /scripts /backups /root/.ssh

# Copy scripts
COPY ./scripts/backup_databases.sh /scripts
COPY ./scripts/prune_backups.sh /scripts
COPY ./scripts/restore_backups.sh /scripts
COPY ./scripts/sync_to_nas.sh /scripts

# Make scripts executable
RUN chmod +x /scripts/backup_databases.sh \
    && chmod +x /scripts/prune_backups.sh \
    && chmod +x /scripts/restore_backups.sh \
    && chmod +x /scripts/sync_to_nas.sh

# Copy cron jobs and set permissions
COPY ./scripts/crontab.txt /etc/crontabs/root
RUN chmod 0644 /etc/crontabs/root

# Set proper SSH directory permissions
RUN chmod 700 /root/.ssh

# Create entry point script
COPY ./scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Start cron
ENTRYPOINT ["/entrypoint.sh"]
