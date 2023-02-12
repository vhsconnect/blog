---
tags: nixos
title: Writing bootable linux images with dd and fsync
author: vhs
---

use `lsblk` to find where the sdcard or usb stick is mounted. Something like `sda`.

I've read other sources advising to unmount the boot image from `/run` or `/media` before writing to the flash drive, but I never had to do that.

Then use the dd command the write the image. image files can be `.img`, `.raw` or `.iso` depending on the architecture and the vendor

```bash
dd if=pathto.img of=/dev/sdb bs=4M iflag=fullblock oflag=direct conv=fsync status=progress
```
