variable "location" {
  default = "westeurope"
}

variable "vm_name" {
  default = "hylastix-vm"
}

variable "admin_username" {
  default = "azureuser"
}

variable "vm_ssh_public_key" {
  description = "SSH public key for VM"
  type        = string
}
