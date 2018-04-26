FROM debian:9

RUN apt-get update && apt-get install -y --no-install-recommends\
        git \
        python3 \
        python3-httplib2 \
        python3-pastedeploy \
        python3-pyaudio \
        python3-setuptools \
        python3-simplejson \
        python3-sqlalchemy \
        python3-webob \
        rsync \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /srv

RUN easy_install3 PasteScript

# install & patch server
COPY ./root/anki-sync.diff /anki-sync.diff
RUN git clone -b anki_2_1 https://github.com/tsudoko/anki-sync-server.git /srv \
        && git submodule update --init \
        && git apply /anki-sync.diff \
        && python3 setup.py egg_info

COPY ./root/production.ini /srv/production.ini
COPY ./root/entrypoint.sh /entrypoint.sh

# configure file permissions 
RUN mkdir /data \
    && chmod 777 /srv /data \
    && chmod +x /entrypoint.sh

VOLUME /data
EXPOSE 27701
USER 1001

CMD /entrypoint.sh
