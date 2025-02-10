#!/bin/bash

set -e

echo "PostgreSQL wait for Patroni to start..."

echo "Starting sshd..."
/usr/sbin/sshd -D &
echo "SSH running..."

echo "Starting PgBouncer..."
gosu postgres pgbouncer -d /etc/pgbouncer/pgbouncer.ini &
echo "PgBouncer running..."

echo "Starting Patroni..."
exec gosu postgres /venv/bin/patroni /etc/patroni/patroni.yml
