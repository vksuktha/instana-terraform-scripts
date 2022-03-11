variable "ibmcloud_api_key" {
    type = string
    description = "The IBM Cloud api token"
} 

variable "RESOURCE_PREFIX" {
    type = string
    description = "The prefix value for resources created by this module"
}

variable "name" {
   type = string
   description = "The name for instana VM to be created"
}
 
variable "region" {
    type = string
    description = "Geographic location of the resource (e.g. us-south, us-east)"
}

variable "zone" {
  type = string
  description = "The IBM Cloud zone"
}

variable "sales_id"{
  type = string
  description = "The agent key value to initialize Instana"
}

variable "agent_key"{
  type = string
  description = "The saled ID value to initialize Instana"
}

variable "ssh_instana_public_key_file"{
  type = string
  description = "The public key file for Instana VM"
}

variable "ssh_instana_private_key_file"{
  type = string
  description = "The private key file for Instana VM"
}
