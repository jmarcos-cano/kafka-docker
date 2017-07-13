FROM anapsix/alpine-java:8

ARG KAFKA_VERSION=0.10.2.0
ARG SCALA_VERSION=2.11


ENV KAFKA_VERSION=${KAFKA_VERSION} SCALA_VERSION=${SCALA_VERSION} \
    KAFKA_HOME_BASE=/opt KAFKA_HOME=/opt/kafka PATH=${PATH}:${KAFKA_HOME}/bin \
    EV_KAFKA_DATA=/kafka 

ADD include/ /usr/bin/

COPY bin/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz /tmp
RUN apk add -q --no-cache --virtual .build-deps unzip wget curl jq coreutils tar \
    && chmod a+x /usr/bin/download-kafka.sh && sync \
    && echo -e "\n******** Download Kakfa ********\n"  \
   # && /usr/bin/download-kafka.sh \
    && echo -e "\n******** Installing Kakfa ********\n"  \
    && tar xfz /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C ${KAFKA_HOME_BASE} \
    && rm /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz \
    && ln -s ${KAFKA_HOME_BASE}/kafka_${SCALA_VERSION}-${KAFKA_VERSION} ${KAFKA_HOME} \
    && apk del -q .build-deps \
    && chmod +x /usr/bin/*.sh \
    && mkdir -p ${EV_KAFKA_DATA} 


VOLUME ["${EV_KAFKA_DATA}"]

# Use "exec" form so that it runs as PID 1 (useful for graceful shutdown)
CMD ["bootstrap.sh"]



LABEL   maintainer="Marcos Cano <jmarcos.cano@gmail.com>" \
        org.label-schema.schema-version="v1.0-${SCALA_VERSION}-${KAFKA_VERSION}" \
        org.label-schema.description="Kafka environment " \
        org.label-schema.vcs-url="https://github.com/jmarcos-cano/kafka-docker" 
