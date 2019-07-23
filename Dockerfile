FROM openjdk:8-jre

# install shell2http
COPY --from=msoap/shell2http /app/shell2http /app/shell2http

# install filebot
ENV FILEBOT_VERSION 4.7.9


WORKDIR /usr/share/filebot

# RUN FILEBOT_SHA256=892723dcec8fe5385ec6665db9960e7c1a88e459a60525c02afb7f1195a50523 \
#  && FILEBOT_PACKAGE=filebot_${FILEBOT_VERSION}_amd64.deb \
#  && curl -L -O https://downloads.sourceforge.net/project/filebot/filebot/FileBot_$FILEBOT_VERSION/$FILEBOT_PACKAGE \
#  && echo "$FILEBOT_SHA256 *$FILEBOT_PACKAGE" | sha256sum --check --strict \
#  && dpkg -i $FILEBOT_PACKAGE \
#  && rm $FILEBOT_PACKAGE

ARG FILEBOT_SHA256="892723dcec8fe5385ec6665db9960e7c1a88e459a60525c02afb7f1195a50523"
ARG FILEBOT_PACKAGE="filebot_${FILEBOT_VERSION}_amd64.deb"
COPY ${FILEBOT_PACKAGE} ./
RUN echo "$FILEBOT_SHA256 *$FILEBOT_PACKAGE" | sha256sum --check --strict \
 && dpkg -i $FILEBOT_PACKAGE \
 && rm $FILEBOT_PACKAGE

RUN apt-get update && apt-get install -y \
    mediainfo \
    libchromaprint-tools \
    file \
    curl \
    inotify-tools \
 && rm -rf /var/lib/apt/lists/*


ENV DOCKER_DATA /data
ENV DOCKER_VOLUME /volume1


ENV HOME $DOCKER_DATA
ENV JAVA_OPTS "-DuseGVFS=false -Djava.net.useSystemProxies=false -Dapplication.deployment=docker -Dapplication.dir=$DOCKER_DATA -Duser.home=$DOCKER_DATA -Djava.io.tmpdir=$DOCKER_DATA/tmp -Djava.util.prefs.PreferencesFactory=net.filebot.util.prefs.FilePreferencesFactory -Dnet.filebot.util.prefs.file=$DOCKER_DATA/prefs.properties"


WORKDIR $DOCKER_DATA

VOLUME ["$DOCKER_DATA", "$DOCKER_VOLUME"]

# install s6 overlay
ARG OVERLAY_VERSION="v1.22.0.0"
ARG OVERLAY_ARCH="amd64"

ARG DEBIAN_FRONTEND="noninteractive"

RUN \
  curl -o \
  /tmp/s6-overlay.tar.gz -L \
    "https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.gz" && \
  tar xfz \
    /tmp/s6-overlay.tar.gz -C / && \
  echo "**** create abc user and make our folders ****" && \
  useradd -u 911 -U -d /config -s /bin/false abc && \
  usermod -G users abc && \
  mkdir -p \
  /app \
  /config \
  /defaults && \
  echo "**** cleanup ****" && \
  apt-get clean

COPY root/ /

ENTRYPOINT ["/init"]
