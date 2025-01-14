packer {
  required_plugins {
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
    virtualbox = {
      source  = "github.com/hashicorp/virtualbox"
      version = "~> 1"
    }
    vmware = {
      source  = "github.com/hashicorp/vmware"
      version = "~> 1"
    }
  }
}

variable "autounattend" {
  type    = string
  default = "./answer_files/10/Autounattend.xml"
}

variable "disk_size" {
  type    = string
  default = "61440"
}

variable "iso_checksum" {
  type    = string
  default = "69efac1df9ec8066341d8c9b62297ddece0e6b805533fdb6dd66bc8034fba27a"
}

variable "iso_checksum_type" {
  type    = string
  default = "sha256"
}

variable "iso_url" {
  type    = string
  default = "https://software-download.microsoft.com/download/sg/444969d5-f34g-4e03-ac9d-1f9786c69161/19044.1288.211006-0501.21h2_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
}

source "virtualbox-iso" "virtualbox-iso" {
  boot_wait            = "6m"
  communicator         = "winrm"
  disk_size            = "${var.disk_size}"
  floppy_files         = ["${var.autounattend}", "./floppy/WindowsPowershell.lnk", "./floppy/PinTo10.exe", "./scripts/fixnetwork.ps1", "./scripts/disable-screensaver.ps1", "./scripts/disable-winrm.ps1", "./scripts/enable-winrm.ps1", "./scripts/win-updates.ps1", "./scripts/unattend.xml", "./scripts/sysprep.bat"]
  guest_additions_mode = "disable"
  guest_os_type        = "Windows81_64"
  headless             = true
  iso_checksum         = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url              = "${var.iso_url}"
  shutdown_command     = "a:/sysprep.bat"
  shutdown_timeout     = "2h"
  vboxmanage           = [["modifyvm", "{{ .Name }}", "--memory", "4096"], ["modifyvm", "{{ .Name }}", "--cpus", "2"]]
  vm_name              = "windows_10"
  winrm_password       = "vagrant"
  winrm_timeout        = "4h"
  winrm_username       = "vagrant"
}

source "vmware-iso" "vmware-iso" {
  boot_wait        = "7m"
  communicator     = "winrm"
  disk_size        = "${var.disk_size}"
  floppy_files     = ["${var.autounattend}", "./floppy/WindowsPowershell.lnk", "./floppy/PinTo10.exe", "./scripts/fixnetwork.ps1", "./scripts/disable-screensaver.ps1", "./scripts/disable-winrm.ps1", "./scripts/enable-winrm.ps1", "./scripts/microsoft-updates.bat", "./scripts/win-updates.ps1", "./scripts/unattend.xml", "./scripts/sysprep.bat"]
  guest_os_type    = "windows9-64"
  headless         = true
  iso_checksum     = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url          = "${var.iso_url}"
  shutdown_command = "a:/sysprep.bat"
  shutdown_timeout = "3h"
  version          = 11
  vm_name          = "windows_10"
  vmx_data = {
    "RemoteDisplay.vnc.enabled" = "false"
    "RemoteDisplay.vnc.port"    = "5900"
    memsize                     = "2048"
    numvcpus                    = "2"
    "scsi0.virtualDev"          = "lsisas1068"
  }
  vnc_port_max   = 5980
  vnc_port_min   = 5900
  winrm_password = "vagrant"
  winrm_timeout  = "5h"
  winrm_username = "vagrant"
}

build {
  sources = ["source.virtualbox-iso.virtualbox-iso", "source.vmware-iso.vmware-iso"]

  provisioner "windows-shell" {
    execute_command = "{{ .Vars }} cmd /c \"{{ .Path }}\""
    remote_path     = "/tmp/script.bat"
    scripts         = ["./scripts/vm-guest-tools.bat", "./scripts/enable-rdp.bat"]
  }

  provisioner "windows-restart" {
  }

  provisioner "powershell" {
    scripts = ["./scripts/set-powerplan.ps1", "./scripts/docker/disable-windows-defender.ps1"]
  }

  provisioner "windows-shell" {
    execute_command = "{{ .Vars }} cmd /c \"{{ .Path }}\""
    remote_path     = "/tmp/script.bat"
    scripts         = ["./scripts/pin-powershell.bat", "./scripts/compile-dotnet-assemblies.bat", "./scripts/set-winrm-automatic.bat"]
  }

  post-processor "vagrant" {
    keep_input_artifact  = false
    output               = "windows_10_{{ .Provider }}.box"
    vagrantfile_template = "vagrantfile-windows_10.template"
  }
}
