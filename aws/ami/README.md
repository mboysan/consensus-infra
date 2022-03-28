# Prerequisites
- An aws account. Also make sure you are eligible for using aws free-tier and/or you can pay for the resources you use.
- [packer](https://www.packer.io/)
- [aws cli](https://aws.amazon.com/cli/) 

# Creating your AMI on AWS

1. Create a script called `secrets.sh` with the contents:
```
#!/bin/bash
export ACCESS_KEY=<your_aws_access_key>
export SECRET_KEY=<your_aws_secret_key>
```
2. make executable `chmod +x secrets.sh` and run with `source secrets.sh`
3. navigate to ami dir: `cd aws/ami/`
4. run `packer build packer.json`

This will create an ami with all the dependencies installed with the [`ami-bootstrap.sh`](ami-bootstrap.sh) script.

To verify:
1. Navigate to your aws account -> EC2.
2. Create a new instance and select the ami created with name: **ami-full-deps**

