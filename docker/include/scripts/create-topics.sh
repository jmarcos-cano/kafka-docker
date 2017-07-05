#!/bin/bash

if [[ -z "$START_TIMEOUT" ]]; then
    START_TIMEOUT=600
fi

start_timeout_exceeded=false
count=0
step=10

KAFKA_PORT=$( echo $KAFKA_ADVERTISED_LISTENERS | grep -oE "[[:digit:]]{1,}" |head -n 1 )

WAIT_COMMAND="netstat -lnt | awk '$4 ~ /:'${KAFKA_PORT}'$/ {exit 1}'"
#run jmx on random port 9
WAIT_COMMAND="JMX_PORT=9 $KAFKA_HOME/bin/zookeeper-shell.sh ${KAFKA_ZOOKEEPER_CONNECT} <<< 'ls /brokers/ids' | awk 'NR > 1 {print $1}' RS='[' FS=']'"


while [[ -z $(eval $WAIT_COMMAND) ]]; do
    echo "[CREATE-TOPICS] - waiting for kafka to be ready"
    sleep $step;
    count=$(expr $count + $step)
    if [ $count -gt $START_TIMEOUT ]; then
        start_timeout_exceeded=true
        break
    fi
done

if $start_timeout_exceeded; then
    echo "[CREATE-TOPICS] - Not able to auto-create topic (waited for $START_TIMEOUT sec)"
    exit 1
fi

if [[ -n $KAFKA_CREATE_TOPICS ]]; then
    IFS=','; for topicToCreate in $KAFKA_CREATE_TOPICS; do
        echo "[CREATE-TOPICS] - ********* CREATING TOPICS: ********* \n [$topicToCreate]"
        IFS=':' read -a topicConfig <<< "$topicToCreate"
        if [ ${topicConfig[3]} ]; then
          JMX_PORT='' $KAFKA_HOME/bin/kafka-topics.sh --create --zookeeper $KAFKA_ZOOKEEPER_CONNECT --replication-factor ${topicConfig[2]} --partition ${topicConfig[1]} --topic "${topicConfig[0]}" --config cleanup.policy="${topicConfig[3]}" | xargs echo "[CREATE-TOPICS] - "
        else
          JMX_PORT='' $KAFKA_HOME/bin/kafka-topics.sh --create --zookeeper $KAFKA_ZOOKEEPER_CONNECT --replication-factor ${topicConfig[2]} --partition ${topicConfig[1]} --topic "${topicConfig[0]}" | xargs echo "[CREATE-TOPICS] - "
        fi
    done
else 
    echo "[CREATE-TOPICS] - ********* NO TOPICS PROVIDED *********"
fi
