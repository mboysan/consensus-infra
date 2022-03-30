# Prerequisites
- An aws account. Also make sure you are eligible for using aws free-tier and/or you can pay for the resources you use.
- [aws cli](https://aws.amazon.com/cli/)
- [ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- [python3, pip3, boto3](https://stackoverflow.com/a/59073019)

# Confirm Installation

## Preparing AWS credentials

1. create a file called `credentials` under home dir `~/.aws/`
2. edit the file with the following contents:
```
[default]
aws_access_key_id=<your_aws_access_key>
aws_secret_access_key=<your_aws_secret_key>
```

## List AWS resources
execute: 
```
ansible-inventory -i inventory_aws_ec2.yaml --graph
```

# Setting ansible.cfg location

## Prepare
1. Make sure you view the contents of `./ansible.cfg`
2. Make any necessary changes like modifying the aws private-key location.

## Setting the config location

### Method-1 (preferred)
1. Backup default config under `/etc/ansible/ansible.cfg`
2. Move `./ansible.cfg` under `/etc/ansible` directory
3. Ansible should pick up this configuration by default

### Method-2 (security risk)
1. Make sure you read [security related issues with this method](https://docs.ansible.com/ansible/devel/reference_appendices/config.html#cfg-in-world-writable-dir)
2. run 
```
export ANSIBLE_CONFIG=./ansible.cfg
```
3. Ansible should now the current dir.

## Verify
```
ansible-config view
```

# Run the playbook
```
ansible-playbook play.yaml
```

# Useful commands
```
# see resources as list
ansible-inventory -i inventory_aws_ec2.yaml --list

# see resources as graph
ansible-inventory -i inventory_aws_ec2.yaml --graph

# ping a group of nodes
ansible nodes -i inventory_aws_ec2.yaml -m ping --private-key=~/.ssh/aws_instance_key.pem

# ping a group of nodes as login user 'ubuntu'
ansible nodes -i inventory_aws_ec2.yaml -m ping --private-key=~/.ssh/aws_instance_key.pem -u ubuntu

# run playbook
ansible-playbook play.yaml -i inventory_aws_ec2.yaml --private-key=~/.ssh/aws_instance_key.pem -u ubuntu
```