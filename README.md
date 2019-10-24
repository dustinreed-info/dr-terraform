#  Dustin Reed Info - Terraform

## Requirements
Amazon Linux2

AWS Account

An Ec2 SSH Key Pair with the public key located on the terraform host in the
~/.ssh/ directory.  You can change the key name and location in vars.tf.

## Installation

Install terraform and extract it to ~/bin dir.
```
curl -O https://releases.hashicorp.com/terraform/0.12.12/terraform_0.12.12_linux_amd64.zip
mkdir ~/bin
unzip terraform_0.12.12_linux_amd64.zip -d ~/bin/
```
Install git
```
sudo yum install git -y
```
Run aws configure if you do not have default credentials configured.
```
aws configure
```

## Verify Installation
Ensure that ~/bin/ exists in $PATH
```
terraform --version
```

## Configure website and initialize Terraform
Clone dr-terraform repo and navigate to directory.
Initialize Terraform
```
git clone https://github.com/dustinreed-info/dr-terraform.git
cd ~/dr-terraform
terraform init
```

## Plan Terraform execution
Run terraform plan and verify there are no conflicts or errors with existing resources.
```
terraform plan
```

## Apply Terraform

```
terraform apply
```

You can also specify the public key name and location when running terraform apply.
```
terraform apply -var="key_name=dr-tf-key" var="public_key_path=~/.ssh/dr-tf-key.pub"
```
