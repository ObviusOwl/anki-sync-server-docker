FROM debian:9 as builder
WORKDIR /srv

RUN apt-get update && apt-get install -y --no-install-recommends\
        ca-certificates \
        git \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# download & patch server
COPY ./root/anki-sync.diff /anki-sync.diff
RUN git clone -b master https://github.com/tsudoko/anki-sync-server.git /srv \
        && git submodule update --init \
        && git apply /anki-sync.diff

# ankisyncd doesn't use the audio recording feature of Anki
RUN sed -i '/# Packaged commands/,$d' /srv/anki-bundled/anki/sound.py


FROM debian:9
WORKDIR /srv
VOLUME /data
EXPOSE 27701

RUN apt-get update && apt-get install -y --no-install-recommends\
        python3 \
        python3-bs4 \
        python3-decorator \
        python3-markdown \
        python3-pip \
#        python3-pyaudio \
        python3-requests \
        python3-webob \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pip3 install send2trash

# copy anki source
COPY --from=builder /srv /srv

COPY ./root/ankisyncd.conf /srv/ankisyncd.conf
COPY ./root/entrypoint.sh /entrypoint.sh

# configure file permissions 
RUN mkdir -p /data \
    && chmod 777 /srv /data \
    && chmod +x /entrypoint.sh

USER 1001
CMD /entrypoint.sh
