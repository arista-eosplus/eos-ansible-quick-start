# Network Module Example
This repo contains example within a simple framework for leveraging the Ansible
[Ansible Network Modules](http://docs.ansible.com/ansible/latest/list_of_network_modules.html).
Spefically, it demonstrates use of:

* [net_banner](http://docs.ansible.com/ansible/latest/net_banner_module.html)
* [net_system](http://docs.ansible.com/ansible/latest/net_system_module.html)
* [net_l2_interface](http://docs.ansible.com/ansible/latest/net_l2_interface_module.html)
* [net_l3_interface](http://docs.ansible.com/ansible/latest/net_l3_interface_module.html)
* [net_vlan](http://docs.ansible.com/ansible/latest/net_vlan_module.html)

However, the overall techniques and structure can be used with all of the Ansible Network Modules.

## Playbook Variables

When writing playbooks, it is best to separate the definition of the network (i.e. the key/value pairs that define the desired end state) from the implementation of that definition. These key/value pairs can be tailored to the need of your organization or just a reflection of some convention or existing data model.  For example, the following is configuration data collected from a switch and stored in a way that can then be fed to the `net_interface` and `net_l2_interface` module:

```yaml
interfaces:
  GigabitEthernet0/1:
    enabled: True
    mtu: 1500
    mode: access
    access_vlan: 100
  GigabitEthernet0/2:
    enabled: True
    mtu: 1500
    mode: access
    access_vlan: 100
  GigabitEthernet0/3:
    enabled: True
    mtu: 1500
    mode: access
    access_vlan: 200
```

## Inventory

As the number of elements being managed grows, it is important to have a way to organize those element and their associated data.  In addition to the inventory file containing the elements, Ansible provides a hierarchical directory structure for housing vars files containing key/value pairs.  The host_vars directory contains either a file using the `inventory_hostname` of the device (e.g. switch1.yml) or a directory using the `inventory_hostname` containing multiple vars files.  For example, one vars file (e.g. interfaces.yml) can contain the interface configuration information and another vars file (e.g. vlans.yml) can contain the vlan configuration information for a particular switch.  Similarly, the group_vars directory contains vars files that apply to particular groups of devces.  Finally, an `all` file or directory can be used to store vars file that apply to all devices.

To organize and separate inventories and configuration data among separate locations or tenants, the entire directory structure can be duplicated.  For an enterprise with two data centers, for example, two completely separate directory structures can be created for DC1 and DC2:  

```
.
├── ansible.cfg
├── inventory/            # Parent directory for our environment-specific directories
│   │
│   ├── DC1/              # Contains all files specific to Data Center 1
│   │   ├── host_vars/    # device specific vars files
│   │   │   ├── router1
│   │   │   │   ├── interfaces.yml  # Device specific interface config
│   │   │   │   └── ospf.yml        # Device specific OSPF config
│   │   │   └── switch1
│   │   │       ├── interfaces.yml  # Device specific interface config
│   │   │       └── vlans.yml       # Device specific vlan config
│   │   │
│   │   ├── group_vars/   # group specific vars files
│   │   │   ├── all
│   │   │   │   └── vlans.yml       # Global VLAN config
│   │   │   ├── routers
│   │   │   │   └── ospf.yml        # Global OSPF config
│   │   │   └── switches
│   │   │       └── stp.yml         # Global STP config
│   │   └── hosts         # Contains only the hosts in the dev environment
│   │
│   └── DC2/              # Contains all files specific to Data Center 1
│       ├── host_vars/    # device specific vars files
│       │   ├── router1
│       │   │   ├── interfaces.yml  # Device specific interface config
│       │   │   └── ospf.yml        # Device specific OSPF config
│       │   └── switch1
│       │       ├── interfaces.yml  # Device specific interface config
│       │       └── vlans.yml       # Device specific vlan config
│       │
│       ├── group_vars/   # group specific vars files
│       │   ├── all
│       │   │   └── vlans.yml       # Global VLAN config
│       │   ├── routers
│       │   │   └── ospf.yml        # Global OSPF config
│       │   └── switches
│       │       └── stp.yml         # Global STP config
│       └── hosts         # Contains only the hosts in the dev environment
│
├── playbook.yml
│
└── . . .
```

## Running the example playbooks
In order to run the example playbooks, create an inventory directory using
`inventory/example` as a prototype.  The playbooks can then be run with the
command:

```
ansible-playbook -i inventory/example -u admin -k network-banner.yml
```

`-i inventory/example` tells ansible-playbook where to look for the inventory. `-u admin` specifies the username with which to connect. `-k` tell ansible-playbook to ask for the connection password.
