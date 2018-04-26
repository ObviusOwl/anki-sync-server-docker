#!/bin/bash

export PYTHONPATH="/srv:/srv/anki-bundled"

if [ -z "$ANKI_USER" ]; then
  echo "Please set the environment variable ANKI_USER"
  exit 1
fi

if [ -z "$ANKI_PASSWORD" ]; then
  echo "Please set the environment variable ANKI_PASSWORD"
  exit 1
fi

echo -e "$ANKI_PASSWORD\n" | /srv/ankiserverctl.py adduser "$ANKI_USER"

/srv/ankiserverctl.py debug 2>&1 | grep -v -E "^INFO.*$"
