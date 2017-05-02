FROM ansible/ansible:ubuntu1604

RUN apt-get update
Run apt-get install -y gcc make python-dev libssl-dev libffi-dev
RUN pip install --upgrade pip
RUN pip install ansible==2.2.0.0
RUN pip install -U paramiko PyYAML Jinja2 httplib2 six

RUN apt-get install -y iputils-ping
RUN apt-get install -y net-tools
RUN apt-get install -y tcpdump
RUN apt-get install -y vim

ENTRYPOINT /bin/bash
