FROM anapsix/alpine-java:8

ARG KAFKA_VERSION=0.10.2.0
ARG SCALA_VERSION=2.11


ENV KAFKA_VERSION=${KAFKA_VERSION} SCALA_VERSION=${SCALA_VERSION} \
    KAFKA_HOME=/opt/kafka PATH=${PATH}:${KAFKA_HOME}/bin \
    EXPOSED_VOLUME=/kafka

ADD internal/scripts/ /usr/bin/

COPY bin/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz /tmp

RUN apk add --no-cache --virtual .build-deps unzip wget curl jq coreutils  \
    && chmod a+x /usr/bin/download-kafka.sh && sync \
    && echo -e "\n******** download Kakfa ********\n"  \
   # && /usr/bin/download-kafka.sh \
    && tar xfz /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt \
    && rm /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz \
    && ln -s /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} ${KAFKA_HOME} \
    && apk del .build-deps

VOLUME ["${EXPOSED_VOLUME}"]



#ADD broker-list.sh /usr/bin/broker-list.sh
#ADD create-topics.sh /usr/bin/create-topics.sh
# The scripts need to have executable permission
RUN chmod a+x /usr/bin/*.sh 
#    && chmod a+x /usr/bin/broker-list.sh \
#    && chmod a+x /usr/bin/create-topics.sh
# Use "exec" form so that it runs as PID 1 (useful for graceful shutdown)
CMD ["start-kafka.sh"]


LABEL maintainer="Marcos Cano <jmarcos.cano@gmail.com>"
