FROM ghostserverd/shell2http

USER root

RUN apk update

RUN apk add ca-certificates coreutils tzdata

# install filebot dependencies
RUN echo '@testing http://dl-4.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && \
    apk update && \
    apk add --no-cache \
        java-cacerts \
        java-jna \
        libzen@testing \
        libmediainfo@testing \
        openjdk8-jre-base \
        nss

WORKDIR /usr/local/bin

# add filebot postprocess
# COPY transmission-postprocess.sh transmission-postprocess.sh
# RUN chmod +rx transmission-postprocess.sh

# install filebot
COPY FileBot_4.7.7-portable.tar.xz filebot.tar.xz
RUN ls -lah
RUN tar xvf filebot.tar.xz
RUN chmod +x filebot.sh
RUN mv filebot.sh filebot

# add local files
COPY root/ /
