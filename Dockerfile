FROM apache/hive:standalone-metastore-4.1.0

ENV JAVA_HOME=/opt/java/openjdk

USER root

RUN microdnf install -y nc && microdnf clean all

RUN curl -L https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.19.tar.gz | tar zxf - && \
    cp mysql-connector-java-8.0.19/mysql-connector-java-8.0.19.jar /opt/hive/lib/ && \
    rm -rf mysql-connector-java-8.0.19 && \
    curl -L --output /opt/hive/lib/postgresql-42.4.0.jar https://jdbc.postgresql.org/download/postgresql-42.4.0.jar

COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER hive
EXPOSE 9083

ENTRYPOINT ["sh", "-c", "/entrypoint.sh"]
