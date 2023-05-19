# About

This module shall be used to run the performance tests on the infrastructure [provision](../provision)ed.

## Prerequisites
### On Controller Machine
- Read the [readme](../README.md) at the parent dir.
- Install [ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- Install [python3, pip3, boto3](https://stackoverflow.com/a/59073019).
- Ubuntu for control machine (optional): to run [prepare_orchestration.sh](prepare_orchestration.sh) script.

Note: all the commands listed in the following sections shall be executed in this directory (working directory).

## Setting ansible.cfg location

The [ansible.cfg](ansible.cfg) file located in this directory shall be used for the orchestration. Make sure you view
the contents of this file and make changes (modifying aws private-key location etc.) where necessary.

Following are the two main methods that can be used to set up the config location.

### Method-1 (preferred)
1. Backup default config under `/etc/ansible/ansible.cfg`.
2. Move `./ansible.cfg` under `/etc/ansible` directory.
3. Ansible should pick up this configuration by default.

### Method-2 (security risk)
1. Make sure you read [security related issues with this method](https://docs.ansible.com/ansible/devel/reference_appendices/config.html#cfg-in-world-writable-dir)
2. Run 
```
export ANSIBLE_CONFIG=./ansible.cfg
```
3. Ansible should pick up the config in the current directory.

### Verifying

Execute the following to verify if ansible was able to pick up the correct configuration:
```
ansible-config view
```

## Creating the Ansible Inventory

We need to create the inventory of servers to allow ansible to successfully ssh and execute commands. You can populate
the inventory manually by connecting to your aws account and getting public ip addresses of all the instances and
placing them into [inventory/aws_ec2_static.ini](inventory/aws_ec2_static.ini) file (you can use this file as a sample). 
Or, you can simply run the [prepare_orchestration.sh](prepare_orchestration.sh) script located in this directory, given 
that you have successfully [provision](../provision)ed the aws stack.
```
# run for preparing the ansible setup.
./prepare_orchestration.sh
```

### Confirm Inventory Setup

You can confirm if the inventory setup works properly by executing:
```
ansible-inventory -i inventory/aws_ec2_static.ini --graph
```

## Information on Playbooks

Following is the naming pattern used for the playbooks.
- `P<X>_<name>`: Playbooks starting with this naming pattern is used to prepare the hosts by installing 
necessary software and project dependencies, i.e. `P` stands for "Prepare".
- `S<X>_<name>`: Playbooks starting with this naming pattern is used for reference purposes only, i.e. `S` stands
for "Sample". We suggest using `T` playbooks (as described next) for performing the load tests.
- `T<X>_<name>`: Playbooks starting with this naming pattern is used to perform the load tests, 
i.e. `T` stands for "Test".
- `W<X>_<name>`: Playbooks starting with this naming pattern is used to work on the collected metrics,
  i.e. `W` stands for "Work". They should be run after all the tests are completed.
- `util_<name>`: Playbooks starting with this naming pattern is used as utility tasks such as starting, 
stopping, cleanup etc. of hosts that are shared by all other playbooks.

With the above information, one should first execute the playbooks that start with `P` with the numerical order defined.
Only then, actual test playbooks shall be run, i.e. playbooks that start with `T`. The execution order of `T` playbooks
are not important.

Once you have prepared the ansible inventory, playbooks can be executed like:
```
ansible-playbook playbooks/<playbook-name>
```

# Useful commands
```
# see resources as list
ansible-inventory -i inventory/aws_ec2.yaml --list

# see resources as graph
ansible-inventory -i inventory/aws_ec2.yaml --graph

# ping all
ansible all -m ping

# ping a group of nodes
ansible nodes -i inventory/aws_ec2_static.ini -m ping --private-key=~/.ssh/aws_instance_key.pem

# ping a group of nodes as login user 'ubuntu'
ansible nodes -i inventory/aws_ec2_static.ini -m ping --private-key=~/.ssh/aws_instance_key.pem -u ubuntu

# running a playbook
ansible-playbook play.yaml

# run playbook
ansible-playbook play.yaml -i inventory/aws_ec2_static.ini --private-key=~/.ssh/aws_instance_key.pem -u ubuntu

# run playbook with extra vars (--extra-vars or -e param)
ansible-playbook play.yaml -e "key=value"
ansible-playbook playbooks/util_start_nodes.yaml -e 'cli_params="protocol=raft"'
```