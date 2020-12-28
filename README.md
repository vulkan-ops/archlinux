# archlinux-install
---
# 1- install.sh
# 2- reboot
# done!


# requirements
---
To use this script, make sure your disk is formatted in GPT, with UEFI boot enabled.
The structure must have at least 2 partitions as shown in the example below:

| Disk | Size | Type |
|--|--|--|
| /dev/sda1 | 512M | EFI System |
| /dev/sda2 | 100G | Linux system files |
