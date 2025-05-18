resource "azurerm_resource_group" "main" {
  name     = "rg-hylastix-infra"
  location = var.location
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-hylastix"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {
  name                 = "subnet-hylastix"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "main" {
  name                = "nsg-hylastix"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "main" {
  name                = "pip-hylastix"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  domain_name_label   = "hylastix-test"
  allocation_method   = "Static"
  sku                 = "Basic"
}

resource "azurerm_network_interface" "main" {
  name                = "nic-hylastix"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_attach" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_linux_virtual_machine" "main" {
  name                            = var.vm_name
  location                        = var.location
  resource_group_name             = azurerm_resource_group.main.name
  size                            = "Standard_B1s"
  network_interface_ids           = [azurerm_network_interface.main.id]
  admin_username                  = var.admin_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.vm_ssh_public_key
  }

  os_disk {
    name                 = "osdisk-${var.vm_name}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}
