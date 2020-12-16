FROM ubuntu:20.04

LABEL maintainer="Dimitri Vasdekis <dvasdekis@gmail.com>"

# Set Env vars
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Chicago
ENV TWS_MAJOR_VRSN=978
ENV IBC_VERSION=3.8.2
ENV IBC_INI=/root/IBController/IBController.ini
ENV IBC_PATH=/opt/IBController
ENV TWS_PATH=/root/Jts
ENV TWS_CONFIG_PATH=/root/Jts
ENV LOG_PATH=/opt/IBController/Logs
ENV JAVA_PATH=/opt/i4j_jres/1.8.0_152-tzdata2019c/bin
ENV APP=GATEWAY

# Install needed packages
RUN apt-get -qq update -y && apt-get -qq install -y unzip xvfb libxtst6 libxrender1 libxi6 socat software-properties-common curl supervisor x11vnc tmpreaper python3-pip

# Setup IB TWS
RUN mkdir -p /opt/TWS
WORKDIR /opt/TWS
COPY ./ibgateway-stable-standalone-linux-9782c-x64.sh /opt/TWS/ibgateway-stable-standalone-linux-x64.sh
RUN chmod a+x /opt/TWS/ibgateway-stable-standalone-linux-x64.sh

# Install IBController
RUN mkdir -p /opt/IBController/ && mkdir -p /opt/IBController/Logs
WORKDIR /opt/IBController/
COPY ./IBCLinux-3.8.2/  /opt/IBController/
RUN chmod -R u+x *.sh && chmod -R u+x scripts/*.sh

WORKDIR /

# Install TWS
RUN yes n | /opt/TWS/ibgateway-stable-standalone-linux-x64.sh
RUN rm /opt/TWS/ibgateway-stable-standalone-linux-x64.sh

# Must be set after install of IBGateway
ENV DISPLAY :0

# Below files copied during build to enable operation without volume mount
COPY ./ib/IBController.ini /root/IBController/IBController.ini
RUN mkdir -p /root/Jts/
COPY ./ib/jts.ini /root/Jts/jts.ini

# Overwrite vmoptions file
RUN rm -f /root/Jts/ibgateway/978/ibgateway.vmoptions
COPY ./ibgateway.vmoptions /root/Jts/ibgateway/978/ibgateway.vmoptions

# Install Python requirements
RUN pip3 install supervisor

COPY ./restart-docker-vm.py /root/restart-docker-vm.py

COPY ./supervisord.conf /root/supervisord.conf

COPY ./main.sh /root/main.sh
RUN chmod u+x /root/main.sh

CMD /root/main.sh
