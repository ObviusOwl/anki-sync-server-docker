FROM debian:9

RUN apt-get update && apt-get install -y --no-install-recommends\
        git \
        locales \
        python3 \
        python3-bs4 \
        python3-decorator \
        python3-markdown \
        python3-pip \
#        python3-pyaudio \
        python3-requests \
        python3-webob \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /srv

RUN pip3 install send2trash

# install & patch server
COPY ./root/anki-sync.diff /anki-sync.diff
RUN git clone -b master https://github.com/tsudoko/anki-sync-server.git /srv \
        && git submodule update --init \
        && git apply /anki-sync.diff

# ankisyncd doesn't use the audio recording feature of Anki
RUN sed -i '/# Packaged commands/,$d' /srv/anki-bundled/anki/sound.py

COPY ./root/ankisyncd.conf /srv/ankisyncd.conf
COPY ./root/entrypoint.sh /entrypoint.sh

# configure file permissions 
RUN mkdir /data \
    && chmod 777 /srv /data \
    && chmod +x /entrypoint.sh

# anki-desktop needs a UTF-8 locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen

VOLUME /data
EXPOSE 27701
USER 1001

CMD /entrypoint.sh
