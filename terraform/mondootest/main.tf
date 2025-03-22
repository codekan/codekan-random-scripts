provider "azurerm" {
  features {}
  subscription_id = var.subscriptionID
}

# Variablen initialisieren - Alles ohne Default wird gepromptet beim Deployen
variable "resource_group_name" {
  default = "mondoo_test_resource_group"
}

variable "location" {
  default = "centralindia"
} 
# Azure Subscription ID abfragen - Muss manuell erstellt werden
variable "subscriptionID" {
  description = "Die Subscription ID deiner Azure Subscription - az account show - dann id schnappen oder Azure Portal > Subscriptions"
}

#VM Credentials - Linux und Windows
variable "admin_username" {
  default = "azureuser"
}
variable "admin_password" {
  description = "Passwort für die VMs"
  sensitive   = true
}

# Mondoo Authentication Token für cnspec Windows Agents - Aus Mondoo Dashboard holen
variable "mondoo_token_windows"{
  description = "Mondoo Windows token from the dashboard"
  sensitive = true
}
# Mondoo Authentication Token für cnspec Linux Agents - Aus Mondoo Dashboard holen
variable "mondoo_token_linux"{
  description = "Mondoo Linux token from the dashboard"
  sensitive = true
}




# Resource group + vNet bauen
# Zusätzlich in Terraform NetworkwatcherRG und den Watcher darin hier definieren
# Sonst wird der beim Deployment automatisch von Azure erstellt und dann nicht abgerissen
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}
resource "azurerm_resource_group" "network_watcher_rg" {
  name     = "NetworkWatcherRG"
  location = var.location
}
resource "azurerm_network_watcher" "network_watcher" {
  name                = "NetworkWatcher_${azurerm_resource_group.network_watcher_rg.location}"
  resource_group_name = azurerm_resource_group.network_watcher_rg.name
  location            = azurerm_resource_group.network_watcher_rg.location
}





# Übergeordnetes vNet für das komplette Test Deployment
resource "azurerm_virtual_network" "main_vnet" {
  name                = "my-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_resource_group.example]
}

# Subnet für Bastion
resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.main_vnet.name
  address_prefixes     = ["10.0.0.0/24"] 
}

# Subnetz für VMs
resource "azurerm_subnet" "vm_subnet" {
  name                 = "VMSubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.main_vnet.name
  address_prefixes     = ["10.0.1.0/24"] 
}




# Bastion Setup
resource "azurerm_bastion_host" "bastion" {
  name                = "my-bastion-host"
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name
  virtual_network_id  = azurerm_virtual_network.main_vnet.id
  sku                 = "Developer"
}

# NSG für Bastion
resource "azurerm_network_security_group" "vm_nsg" {
  name                = "vm-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_resource_group.example]
}

resource "azurerm_network_security_rule" "allow_rdp_bastion" {
  name                        = "Allow-RDP-From-Bastion"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "168.0.0.0/24"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.vm_nsg.name
}

resource "azurerm_subnet_network_security_group_association" "vm_nsg_association" {
  subnet_id                 = azurerm_subnet.vm_subnet.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}

# Linux VM Setup
resource "azurerm_network_interface" "linux_nic" {
  name                = "linux-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "linux-ip"
    subnet_id                     = azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "linux_vm" {
  name                = "linux-vm"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B1ls"
  disable_password_authentication = false
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [azurerm_network_interface.linux_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  user_data = base64encode(<<EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install ufw
sudo ufw default allow outgoing
sudo ufw allow from 168.0.0.0/24 to any port 3389 proto tcp
sudo ufw enable
apt-get update
export MONDOO_REGISTRATION_TOKEN="${var.mondoo_token_linux}"
curl -sSL https://install.mondoo.com/sh | bash -s -- -u enable -s enable -t $MONDOO_REGISTRATION_TOKEN
cnspec scan local
EOF
  )
}

# Windows VM Setup

resource "azurerm_windows_virtual_machine" "windows_vm" {
  name                  = "windows-vm"
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = "Standard_B1ms"
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.windows_nic.id]

  #Inline Commands only
  provisioner "local-exec" {
  command = <<EOT
      New-Item -Path "C:\users\$env:USERNAME\desktop\okaaaaan" -ItemType Directory
  EOT
  interpreter = ["PowerShell", "-Command"]
  }
  # File execution only - File in same directory as main.tf
  provisioner "local-exec" {
      command = "windowsvmsetupmondoo.ps1"
  interpreter = ["PowerShell", "-File"]
  }
  
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Image festlegen - In Azure Cloud Shell prüfen, was verfügbar ist bei Bedarf
  # az vm image list --publisher MicrosoftWindowsDesktop --offer Windows-10 --all --output table
  # SKU muss man immer hardcoden 
  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "win11-21h2-avd"
    version   = "latest"
  }
}

resource "azurerm_network_interface" "windows_nic" {
  name                = "windows-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "windows-ip"
    subnet_id                     = azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
