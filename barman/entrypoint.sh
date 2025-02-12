#!/bin/bash

set -e

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log "Starting entrypoint.sh"

log "Checking SSH key permissions for barman"

chmod 700 /var/lib/barman/.ssh
chmod 600 /var/lib/barman/.ssh/id_rsa
chmod 600 /var/lib/barman/.ssh/id_rsa.pub
chmod 600 /var/lib/barman/.ssh/authorized_keys

log "Verifying SSH connectivity (barman → postgres)"
if ssh -o StrictHostKeyChecking=no postgres@pgsql15node01 'echo SSH OK'; then
    log "Successful SSH connection to localhost"
else
    log "SSH connection to localhost failed"
fi

log "Starting SSH server..."
/usr/sbin/sshd &

log "Checking SSL certificates"
if [ ! -f /home/barman/certs/server.crt ] || [ ! -f /home/barman/certs/server.key ]; then
    log "Missing SSL certificates. Exiting."
    exit 1
fi

log "Starting pg-backup-api with Gunicorn..."
exec /home/barman/app/venv/bin/gunicorn -c /etc/pg-backup-api-config.py pg_backup_api.app
