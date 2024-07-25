---
tags: linux, via
title: Using Via/Vial with Chromium on Linux
author: vhs
---

Linux does not give your browser write access to devices (e.g /dev/hidraw3) which is needed for [Via](https://www.caniusevia.com) to modify the device's firmware.

So you need to change the permissions of the device first to let it be writable by world. The premissions will be reset next time the device is mounted so you would just need to disconnect and reconnect your keyboard.

### Finding the keyboard

This command will give you information about the various devices mounted in your filesystem. Look for hints about the manufacturer of the keyboard - at the very least, use it to remove some devices from consideration.

```bash
#as admin
ls /dev/hidraw* | xargs -I  {} bash -c "udevadm info --query=all --name={$1}"
```

Once you've identified the device. change the permissions

### Changing permissions

```bash
#as admin
chmod a+rw /dev/<yourdevice>
```

Now you access [vial.rocks](https://vial.rocks) or [usevia.app](https://usevia.app) and change your keymap.
