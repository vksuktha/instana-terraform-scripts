# instana-terraform-scripts
## Example usage
```
module "instana_instance" {
  source = "github.com/vksuktha/instana-terraform-scripts?ref=v1.0.0"

  name                 = var.resource_prefix
  resource_group_name  = var.resource_group_name
  region               = var.region
  ibmcloud_api_key     = var.ibmcloud_api_key
  subnet_name          = var.subnet_name
  vpc_name             = var.vpc_name
  zone                 = var.zone
  sales_id             = var.sales_id
  agent_key            = var.agent_key
  ssh_instana_public_key_file = var.ssh_instana_public_key_file
  ssh_instana_private_key_file = var.ssh_instana_private_key_file
}
```
