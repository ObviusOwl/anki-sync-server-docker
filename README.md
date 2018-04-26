# Anki sync server single user docker container

This container serves the unofficial anki-sync-server in single user mode.

The source code of the sync server can be found on [github](https://github.com/tsudoko/anki-sync-server.git). Branch `anki_2_1` is checked out, which is a port to python3 of the [original server](https://github.com/dsnopek/anki-sync-server).

This container is single user only: on start up a user is created according to the environment variables.  

# Usage

The container takes these environment variables:

- `ANKI_USER`
- `ANKI_PASSWORD`

The http server for syncing is exposed on port `27701`

Build and run the server locally:

```
docker build -t anki-sync-server:latest .
docker run -it --rm -p 27701:27701 -e ANKI_USER=test -e ANKI_PASSWORD=test anki-sync-server:latest
```

# Pointing Anki at the sync server

## Anki desktop

Crating a custom plugin:

```
mkdir -p ~/.local/share/Anki2/addons21/sync
vim ~/.local/share/Anki2/addons21/sync/__init__.py
```

```
import anki.sync
anki.sync.SYNC_BASE = 'http://localhost:27701/'
anki.sync.SYNC_MEDIA_BASE = 'http://localhost:27701/msync/'
```

Or using a custom start script:

```
#!/usr/bin/env python2

import sys
sys.path[0] = '/usr/share/anki'

import anki.sync
anki.sync.SYNC_BASE = 'http://127.0.0.1:27701/'
anki.sync.SYNC_MEDIA_BASE = 'http://127.0.0.1:27701/msync/'

import aqt
aqt.run()
```

## Ankidroid

Quoting https://github.com/dsnopek/anki-sync-server/blob/master/README.rst

As of AnkiDroid 2.6 the sync server can be changed in the settings:

1. Open the Settings screen from the menu
2. In the Advanced section, tap on Custom sync server
3. Check the Use custom sync server box
4. Change the Sync URL and Media sync URL to the values described above
5. The next sync should use the new sync server (if your previous username or password does not match AnkiDroid will ask you to log in again)

# Openshift template

The openshift template has the following parameters:

```yaml
- name: ANKI_SYNC_IMAGE_STREAM_TAG
  description: Name of the ImageStreamTag to be used for the image.
  displayName: Name of the docker image and tag
  value: "anki-sync-server:latest"
- name: APP_STORAGE_SIZE
  description: Volume space available for data, e.g. 512Mi, 2Gi.
  displayName: Volume size
  required: true
- name: APP_ROUTE_HOST
  description: Hostname use for the router object
  value: anki-sync-jojo.apps.lan.terhaak.de
  required: true
- name: APP_ROUTE_PATH
  description: Path use for the router object
  value: 
- name: ANKI_USER
  description: Username for anki sync login
  displayName: Anki username
  required: true
- name: ANKI_PASSWORD
  description: Password for anki sync login
  displayName: Anki password
  required: true
```

The template will create:

- *DeploymentConfig* with on container
- *Service*
- *Route*
- *PersistentVolumeClaim* for storage of the collections
- *Secret* storing username and password

A container will automatically be deployed when a docker image is pushed to
the openshift registry in the namespace of the openshift project tagged with 
the tag (`image-name:tag`) specified when the template was instantiated. 

Apache reverse proxy configuration to route from your main site to openshift:

```
RedirectPermanent "/anki" "https://www.example.com/anki/"
<LocationMatch "^/anki/(.*)$" >
        ProxyPassReverse "http://anki-sync.apps.example.com/$1"
        ProxyPass "http://anki-sync.apps.example.com/$1"
</LocationMatch>
```