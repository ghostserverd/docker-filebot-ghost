FROM lsiobase/ubuntu:bionic

# install shell2http
COPY --from=msoap/shell2http /app/shell2http /app/shell2http

# install filebot
RUN apt-get update \
 && apt-get install -y default-jre-headless libjna-java mediainfo libchromaprint-tools unrar p7zip-full p7zip-rar mkvtoolnix mp4v2-utils gnupg curl file inotify-tools \
 && rm -rvf /var/lib/apt/lists/*

RUN apt-key adv --fetch-keys https://raw.githubusercontent.com/filebot/plugins/master/gpg/maintainer.pub  \
 && echo "deb [arch=all] https://get.filebot.net/deb/ universal main" > /etc/apt/sources.list.d/filebot.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends filebot \
 && rm -rvf /var/lib/apt/lists/*

ENV DOCKER_DATA /data

VOLUME $DOCKER_DATA

ENV HOME /data
ENV LANG C.UTF-8
ENV FILEBOT_OPTS "-DuseGVFS=false -Djava.net.useSystemProxies=false -Dapplication.deployment=docker -Dapplication.dir=$DOCKER_DATA -Duser.home=$DOCKER_DATA -Djava.io.tmpdir=$DOCKER_DATA/tmp -Djava.util.prefs.PreferencesFactory=net.filebot.util.prefs.FilePreferencesFactory -Dnet.filebot.util.prefs.file=$DOCKER_DATA/prefs.properties" 

# initialize filebot and clean up some permissions
RUN \
  filebot -script fn:sysinfo && \
  mkdir -p ${DOCKER_DATA}/.filebot

COPY root/ /

ENTRYPOINT ["/init"]
