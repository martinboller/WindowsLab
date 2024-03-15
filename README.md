# Windows Lab
This lab is based on a 2017 version of Chris Longs Detection Lab - As I have messed it up a lot for specific testing purposes over a period of time while Chris has developed further on DetectionLab, this is here for other test purposes.
If you use this, please consider supporting Chris https://github.com/sponsors/clong

Scripts and files for preloading OUs, Users, and Groups shamelessly lifted from https://activedirectorypro.com/create-active-directory-test-environment/#lesson-4

## Purpose
Testing & Hacking Windows.

## Known Issues
- Running Virtualbox on Debian, so this is what is tested here.

## Build boxes
$ packer build --only=[vmware|virtualbox]-iso.* windows_*xxxx*.pkr.hcl

### Virtualbox examples
$ packer build --only=virtualbox-iso.* windows_2022.pkr.hcl

$ packer build --only=virtualbox-iso.* windows_2019.pkr.hcl

$ packer build --only=virtualbox-iso.* windows_2016.pkr.hcl

$ packer build --only=virtualbox-iso.* windows_10.pkr.hcl

$ packer build --only=virtualbox-iso.* windows_11.pkr.hcl

Note: Windows 11 requirements not met on test system so currently not tested

Move the boxes created to ..\Boxes\

## Run stuff
