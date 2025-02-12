#!/bin/bash

set -e

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log "Starting entrypoint.sh"

log "Checking SSH key permissions for postgres"

chmod 0700  /var/lib/postgresql/.ssh
chmod 0600  /var/lib/postgresql/.ssh/id_rsa
chmod 0600  /var/lib/postgresql/.ssh/id_rsa.pub
chmod 0600  /var/lib/postgresql/.ssh/authorized_keys

log "PostgreSQL wait for Patroni to start..."

log "Starting SSH server..."
/usr/sbin/sshd -D &

log "Starting PgBouncer..."
gosu postgres pgbouncer -d /etc/pgbouncer/pgbouncer.ini &

log "Starting Patroni..."
exec gosu postgres /venv/bin/patroni /etc/patroni/patroni.yml
