# About

This folder shall be used to provision and orchestrate the performance tests for the consensus project in
Amazon Web Services (aws).

## Prerequisites

- Make sure you have an [AWS](https://aws.amazon.com/) account and configured according to amazon's best practices and 
recommendations. Also make sure you are eligible for using aws free-tier and/or you can pay for the resources you use.
- Install [aws cli](https://aws.amazon.com/cli/).
- Install [terraform](https://developer.hashicorp.com/terraform/install).
- Install [ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).
- (Optional) Install [R](https://www.r-project.org/) to regenerate the plots for the performance tests on your machine.

## IAM Policy Information

Although, in theory you can create an aws user with unbounded permissions, we highly suggest you assign a policy with 
the least number of privileges required to run the aws api calls for the user. We have created an 
[example IAM policy](./iam_example_policy.json) for which you can use to run terraform commands configured 
for this project.

## Preparing AWS credentials

Almost all the tools used in this folder group needs to be configured properly with aws credentials to be able to
make the required api calls to amazon web services. There are many ways of configuring the credentials and adopting 
the configuration of the tools to the method you choose.

We prefer creating a profile called `consensus` in the `~/.aws/credentials` file as follows:
```
[consensus]
region=eu-west-1
aws_access_key_id=<your aws access key id>
aws_secret_access_key==<your aws secret access key>
```

After that, you should generate a public and private key for the aws ec2 machine instances. We recommend placing the
private key in `~/.ssh/aws/aws_instance_key.pem`, which will be used by Ansible. If you use a different location,
then make sure you edit the [env_setup.sh](env_setup.sh) file:
```
# find the following line and change the path to the private key.
export ANSIBLE_PRIVATE_KEY_FILE=<path to the private key>
```
The public key should be placed in `./provision/access/aws_instance_key.pub`.

Finally, review [env_setup.sh](env_setup.sh) and execute the following:
```
chmod +x env_setup.sh
source env_setup.sh
```

## Guide
After preparing your aws credentials appropriately, you can check out the guides:
1. For provisioning the infrastructure, follow the guide at [provision](./provision) folder.
2. For orchestrating the ec2 instances and running the performance tests use the [orchestrate](./orchestrate) folder.

### Convenience Scripts

You can find two scripts to conveniently initialize ([stack_init.sh](./stack_init.sh)) and destroy 
([stack_destroy.sh](./stack_destroy.sh)) the aws environment. You can use them like the following (NB! If you are running the setup
for the first time, we recommend executing each line of the script line-by-line to detect possible
issues you might encounter):
```
# make the scripts executable.
chmod +x *.sh

# initialize the stack (loads environment variables for the current shell as well).
source stack_init.sh

# destroy the stack.
./stack_destroy.sh
```