# instana-terraform-scripts 

The script in this repository creates a Resource group, VPC, Subnet, Public Gateway and VM (Virtual Server Instance) with essential security groups, required for Instana installation in the target IBM Cloud account and installs Instana in it.

## Clone the repository
```
git clone https://github.com/vksuktha/instana-terraform-scripts
```
## Generate SSH key 
Instana VM requires an SSH Key, so run the following command to generate it:

```
cd instana-terraform-scripts
chmod 755 create-ssh-keys.sh
./create-ssh-keys.sh
```
Public and private ssh key pair files - `ssh-instana.pub` and `ssh-instana` get generated in the project directory.

## Provide variable values
Rename the variable template file `terraform.tfvars.tmpl` to `terraform.tfvars` file and assign values to all variables.
```
cp terraform.tfvars.tmpl terraform.tfvars
```
Then edit the `terraform.tfvars` file to define the following keys:
```
ibmcloud_api_key=""                             # IBM Cloud Account API Key
RESOURCE_PREFIX="instana"                       # Prefix value which will be added to all resources
region="us-south"                               # IBM Cloud region 
zone="us-sount-1"                               # IBM Cloud zone
sales_id="xxxx"                                 # Instana license sales_id
agent_key="xxxxxxxx"                            # Instana license agent_key
name="instana-vm"                               # The name for instana VM to be created"
ssh_instana_public_key_file="ssh-instana.pub"   # SSH PUBLIC KEY file path
ssh_instana_private_key_file="ssh-instana"      # SSH PRIVARTE KEY file path
```

## Module details
The code available in this [repository](https://github.com/vksuktha/instana-terraform-scripts) can be invoked as a module as follows: 
```
module "instana_instance" {
  source = "github.com/vksuktha/instana-terraform-scripts?ref=v1.0.2"

  name                 = var.name
  RESOURCE_PREFIX      = var.RESOURCE_PREFIX
  ibmcloud_api_key     = var.ibmcloud_api_key
  region               = var.region
  zone                 = var.zone
  sales_id             = var.sales_id
  agent_key            = var.agent_key
  ssh_instana_public_key_file = var.ssh_instana_public_key_file
  ssh_instana_private_key_file = var.ssh_instana_private_key_file
}
```


## Install Instana
To create VM and install Instana execute following command:
```
terraform init
terraform plan
terraform apply -auto-approve
```

Instana credentials and IP address of the VM would be displayed after VM is provisioned and Instana setup is complete.

**Note**: The user of the provided API key, needs to have privileges to create resource-group, vpc, sunet, ssh-key and VSI instances and also IP-spoofing Operator in IBM Cloud. For enabling IP-Spoofing Operator privilege check `IAM prerequisites` section in this [blog](https://www.ibm.com/cloud/blog/network-function-virtualization-nfv-using-vpc-routing).

## Access Instana

Instana can be accessed though the browser `https://<IP_Address>`. Credentials to access Instana can also be found in the VM at `/instana/instana_credentials.txt`

Instana VM can be accessed using the SSH private key file generated in the project directory earlier.
```
ssh -i ssh_instana root@<IP_Address>
```
