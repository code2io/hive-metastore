#!/bin/sh

export HADOOP_HOME=/opt/hadoop-${HADOOP_VERSION:-3.3.6}
export HADOOP_CLASSPATH=${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-bundle-*.jar:${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-aws-*.jar
export JAVA_HOME=/usr/lib/jvm/default-jvm/jre
export METASTORE_DB_HOSTNAME=${METASTORE_DB_HOSTNAME:-localhost}
export METASTORE_TYPE=${METASTORE_TYPE:-mysql}

HIVE_HOME=/opt/hive-standalone-metastore-${METASTORE_VERSION:-4.1.0}-bin

MYSQL='mysql'
POSTGRES='postgres'

if [ "${METASTORE_TYPE}" = "${MYSQL}" ]; then
  echo "Using mysql for metastore"
  METASTORE_DB_PORT=${METASTORE_DB_PORT:-3306} # Default to 3306
  echo "Waiting for database on ${METASTORE_DB_HOSTNAME} to launch on ${METASTORE_DB_PORT} ..."
  while ! nc -z ${METASTORE_DB_HOSTNAME} ${METASTORE_DB_PORT}; do
    sleep 1
  done

  echo "Database on ${METASTORE_DB_HOSTNAME}:${METASTORE_DB_PORT} started"
  echo "Init apache hive metastore on ${METASTORE_DB_HOSTNAME}:${METASTORE_DB_PORT}"

  ${HIVE_HOME}/bin/schematool -initSchema -dbType mysql
  ${HIVE_HOME}/bin/start-metastore
fi

if [ "${METASTORE_TYPE}" = "${POSTGRES}" ]; then
  echo "Using postgresql for metastore"
  METASTORE_DB_PORT=${METASTORE_DB_PORT:-5432} # Default to 5432
  echo "Waiting for database on ${METASTORE_DB_HOSTNAME} to launch on ${METASTORE_DB_PORT} ..."
  while ! nc -z ${METASTORE_DB_HOSTNAME} ${METASTORE_DB_PORT}; do
    sleep 1
  done

  echo "Database on ${METASTORE_DB_HOSTNAME}:${METASTORE_DB_PORT} started"
  echo "Init apache hive metastore on ${METASTORE_DB_HOSTNAME}:${METASTORE_DB_PORT}"

  ${HIVE_HOME}/bin/schematool -initSchema -dbType postgres
  ${HIVE_HOME}/bin/start-metastore
fi
