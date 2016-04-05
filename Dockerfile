FROM ubuntu:14.04
MAINTAINER Chris Morandi <c.morandi@kainos.com>

RUN \
  apt-get update && \
  apt-get -y install software-properties-common && \
  echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java7-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk7-installer

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-7-oracle

RUN  apt-get update && apt-get -y upgrade && apt-get -y install redis-server

RUN \
   wget https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.7.2.deb && \
   dpkg -i elasticsearch-1.7.2.deb && \
   rm /elasticsearch-1.7.2.deb && \
   update-rc.d elasticsearch defaults

RUN adduser openlrs 
RUN echo openlrs:openlrs | chpasswd
RUN adduser openlrs sudo
RUN echo 'ALL ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER openlrs
ADD openlrs.jar /home/openlrs/bin/
ADD default.properties /home/openlrs/conf/
ADD openlrs.log /home/openlrs/log/
USER root
ADD openlrs /etc/init.d/
RUN chmod +x /etc/init.d/openlrs
RUN update-rc.d openlrs defaults
USER openlrs
CMD sudo service redis-server start && \
    sudo service elasticsearch start && \
    java -jar /home/openlrs/bin/openlrs.jar -server -Xms512m -Xmx512m -XX:MaxPermSize=256m --spring.config.location=/home/openlrs/conf/default.properties
