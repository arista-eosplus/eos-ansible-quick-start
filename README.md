# Ansible + Arista Quick Start
A simple Ansible setup to get you up and running faster!

## Intro
This repo includes automated playbooks that will help you run some basic playbooks against your Arista EOS switch. This setup is not meant to be a boilerplate for production, rather, a quick and easy way to learn the basics.

## Prereqs
* git
* Ansible 2.1+ (or Ansible 2.0.1 networking preview [releases](http://releases.ansible.com/ansible-network/latest))
* A CLI user created on your switch
* An Arista EOS switch with eAPI enabled or SSH access

### A Note about Ansible Versions
Until Ansible 2.1 is uploaded to Pypi, or any of the common package managers, the
only way you can get the new modules is by running from Git source, or using one of the
special network preview [releases](http://releases.ansible.com/ansible-network/latest).
One easy method is using Pip's source install feature:

```
[sudo] pip install git+git://github.com/ansible/ansible.git@devel
```


## Getting Started

### First clone this repo

``git clone https://github.com/arista-eosplus/eos-ansible-quick-start.git``

### Run the Setup Playbook

``ansible-playbook setup_env.yaml``

You'll answer a few basic questions to help get your files setup.

```
What is the IP or FQDN of your EOS device?: 172.16.130.201
How would you like to connect to the switch? [ssh|http|https]: http
EOS Username?: admin
EOS password?:
Do we need to run 'enable' upon login? [yes|no]: no
```

Then some tasks will run to:

* Create a group_vars/all file. Notice there's a ``provider`` dict with values you entered in the prompt.
* Create a ``hosts`` file containing the host
* A ``host_vars/<host>`` with some basic vars to get you up and running.

### Run your first EOS playbook

``ansible-playbook -i hosts base_configuration.yaml -v``

You should get something like:

```
PLAY [all] *********************************************************************

TASK [Arista EOS Base Configuration] *******************************************
changed: [172.16.130.201] => {"changed": true, "responses": [{}, {}, {}, {}], "updates": ["ip name-server vrf default 8.8.8.8", "ip name-server vrf default 2.2.2.2", "hostname arista.makes.the.best.switches", "ip name-server vrf default 1.1.1.1"]}

PLAY RECAP *********************************************************************
172.16.130.201             : ok=1    changed=1    unreachable=0    failed=0
```

Cool! So by looking at the updates field we see that we configured some DNS
servers and the hostname! Easy peasy!

Run it again to see idempotency in action. That's to say, if Ansible sees that
all of the config on the switch is in the state we define in our playbook don't
make any changes!

```
PLAY [all] *********************************************************************

TASK [Arista EOS Base Configuration] *******************************************
ok: [172.16.130.201] => {"changed": false, "updates": []}

PLAY RECAP *********************************************************************
172.16.130.201             : ok=1    changed=0    unreachable=0    failed=0   
```

Notice now that the task comes back 'ok' and there are no changed items.

#### How it works

Let's break down the playbook command:

``ansible-playbook -i hosts base_configuration.yaml -v``

This says:

* Use the ansible-playbook command to run a playbook
* We use the ``-i hosts`` to specify our local ``hosts`` file instead of the default one in ``/etc/ansible/hosts``
* We want to run the ``base_configuration.yaml`` playbook
* We want to see some extra logging with ``-v`` verbosity

Let's take a look inside this playbook:

```
---
- hosts: eos_demo_group
  gather_facts: no
  connection: local

  tasks:
    - name: Arista EOS Base Configuration
      eos_template:
        src=baseconfig.j2
        provider={{ provider|default(omit) }}
```

First we specify the group of hosts that we want to run this playbook against.
In this case, it will look in the ``hosts`` file for the ``eos_demo_group``
group and run the playbook against all the hosts inside.

Then we skip generic fact gathering with ``gather_facts: no``

Importantly, we use ``connection: local``. This tells Ansible to run the modules
locally. If we didn't use this, Ansible would try and SSH into our host and look
for a bash shell. This isn't the same type of SSH connection that
we use to access the CLI.

Then we move on to tasks. In this case we simply run one task to setup some
basic config. This task uses the ``eos_template`` module to execute a Jinja
template, then compare the generated config against the EOS running-config.
If it determines there are incongruities, it will issue the needed commands to
get the switch config into the
correct state.

Let's take a look at this Jinja template, ``baseconfig.j2``:

```
hostname {{ hostname }}

{% for dns_ip in dns_servers %}
ip name-server vrf default {{ dns_ip }}
{% endfor %}
```

Jinja is pretty easy to read. The ``{{`` denote a variable to be substituted.
Ansible will look for a variable called ``hostname`` and put it in there. In
this setup, it finds it in the ``host_vars/<host>`` file. Try changing the
``hostname`` variable in ``host_vars/<host>`` and re-run your playbook to see the
hostname change (where <host> is the host FQDN/IP you provided earlier).

Then we get to some cool Jinja control logic. If you've worked with Python,
the loop we have here should look very familiar. Ansible automatically takes
the ``dns_servers`` list from ``group_var/all.yaml`` and creates a config line
for each entry.  What do you think would happen if you created a ``dns_servers``
list in your ``host_vars/<host>`` file? Give it a try and re-run the playbook!
