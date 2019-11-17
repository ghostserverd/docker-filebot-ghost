# private-docker-filebot-ghost
filebot docker with s6 and shell2http

call the AMC script via http

# command example
```
curl --data-urlencode name="<some_name>" --data-urlencode path="/downloads/complete/<some_name>" --data-urlencode label="N/A" http://192.168.1.11:7070/amc
```

# example compose
```
  filebot:
    image: ghostserverd/filebot:4.8.x
    container_name: filebot
    restart: always
    ports:
      - "7070:7070"
    environment:
      - PUID=1001
      - PGID=1001
      - FILEBOT_PORT=7070
      - FILEBOT_FORMAT={plex} - {hd}
      - FILEBOT_ACTION=duplicate
      - FILEBOT_CONFLICT=auto
      - SHARE_BASE_PATH=/server
      - OPEN_SUB_USER=someuser
      - OPEN_SUB_PASS=somepass
      - TZ=America/Los_Angeles
    volumes:
      - /server/config/filebot:/config
      - /server/downloads:/downloads
      - /server/media:/server/media
```
