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
    quemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"      
    }
  }
}

variable "autounattend" {
  type    = string
  default = "./answer_files/2022/Autounattend.xml"
}

variable "iso_checksum" {
  type    = string
  default = "3e4fa6d8507b554856fc9ca6079cc402df11a8b79344871669f0251535255325"
}

variable "iso_checksum_type" {
  type    = string
  default = "sha256"
}

variable "iso_url" {
  type    = string
  default = "https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/SERVER_EVAL_x64FRE_en-us.iso"
}

variable "packer_build_dir" {
  type    = string
  default = "./win2022"
}

source "virtualbox-iso" "virtualbox-iso" {
  boot_wait            = "2m"
  communicator         = "winrm"
  disk_size            = 61440
  floppy_files         = ["${var.autounattend}", "./floppy/WindowsPowershell.lnk", "./floppy/PinTo10.exe", "./scripts/unattend.xml", "./scripts/sysprep.bat", "./scripts/disable-screensaver.ps1", "./scripts/disable-winrm.ps1", "./scripts/enable-winrm.ps1", "./scripts/microsoft-updates.bat", "./scripts/win-updates.ps1", "./scripts/oracle-cert.cer"]
  guest_additions_mode = "disable"
  guest_os_type        = "Windows2022_64"
  headless             = true
  iso_checksum         = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url              = "${var.iso_url}"
  shutdown_command     = "a:/sysprep.bat"
  vboxmanage           = [["modifyvm", "{{ .Name }}", "--memory", "2048"], ["modifyvm", "{{ .Name }}", "--cpus", "2"]]
  winrm_password       = "vagrant"
  winrm_timeout        = "4h"
  winrm_username       = "vagrant"
}

source "vmware-iso" "vmware-iso" {
  boot_wait        = "2m"
  communicator     = "winrm"
  disk_size        = 61440
  floppy_files     = ["${var.autounattend}", "./floppy/WindowsPowershell.lnk", "./floppy/PinTo10.exe", "./scripts/unattend.xml", "./scripts/sysprep.bat", "./scripts/disable-screensaver.ps1", "./scripts/disable-winrm.ps1", "./scripts/enable-winrm.ps1", "./scripts/microsoft-updates.bat", "./scripts/win-updates.ps1"]
  guest_os_type    = "windows8srv-64"
  headless         = true
  iso_checksum     = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url          = "${var.iso_url}"
  shutdown_command = "a:/sysprep.bat"
  shutdown_timeout = "2h"
  version          = 11
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
  winrm_timeout  = "4h"
  winrm_username = "vagrant"
}

build {
  sources = ["source.virtualbox-iso.virtualbox-iso", "source.vmware-iso.vmware-iso"]

  provisioner "windows-shell" {
    execute_command = "{{ .Vars }} cmd /c \"{{ .Path }}\""
    scripts         = ["./scripts/vm-guest-tools.bat", "./scripts/enable-rdp.bat"]
  }

  provisioner "windows-restart" {
  }

  provisioner "windows-shell" {
    execute_command = "{{ .Vars }} cmd /c \"{{ .Path }}\""
    scripts         = ["./scripts/pin-powershell.bat", "./scripts/set-winrm-automatic.bat", "./scripts/compile-dotnet-assemblies.bat", "./scripts/uac-enable.bat", "./scripts/compact.bat"]
  }

  provisioner "file" {
    destination = "c:/Windows/Temp/Autounattend_sysprep.xml"
    source      = "./answer_files/2022/Autounattend_sysprep.xml"
  }

  post-processor "vagrant" {
    keep_input_artifact  = false
    output               = "windows_2022_{{ .Provider }}.box"
    vagrantfile_template = "vagrantfile-windows_2022.template"
  }
}
