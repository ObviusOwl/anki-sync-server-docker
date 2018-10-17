#!/bin/bash

export LANG="C.UTF-8"
export LANGUAGE="C.UTF-8"
export LC_ALL="C.UTF-8"

if [ -z "$ANKI_USER" ]; then
  echo "Please set the environment variable ANKI_USER"
  exit 1
fi

if [ -z "$ANKI_PASSWORD" ]; then
  echo "Please set the environment variable ANKI_PASSWORD"
  exit 1
fi

echo -e "$ANKI_PASSWORD\n" | python3 /srv/ankisyncctl.py adduser "$ANKI_USER"

python3 -u -m ankisyncd
