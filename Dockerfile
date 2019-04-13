FROM msoap/shell2http

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

CMD ["-form", "/amc", "echo ${v_path}; echo ${v_name}; echo ${v_label}; filebot -script fn:amc --output /media --action move --conflict auto -non-strict --log-file /media/amc.log --def unsorted=y music=y artwork=y subtitles=en movieFormat={plex} seriesFormat={plex} animeFormat={plex} musicFormat={plex} excludeList=\".excludes\" ut_dir=\"${v_path}\" ut_kind=\"multi\" ut_title=\"${v_name}\" ut_label=\"${v_label}\""]
