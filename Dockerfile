FROM lsiobase/ubuntu:jammy

# this is probably not going to mitigate Log4Shell in many
# cases but it won't hurt
# https://logging.apache.org/log4j/2.x/security.html
ENV LOG4J_FORMAT_MSG_NO_LOOKUPS=true

# install shell2http
COPY --from=msoap/shell2http /app/shell2http /app/shell2http

# install filebot
RUN apt-get update \
 && apt-get install -y default-jre-headless libjna-java mediainfo libchromaprint-tools unrar p7zip-full p7zip-rar mkvtoolnix mp4v2-utils gnupg curl file inotify-tools \
 && rm -rvf /var/lib/apt/lists/*

ENV FILEBOT_VERSION 5.0.3

RUN curl https://get.filebot.net/filebot/FileBot_${FILEBOT_VERSION}/FileBot_${FILEBOT_VERSION}_universal.deb -o FileBot.deb \
 && dpkg -i FileBot.deb \
 && rm FileBot.deb \
 && echo "force latest 2023-08-06"

ENV HOME /data
ENV LANG C.UTF-8
ENV FILEBOT_OPTS "-Dapplication.deployment=docker -Duser.home=$HOME -DuseGVFS=false -Djava.net.useSystemProxies=false -DuseExtendedFileAttributes=false"

# initialize filebot and clean up some permissions
RUN \
  filebot -script fn:sysinfo

COPY root/ /

ENTRYPOINT ["/init"]
