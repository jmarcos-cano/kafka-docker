#!/bin/bash


set -o verbose \
    -o errexit

  

# get first 2 digits from Container id
export BROKER_CONTAINER_ID=$(echo $HOSTNAME| sed -e s/[^0-9]//g|cut -c1-2)



if [ -z ${KAFKA_ZOOKEEPER_CONNECT+x} ]; then echo "KAFKA_ZOOKEEPER_CONNECT is unset"; else echo "KAFKA_ZOOKEEPER_CONNECT is set to '${KAFKA_ZOOKEEPER_CONNECT}'"; fi
if [ -z ${KAFKA_ADVERTISED_LISTENERS+x} ]; then echo "KAFKA_ADVERTISED_LISTENERS is unset"; else echo "KAFKA_ADVERTISED_LISTENERS is set to '${KAFKA_ADVERTISED_LISTENERS}'"; fi


# By default, LISTENERS is derived from ADVERTISED_LISTENERS by replacing
# hosts with 0.0.0.0. This is good default as it ensures that the broker
# process listens on all ports.
if [[ -z "${KAFKA_LISTENERS-}" ]];then
  export KAFKA_LISTENERS
  KAFKA_LISTENERS=${KAFKA_ADVERTISED_LISTENERS}
fi

if [[ -z "${KAFKA_LOG_DIRS-}" ]];then
  export KAFKA_LOG_DIRS
  KAFKA_LOG_DIRS="${EV_KAFKA_DATA}/kafka-logs-$HOSTNAME"
fi
mkdir -p ${KAFKA_LOG_DIRS}

# advertised.host, advertised.port, host and port are deprecated. Exit if these properties are set.
if [[ -n "${KAFKA_ADVERTISED_PORT-}" ]];then
  echo "advertised.port is deprecated. Please use KAFKA_ADVERTISED_LISTENERS instead."
  exit 1
fi

if [[ -n "${KAFKA_ADVERTISED_HOST-}" ]];then
  echo "advertised.host is deprecated. Please use KAFKA_ADVERTISED_LISTENERS instead."
  exit 1
fi

if [[ -n "${KAFKA_HOST-}" ]];then
  echo "host is deprecated. Please use KAFKA_ADVERTISED_LISTENERS instead."
  exit 1
fi

if [[ -n "${KAFKA_PORT-}" ]];then
  echo "port is deprecated. Please use KAFKA_ADVERTISED_LISTENERS instead."
  exit 1
fi



if [[ -z "$KAFKA_BROKER_ID" ]]; then
    if [[ -n "$BROKER_ID_COMMAND" ]]; then
        export KAFKA_BROKER_ID=$(eval ${BROKER_ID_COMMAND})
    else
        # By default auto allocate broker ID
        export KAFKA_BROKER_ID=-1
    fi
fi

if [[ -n "${KAFKA_JMX_OPTS-}" ]];then
  if [[ ! $KAFKA_JMX_OPTS == *"com.sun.management.jmxremote.rmi.port"*  ]];then
    echo "KAFKA_OPTS should contain 'com.sun.management.jmxremote.rmi.port' property. It is required for accessing the JMX metrics externally."
  fi
fi


if [[ -n "$KAFKA_HEAP_OPTS" ]]; then
    sed -r -i "s/(export KAFKA_HEAP_OPTS)=\"(.*)\"/\1=\"$KAFKA_HEAP_OPTS\"/g" $KAFKA_HOME/bin/kafka-server-start.sh
    unset KAFKA_HEAP_OPTS
fi



for VAR in $(env)
do
  if [[ $VAR =~ ^KAFKA_ && ! $VAR =~ ^KAFKA_HOME && ! $VAR =~ ^KAFKA_VERSION ]]; then
    kafka_translated_name=$(echo "$VAR" | sed -r "s/KAFKA_(.*)=.*/\1/g" | tr '[:upper:]' '[:lower:]' | tr _ .)
    env_var=$(echo "$VAR" | sed -r "s/(.*)=.*/\1/g")
    if egrep -q "(^|^#)${kafka_translated_name}=" $KAFKA_HOME/config/server.properties; then
        ### replace if found
        sed -r -i "s@(^|^#)($kafka_translated_name)=(.*)@\2=${!env_var}@g" $KAFKA_HOME/config/server.properties #note that no config values may contain an '@' char
    else
        ### append if not found
        echo "${kafka_translated_name}=${!env_var}" >> $KAFKA_HOME/config/server.properties
    fi
  fi
done

if [[ -n "$CUSTOM_INIT_SCRIPT" ]] ; then
  eval $CUSTOM_INIT_SCRIPT
fi

create-topics.sh 2>&1 &
exec $KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties
