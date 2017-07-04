

# list active brokers


bin/zookeeper-shell.sh localhost:2181 <<< "ls /brokers/ids"



# Single broker

### create topic (single broker)

bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic test


### list topics

bin/kafka-topics.sh --list --zookeeper localhost:2181


### Describe topic

bin/kafka-topics.sh --describe --zookeeper localhost:2181 --topic test


> Extra: describe topics
> topics=$(bin/kafka-topics.sh --list --zookeeper localhost:2181 2>/dev/null); for topic in $topics; do bin/kafka-topics.sh --describe --zookeeper localhost:2181 --topic ${topic}; echo -e "\n\n" ;done


### Produce some messages

bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test


### Consume message in different terminal

bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --from-beginning --topic test 


---------
# Multi-broker cluster

### create multi-broker topic

bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 2 --partition 1 --topic distro

### Describe topics

bin/kafka-topics.sh --describe --zookeeper localhost:2181 --topic distro


### Produce messages in sync mode.

bin/kafka-console-producer.sh --broker-list kafka:9092 kafka-2:9093 --sync --topic distro




------
# Kafka Manager

create automatically a cluster

``` bash
curl localhost:9000/clusters --data "name=main&zkHosts=zookeeper:2181&kafkaVersion=0.9.0.1" -X POST
```



#### Related Issues

- *MAIN* https://stackoverflow.com/questions/41868161/kafka-in-kubernetes-cluster-how-to-publish-consume-messages-from-outside-of-kub

- https://stackoverflow.com/questions/42998859/kafka-server-configuration-listeners-vs-advertised-listeners

- https://issues.jboss.org/browse/DBZ-39?_sscc=t
