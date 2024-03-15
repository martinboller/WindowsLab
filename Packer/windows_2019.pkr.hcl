packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
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
  default = "./answer_files/2019/Autounattend.xml"
}

variable "autounattend_virtio" {
  type    = string
  default = "./answer_files/2019_virtio/Autounattend.xml"
}

variable "disk_size" {
  type    = string
  default = "61440"
}

variable "iso_checksum" {
  type    = string
  default = "549bca46c055157291be6c22a3aaaed8330e78ef4382c99ee82c896426a1cee1"
}

variable "iso_checksum_type" {
  type    = string
  default = "sha256"
}

variable "iso_url" {
  type    = string
  default = "https://software-download.microsoft.com/download/pr/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso"
}

variable "packer_build_dir" {
  type    = string
  default = "./win2019"
}

variable "virtio_win_iso" {
  type    = string
  default = "./virtio-win.iso"
}

source "qemu" "quemu" {
  accelerator      = "kvm"
  boot_wait        = "6m"
  communicator     = "winrm"
  disk_size        = "${var.disk_size}"
  floppy_files     = ["${var.autounattend_virtio}", "./floppy/WindowsPowershell.lnk", "./floppy/WindowsPowershell.lnk", "./floppy/PinTo10.exe", "./scripts/unattend.xml", "./scripts/sysprep.bat", "./scripts/disable-screensaver.ps1", "./scripts/disable-winrm.ps1", "./scripts/enable-winrm.ps1", "./scripts/microsoft-updates.bat", "./scripts/win-updates.ps1", "./scripts/install-credssp-fix.ps1"]
  headless         = true
  iso_checksum     = "${var.iso_checksum}"
  iso_url          = "${var.iso_url}"
  output_directory = "${var.packer_build_dir}"
  qemuargs         = [["-m", "2048"], ["-smp", "2"], ["-drive", "file=${var.virtio_win_iso},media=cdrom,index=3"], ["-drive", "file=${var.packer_build_dir}/{{ .Name }},if=virtio,cache=writeback,discard=ignore,format=qcow2,index=1"], ["-drive", "file=${var.iso_url},media=cdrom,index=2"]]
  shutdown_command = "a:/sysprep.bat"
  shutdown_timeout = "2h"
  vm_name          = "WindowsServer2019"
  winrm_password   = "vagrant"
  winrm_timeout    = "4h"
  winrm_username   = "vagrant"
}

source "virtualbox-iso" "virtualbox-iso" {
  boot_wait            = "2m"
  communicator         = "winrm"
  disk_size            = 61440
  floppy_files         = ["${var.autounattend}", "./floppy/WindowsPowershell.lnk", "./floppy/PinTo10.exe", "./scripts/unattend.xml", "./scripts/sysprep.bat", "./scripts/disable-screensaver.ps1", "./scripts/disable-winrm.ps1", "./scripts/enable-winrm.ps1", "./scripts/microsoft-updates.bat", "./scripts/win-updates.ps1", "./scripts/oracle-cert.cer", "./scripts/install-credssp-fix.ps1"]
  guest_additions_mode = "disable"
  guest_os_type        = "Windows2019_64"
  headless             = true
  iso_checksum         = "${var.iso_checksum}"
  iso_url              = "${var.iso_url}"
  shutdown_command     = "a:/sysprep.bat"
  vboxmanage           = [["modifyvm", "{{ .Name }}", "--memory", "2048"], ["modifyvm", "{{ .Name }}", "--cpus", "2"]]
  vm_name              = "WindowsServer2019"
  winrm_password       = "vagrant"
  winrm_timeout        = "4h"
  winrm_username       = "vagrant"
}

source "vmware-iso" "vmware-iso" {
  boot_wait        = "2m"
  communicator     = "winrm"
  disk_size        = 61440
  floppy_files     = ["${var.autounattend}", "./floppy/WindowsPowershell.lnk", "./floppy/PinTo10.exe", "./scripts/unattend.xml", "./scripts/sysprep.bat", "./scripts/disable-screensaver.ps1", "./scripts/disable-winrm.ps1", "./scripts/enable-winrm.ps1", "./scripts/microsoft-updates.bat", "./scripts/win-updates.ps1", "./scripts/install-credssp-fix.ps1"]
  guest_os_type    = "windows8srv-64"
  headless         = true
  iso_checksum     = "${var.iso_checksum}"
  iso_url          = "${var.iso_url}"
  shutdown_command = "a:/sysprep.bat"
  shutdown_timeout = "2h"
  version          = 11
  vm_name          = "WindowsServer2019"
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
  sources = ["source.qemu.quemu", "source.virtualbox-iso.virtualbox-iso", "source.vmware-iso.vmware-iso"]

  provisioner "windows-shell" {
    execute_command = "{{ .Vars }} cmd /c \"{{ .Path }}\""
    scripts         = ["./scripts/enable-rdp.bat"]
  }

  provisioner "powershell" {
    scripts = ["./scripts/install-credssp-fix.ps1", "./scripts/vm-guest-tools.ps1"]
  }

  provisioner "windows-restart" {
  }

  provisioner "windows-shell" {
    execute_command = "{{ .Vars }} cmd /c \"{{ .Path }}\""
    scripts         = ["./scripts/pin-powershell.bat", "./scripts/set-winrm-automatic.bat", "./scripts/compile-dotnet-assemblies.bat", "./scripts/uac-enable.bat", "./scripts/compact.bat"]
  }

  post-processor "vagrant" {
    keep_input_artifact  = false
    output               = "windows_2019_{{ .Provider }}.box"
    vagrantfile_template = "vagrantfile-windows_2019.template"
  }
}
