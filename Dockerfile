FROM openjdk:8-jre-alpine3.7

RUN apk --no-cache upgrade; \
    apk --no-cache add tini ca-certificates shadow; \
    update-ca-certificates; \
    echo "@edge http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories; \
    apk --no-cache add gosu@edge;

ENV YOUTRACK_VERSION 2018.1.40341
RUN mkdir -p /opt/youtrack; \
	wget https://download.jetbrains.com/charisma/youtrack-${YOUTRACK_VERSION}.jar -O /opt/youtrack/youtrack.jar; \
	chmod 644 /opt/youtrack/youtrack.jar;

COPY entrypoint.sh /entrypoint.sh
RUN chmod 700 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8080/tcp

VOLUME /var/youtrack/data
VOLUME /var/youtrack/backup

LABEL maintainer="nicola@xbblabs.com"
