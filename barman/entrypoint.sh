#!/bin/bash

echo "Setting ownership/permissions on ${BARMAN_DATA_DIR} and ${BARMAN_LOG_DIR}"

install -d -m 0700 -o barman -g barman "${BARMAN_DATA_DIR}"
install -d -m 0755 -o barman -g barman "${BARMAN_LOG_DIR}"

echo "Generating cron schedules"
crontab -l -u barman | tee /tmp/barman_cron
echo "${BARMAN_CRON_SCHEDULE} /usr/bin/barman cron" >> /tmp/barman_cron
echo "${BARMAN_BACKUP_SCHEDULE} /usr/bin/barman backup all" >> /tmp/barman_cron
crontab -u barman /tmp/barman_cron
rm /tmp/barman_cron

if [[ -f /var/lib/barman/.ssh/id_rsa ]]; then
    echo "Setting up Barman private key"
    chmod 700 /var/lib/barman/.ssh
    chmod 600 -R /var/lib/barman/.ssh/*
    chown barman:barman -R /var/lib/barman/.ssh
fi

echo "Initializing done"

exec /usr/sbin/sshd &
exec /usr/local/bin/barman-exporter -l "${BARMAN_EXPORTER_LISTEN_ADDRESS}":"${BARMAN_EXPORTER_LISTEN_PORT}" -c "${BARMAN_EXPORTER_CACHE_TIME}" &

echo "Started Barman exporter on ${BARMAN_EXPORTER_LISTEN_ADDRESS}:${BARMAN_EXPORTER_LISTEN_PORT}"

exec "$@"
