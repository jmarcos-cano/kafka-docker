FROM anapsix/alpine-java:8

ARG KAFKA_VERSION=0.10.2.0
ARG SCALA_VERSION=2.11


ENV KAFKA_VERSION=${KAFKA_VERSION} SCALA_VERSION=${SCALA_VERSION} \
    KAFKA_HOME=/opt/kafka PATH=${PATH}:${KAFKA_HOME}/bin \
    EXPOSED_VOLUME=/kafka 

ADD include/scripts/ /usr/bin/

COPY bin/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz /tmp

RUN apk add --no-cache --virtual .build-deps unzip wget curl jq coreutils  tar \
    && chmod a+x /usr/bin/download-kafka.sh && sync \
    && echo -e "\n******** download Kakfa ********\n"  \
    && /usr/bin/download-kafka.sh \
    && tar xfz /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt \
    && rm /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz \
    && ln -s /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} ${KAFKA_HOME} \
    && apk del .build-deps \
    && chmod +x /usr/bin/*.sh

VOLUME ["${EXPOSED_VOLUME}"]



#    && chmod a+x /usr/bin/broker-list.sh \
#    && chmod a+x /usr/bin/create-topics.sh
# Use "exec" form so that it runs as PID 1 (useful for graceful shutdown)
CMD ["start-kafka.sh"]



LABEL   maintainer="Marcos Cano <jmarcos.cano@gmail.com>" \
        org.label-schema.schema-version="v1.0-${SCALA_VERSION}-${KAFKA_VERSION}" \
        org.label-schema.description = "Kafka " \
        org.label-schema.vcs-url = "https://github.com/jmarcos-cano/kafka-docker"
