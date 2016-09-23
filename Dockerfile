FROM ansible/ansible:ubuntu1604

RUN pip install --upgrade pip
RUN pip install paramiko PyYAML Jinja2 httplib2 six
RUN pip install ansible

RUN apt-get install -y iputils-ping
RUN apt-get install -y net-tools
RUN apt-get install -y tcpdump
RUN apt-get install -y vim

ENTRYPOINT /bin/bash
