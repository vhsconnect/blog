---
tags: nixos
title: dualbooting nixos alongside other linux oses
author: vhs
---

- Install the other OS first, then install NixOs.

- If you end up booting into the second OS' welcome screen, you'll need to switch to NixOs' bootloader. Change the booting priority through your bios setting.

- Install your nixOs configurations with the following boot attrs, getting rid of the systemd-boot module all together. OSProber will locate your second distro and add it as an entry in the grub boot menu.

```nix
{
  ...
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.devices = [ "nodev" ];
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = true;
}
```

or if you are using legacy boot/efi
```nix
{
  boot.loader.grub = {
    enable = true;
    device = user.mbrDevice;
  };
}
```

For multiple machines, I like to paramatize `efi` option in a user.nix file so I have something like this
```nix
{
  let user  = (import <path to user.nix>)
  # example user = {
  #   efiBoot = true;
  #   mbrDevice = "/dev/sda"
  # }
  boot.loader =
    if user.efiBoot then {
      efi = { canTouchEfiVariables = true; };
      grub = {
        enable = true;
        devices = [ "nodev" ];
        efiSupport = true;
        useOSProber = true;
      };
    } else {
      grub = {
        enable = true;
        device = user.mbrDevice;
      };
    };

}

```

note: this worked with other Debian based systems. For Arch based systems, I couldn't successfully boot the OS from the NixOs boot screen (eventhough it was an entry) I had to access the secondOs' bootloader from the boot settings, as if I were booting a usb. Surely there is a way but you might need to tinker a litte extra


