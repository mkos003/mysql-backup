# MySQL Backup 
Quick deploy and simple minimal configuration Docker container performing cron based MySQL backups, backups encryption and syncing with remote backup server

Docker container is using preconfigure scripts to execute 4 actions: `backup databases + encrypt them`, `sync encrypted zipped files to remote server`, `prune old backups from local machine`, `restore backups from zipped encrypted file on local machine` 

## What do you need to have?
- Instance of MySQL database (obviously)
- [Docker](https://docs.docker.com/engine/install/) instelled on host system
- Remote server for storing encrypted backups (3-2-1)
- Private key to access remote server securely 

## What do you need to configure?
- MySQL backup user with mysqldump permission to dump desired databases
- Encryption key for encrypting and decrypting zipped database files
- Local and remote directory for storing encrypted files
- Adjust variables in the `./.env` file to your dependencies 
- Adjust parameters in the `./scripts/crontab.txt` to define script execution timings

> You should only configure variables in .env file, see .env file for details

## How to run backup container?
`docker compose -f docker-compose.yml up -d`

## How to test scripts
You can test individual script by entering the container manually `docker exec -it backup bash`, move to scripts `cd /scripts`, execute desired script `./<script_name> [OPTIONAL_PARAMETERS]`

## Other manual commands
Run restore script in container: `./restore_backup.sh <backup-file.tgz.enc> <database-name>`<br>
Manual restore: `openssl enc -aes-256-cbc -salt -pbkdf2 -d -in "<backup-file.tgz.enc>" -out "<backup-file.tgz>" -k <encryption-key>`

## Clear remote server (this will delete backups on remote server)
Create temp dir: `mkdir -p /tmp/empty_dir`<br>
Delete remote backups: `rsync -avz --delete -e "ssh -i <path_to_ssh_key> -o StrictHostKeyChecking=no" /tmp/empty_dir/ backup-user@46.150.50.168:<remote_backup_dir>`
