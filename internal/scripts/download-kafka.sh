#!/bin/sh


KAFKA_VERSION=0.10.2.1
SCALA_VERSION=2.12


echo "Downloading KAFKA-${SCALA_VERSION}-${KAFKA_VERSION}"
#### configuration
kafka_tar=kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz
preferred_mirror_url=$(curl --stderr /dev/null https://www.apache.org/dyn/closer.cgi\?as_json\=1 | jq -r '.preferred')
kafa_download_url="${preferred_mirror_url}kafka/${KAFKA_VERSION}/${kafka_tar}"

#### download artifacts and get md5sum
remote_md5=$(wget -O- http://www-us.apache.org/dist/kafka/${KAFKA_VERSION}/${kafka_tar}.md5 | tr -d '[:space:]'| tr ":" " " |awk '{print toupper($2)}') 
wget -q "${kafa_download_url}" -O "/tmp/${kafka_tar}" 



#### check md5sum
md5sum /tmp/${kafka_tar} | awk '{print toupper($1)}' | tee /tmp/md5.txt

grep ${remote_md5} /tmp/md5.txt || echo "[ERROR] MD5sum "

ls /tmp
