#!/bin/bash

mkdir /srv/salt 
mkdir /srv/salt/pki
mkdir /srv/salt/pki/master
mkdir /srv/salt/pki/minion

docker run --detach \
    --hostname salt-master.localdomain \
    --publish 4505:4505 --publish 4506:4506 \
    --name saltmaster \
    --restart always \
    --volume /srv/salt:/etc/salt \
    saltstackdocker:latest
