# Prerequisites
- An aws account. Also make sure you are eligible for using aws free-tier and/or you can pay for the resources you use.
- [packer](https://www.packer.io/)
- [aws cli](https://aws.amazon.com/cli/) 

# Creating your AMI on AWS

## Preparing AWS credentials

### Method-1 (Preferred)
1. create a file called `credentials` under home dir `~/.aws/`
2. edit the file with the following contents:
```
[default]
aws_access_key_id=<your_aws_access_key>
aws_secret_access_key=<your_aws_secret_key>
```

### Method-2
1. Create a script called `secrets.sh` with the contents:
```
#!/bin/bash
export ACCESS_KEY=<your_aws_access_key>
export SECRET_KEY=<your_aws_secret_key>
```
2. make executable `chmod +x secrets.sh` 
3. and run with `source secrets.sh`

## Building AMI image
1. navigate to ami dir: `cd aws/ami/`
2. run `packer build packer.json`
   
This will create an ami with all the dependencies installed with the [`ami-bootstrap.sh`](ami-bootstrap.sh) script.

## Validating
1. Navigate to your aws account -> EC2.
2. Create a new instance and inspect the ami created with name: **ami-full-deps**

