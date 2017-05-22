#  DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER
#
# Copyright 2017 Juniper Networks, Inc. 
# All rights reserved.
#
# Licensed under the Juniper Networks Script Software License (the "License").
# You may not use this script file except in compliance with the License, which is located at
# http://www.juniper.net/support/legal/scriptlicense/
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# Please make sure to run this file as a root user

from ubuntu:14.04
MAINTAINER Tony Chan <tonychan@juniper.net>

ARG DEBIAN_FRONTEND=noninteractive

# Editing sources and update apt.
RUN echo "deb http://mirror.kdc.jnpr.net/ubuntu trusty main universe multiverse restricted" > /etc/apt/sources.list && \
  echo "deb http://mirror.kdc.jnpr.net/ubuntu trusty-security main universe multiverse restricted" >> /etc/apt/sources.list && \
  apt-get update && \
  apt-get upgrade -y -o DPkg::Options::=--force-confold

# Packages for PyEZ and SaltStack installation
RUN apt-get install -y --force-yes \
  git git-core curl python-dev \
  libssl-dev libxslt1-dev libxml2-dev libxslt-dev \
  libffi6=3.1~rc1+r3.0.13-12 libffi-dev \
  openssh-server locate vim python-m2crypto \
  build-essential

# Install PIP via source. Fixed by @ntwrkguru
RUN curl https://bootstrap.pypa.io/get-pip.py | python

### Packages for 64bit systems
###
# For 64bit systems one gets "usr/bin/ld: cannot find -lz" at PyEZ installation, solution install lib32z1-dev and zlib1g-dev
# Note: Because sh -c is executed via Docker, it is not use == but =
###
RUN if [ "$(uname -m)" = "x86_64" ]; then apt-get install -y lib32z1-dev zlib1g-dev; fi

# Installing PyEZ (and its hidden dependencies) and jxmlease for SaltStack salt-proxy
RUN pip install regex junos-eznc jxmlease cryptography pyOpenSSL certifi idna urllib3 --upgrade

### Pull master saltstack branches
WORKDIR "/root"
RUN git clone https://github.com/saltstack/salt.git
WORKDIR "/root/salt"
RUN git remote add upstream https://github.com/saltstack/salt.git
RUN git fetch --tags upstream
WORKDIR "/root"
#RUN virtualenv --system-site-packages /root/venv_salt
#RUN /bin/bash -c "source /root/venv_salt/bin/activate ; pip install pyzmq PyYAML pycrypto msgpack-python jinja2 psutil futures tornado ; pip install -e ./salt"
RUN pip install pyzmq PyYAML pycrypto msgpack-python jinja2 psutil futures tornado
RUN pip install -e ./salt

### Packages needed for junos_syslog.py SaltStack engine
RUN pip install pyparsing twisted

### Replacing salt-minion configuration
#RUN sed -i "s/^#master: salt/master: localhost/;s/^#id:/id: minion/" /etc/salt/minion

#Slim the container a litte.
#RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/install_salt.sh

#RUN pip install fabric

#COPY bin/startup.py /etc/salt/bin/
#COPY bin/entrypoint.sh /

#ENTRYPOINT ["/entrypoint.sh"]
