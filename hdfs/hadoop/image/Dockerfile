FROM openjdk:8-jdk

ENV HADOOP_VERSION 3.3.2
ENV HADOOP_HOME=/opt/hadoop

ENV HADOOP_COMMON_HOME=${HADOOP_HOME} \
    HADOOP_HDFS_HOME=${HADOOP_HOME} \
    HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop \
    PATH=${PATH}:${HADOOP_HOME}/bin

RUN curl --silent --output /tmp/hadoop.tgz https://ftp-stud.hs-esslingen.de/pub/Mirrors/ftp.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz && tar --directory /opt -xzf /tmp/hadoop.tgz && rm /tmp/hadoop.tgz
RUN ln -s /opt/hadoop-${HADOOP_VERSION} ${HADOOP_HOME}

WORKDIR $HADOOP_HOME

# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000

#Other ports
EXPOSE 49707 2122
