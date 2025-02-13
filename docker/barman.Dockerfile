FROM debian:bullseye

RUN apt-get update \
	&& apt-get install -y --no-install-recommends lsb-release ca-certificates curl gnupg2 gosu tini\
	&& rm -rf /var/lib/apt/lists/* \
    # verify that the binary works
    && gosu nobody true

RUN curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/postgresql.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/postgresql.gpg] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		cron gcc \
        barman barman-cli barman-cli-cloud \
		ssh rsync \
		libpq-dev libpython3-dev \
		postgresql-client-9.5 postgresql-client-9.6 postgresql-client-10 \
		postgresql-client-11 postgresql-client-12 postgresql-client-13 \
		postgresql-client-14 postgresql-client-15 postgresql-client-16 \
        postgresql-client-17 \
		python3 python3-distutils python3-pip \
        gettext-base procps net-tools nano && \
    rm -rf /var/lib/apt/lists/* && \
    rm -f /etc/crontab /etc/cron.*/* && \
	sed -i 's/\(.*pam_loginuid.so\)/#\1/' /etc/pam.d/cron && \
    mkdir -p /etc/barman/barman.d

ENV BARMAN_CRON_SRC=/private/cron.d \
	BARMAN_DATA_DIR=/var/lib/barman \
	BARMAN_LOG_DIR=/var/log/barman \
    BARMAN_CRON_SCHEDULE="* * * * *" \
    BARMAN_BACKUP_SCHEDULE="0 4 * * *" \
    BARMAN_LOG_LEVEL=INFO \
    BARMAN_EXPORTER_SCHEDULE="*/5 * * * *" \
    BARMAN_EXPORTER_LISTEN_ADDRESS="0.0.0.0" \
    BARMAN_EXPORTER_LISTEN_PORT=9780 \
    BARMAN_EXPORTER_CACHE_TIME=3600

VOLUME ${BARMAN_DATA_DIR}

# Configs
COPY --chown=barman:barman barman/barman.conf /etc/barman.conf
COPY --chown=barman:barman barman/barman.d /etc/barman.d

# SSH Keys
COPY --chown=barman:barman --chmod=0600 ssh-keys/id_rsa ssh-keys/id_rsa.pub /var/lib/barman/.ssh/
COPY --chown=barman:barman --chmod=0600 ssh-keys/id_rsa.pub /var/lib/barman/.ssh/authorized_keys
COPY ssh-keys/server-keys /etc

RUN mkdir -p /run/sshd && \
    echo 'Port 22\nPermitRootLogin no\nPasswordAuthentication no\nPubkeyAuthentication yes\nStrictModes no' > /etc/ssh/sshd_config && \
    echo 'Host *\n\tStrictHostKeyChecking no' > /var/lib/barman/.ssh/config && \
    chmod 0600 /var/lib/barman/.ssh/config

RUN mkdir -p /var/lib/barman/.ssh && \
    chmod 0755  /var/lib/barman && \
    chmod 0700  /var/lib/barman/.ssh && \
    chown -R barman:barman  /var/lib/barman

# Install barman exporter
RUN pip3 install barman-exporter && mkdir /srv/node_exporter

VOLUME /srv/node_exporter

# Logs
RUN mkdir -p /var/log/barman && \
    touch /var/log/barman/barman.log && \
    chmod 755 /var/log/barman && \
    chmod 644 /var/log/barman/barman.log && \
    chown -R barman:barman /var/log/barman

COPY barman/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 22 ${BARMAN_EXPORTER_LISTEN_PORT}

ENTRYPOINT ["tini", "--", "/entrypoint.sh"]

CMD ["cron", "-L", "4", "-f"]

WORKDIR ${BARMAN_DATA_DIR}
