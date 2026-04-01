#!/bin/sh

export METASTORE_DB_HOSTNAME=${METASTORE_DB_HOSTNAME:-localhost}
export METASTORE_TYPE=${METASTORE_TYPE:-mysql}

MYSQL='mysql'
POSTGRES='postgres'

if [ "${METASTORE_TYPE}" = "${MYSQL}" ]; then
  echo "Using mysql for metastore"
  METASTORE_DB_PORT=${METASTORE_DB_PORT:-3306}
  echo "Waiting for database on ${METASTORE_DB_HOSTNAME} to launch on ${METASTORE_DB_PORT} ..."
  while ! nc -z ${METASTORE_DB_HOSTNAME} ${METASTORE_DB_PORT}; do
    sleep 1
  done
  echo "Database on ${METASTORE_DB_HOSTNAME}:${METASTORE_DB_PORT} started"
  /opt/hive/bin/schematool -initSchema -dbType mysql
  /opt/hive/bin/start-metastore
fi

if [ "${METASTORE_TYPE}" = "${POSTGRES}" ]; then
  echo "Using postgresql for metastore"
  METASTORE_DB_PORT=${METASTORE_DB_PORT:-5432}
  echo "Waiting for database on ${METASTORE_DB_HOSTNAME} to launch on ${METASTORE_DB_PORT} ..."
  while ! nc -z ${METASTORE_DB_HOSTNAME} ${METASTORE_DB_PORT}; do
    sleep 1
  done
  echo "Database on ${METASTORE_DB_HOSTNAME}:${METASTORE_DB_PORT} started"
  /opt/hive/bin/schematool -initSchema -dbType postgres
  /opt/hive/bin/start-metastore
fi
