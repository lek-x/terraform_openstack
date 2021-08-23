# Terraform OpenStack deploying script

## Description

This is a basic terraform script which deploying VM, creating network and FW rules.

#### Attention!!!
This script was written for OpenStack cloud Provider's platform. There are no guarnties that it will works with different  OpenStack platform.


## Requrements
- Linux based OS or Windows
- OpenStack
- Terraform (>=0.14)
- Administrator acces into OpenStack

## Usage

1. Clone this repo
2. Initialize plugins
```
terraform init
```
3. Edit varriables.tf according to your values

4. Edit terraform.tfvars according to your credentials

5. Check all config
```
terraform plan
```
If all is ok
6. Deploy VM
```
terraform apply
```





## License

GNU GPL v3