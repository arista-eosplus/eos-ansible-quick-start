FROM ansible/ansible:ubuntu1604

RUN pip install --upgrade pip
RUN pip install paramiko PyYAML Jinja2 httplib2 six
RUN pip install ansible

ENTRYPOINT /bin/bash
