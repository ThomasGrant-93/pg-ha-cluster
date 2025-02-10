# Кластер PostgreSQL с Patroni, etcd и HAProxy

Проект настраивает кластер PostgreSQL с высокой доступностью, используя Patroni для автоматического переключения узлов,
etcd в качестве распределенного хранилища, и HAProxy для балансировки нагрузки между узлами кластера.

## Описание проекта

Кластер PostgreSQL включает следующие компоненты:

- **Patroni**: Управляет экземплярами PostgreSQL и автоматизирует переключение узлов в случае отказа.
- **etcd**: Обеспечивает распределенный консенсус и хранит состояние кластера для Patroni.
- **HAProxy**: Направляет трафик на соответствующий ведущий узел для операций записи и на реплики для операций чтения.
- **PostgreSQL**: Движок базы данных, настроенный на высокую доступность с репликацией, переключением узлов и резервным
  копированием.

## Краткое руководство по запуску

### 1. Клонирование репозитория

### 2. Настройка переменных окружения

Создайте файл `.env` в корневой папке проекта со следующими переменными:

```bash
PGBOUNCER_AUTH_TYPE='scram-sha-256'
PATRONI_ETCD3_HOSTS='etcd:2379'
PATRONI_HTTP_ADMIN='admin'
PATRONI_HTTP_PASSWORD='admin'
PATRONI_SUPERUSER_USERNAME='postgres'
PATRONI_SUPERUSER_PASSWORD='postgres'
PATRONI_POSTGRESQL_DATA_DIR='/var/lib/postgresql/data'
PATRONI_POSTGRESQL_LISTEN='0.0.0.0:5432'
ETCD_INITIAL_CLUSTER='etcd=http://etcd:2380'
ALLOW_NONE_AUTHENTICATION='yes'
ETCD_LISTEN_PEER_URLS='http://0.0.0.0:2380'
ETCD_LISTEN_CLIENT_URLS='http://0.0.0.0:2379'
ETCD_INITIAL_CLUSTER_TOKEN='etcd-cluster'
ETCD_INITIAL_CLUSTER_STATE='new'
```

Настройте переменные в соответствии с вашей средой.

### 3. Сборка и запуск сервисов

Соберите контейнер Patroni:

```bash
docker build . -f pgsql.Dockerfile --pull --tag picasso/pg15-patroni:develop
```

Запустите кластер:

```bash
docker-compose up -d
```

Эта команда запустит узлы etcd, HAProxy и PostgreSQL.

### 4. Доступ к статистике HAProxy

HAProxy предоставляет страницу статистики на порту `8404`. Вы можете получить к ней доступ, перейдя по адресу
`http://localhost:8404/stats` в браузере.

**Стандартные учетные данные:**

- Имя пользователя: `admin`
- Пароль: `admin`

### 5. Подключение к PostgreSQL

После запуска сервисов можно подключиться к ведущему узлу PostgreSQL через HAProxy (порт `6432`):

```bash
psql -h localhost -p 6432 -d postgres -U edw_admin_user -W
```

Для запросов только на чтение используйте порт `6433` (HAProxy будет балансировать между репликами).

## Сервисы и конфигурация

### Конфигурация Patroni

Patroni управляет кластером PostgreSQL. Ключевые компоненты в `patroni.yml`:

- **etcd**: Обеспечивает распределенное хранилище для состояния кластера.
- **Параметры PostgreSQL**:
    - **max_connections**: 100
    - **wal_level**: logical
    - **max_replication_slots**: 5
    - **shared_buffers**: 2GB

### etcd

Сервис etcd используется для распределенного консенсуса. Каждый узел PostgreSQL взаимодействует с etcd для определения
состояния кластера и того, какой узел является лидером.

- **Порт**: 2379 (клиентский)
- **Порт**: 2380 (коммуникация между узлами)

### Конфигурация HAProxy

HAProxy используется для маршрутизации запросов чтения и записи на соответствующий узел PostgreSQL:

- **Порт 6432**: Направляет трафик на запись на лидера.
- **Порт 6433**: Направляет трафик на чтение на одну из реплик.

### Структура Docker Compose

- `pgsql15node01`, `pgsql15node02`, `pgsql15node03`: Узлы PostgreSQL, управляемые Patroni.
- `etcd`: etcd для координации кластера.
- `haproxy`: Балансировщик нагрузки для PostgreSQL.

## Управление кластером

### Просмотр состояния кластера

```bash
./bin/patronictl list
```

### Переключение лидера вручную

```bash
./bin/patronictl switchover --leader <member-name> --candidate <member-name> --force
```

### Валидация конфигурации Patroni

```bash
./bin/patroni --validate-config /etc/patroni/patroni.yml
```

### Просмотр логов

```bash
tail -f /var/log/patroni/patroni.log -n 1000
tail -f /var/log/pgbouncer.log -n 1000
```

## Частые проблемы

### Ошибка "no pg_hba.conf entry"

Убедитесь, что в настройках `pg_hba.conf` в файле `patroni.yml` разрешены подключения от всех необходимых хостов,
включая диапазоны IP-адресов внутри Docker.

### Не удается подключиться к PostgreSQL

Проверьте логи контейнеров PostgreSQL:

```bash
docker-compose logs -f --tail 500
```

### Ошибка выбора лидера

Проверьте, что etcd запущен и доступен для всех узлов Patroni. Вы также можете проверить логи контейнера etcd:

```bash
docker-compose logs -f etcd
```
