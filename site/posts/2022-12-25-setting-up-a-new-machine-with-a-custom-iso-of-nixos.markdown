---
tags: nixos, linux
title: Setting up a new machine with a custom iso of NixOS
author: vhs
---

Setting up a NixOS installation is much easier then doing so with any other distribution. Your configuration already exists and the new machine is likely to use more or less the same configuration.

## The typical way of doing it

Previously, I would just boot up from my nightingale 20.09 iso. do a normal installation, reboot the machine, replace the existing configuration with my own. That would include several changes.

- Enabling experiemental flakes, in order to be able to evaluate my existing configuration. In some cases I had to restart the nix daemon after doing this.
```nix
{
  nix =  {
    package = pkgs.nixFlakes;
    extraOptions  = ''
      experimental-features = nix-command flakes
    '';
  };
}
```
- Change the location of the configuration file to something in my home directory. (Not anymore the case with flakes)
- Clone the config and place it in the right place.
- Adding an entry in my configuration for the new host.


Sometimes paths wouldn't evaluate correctly as they would point to the old store for example. It's not that these things are hard, they're just tiring especially without my tools, shell, environment on a vanilla install (no nix fomatting, no vim configuration). How great would it be if I can just boot an iso that generates my configuration and be done with it. (Well there would still be some things to do like generating some ssh and gpg keys, but it would still be much faster).

## The custom iso

[nixos-generators](https://github.com/nix-community/nixos-generators) allows you to define one of your outputs as an iso based on your own configuration. The definition would look something like this.

```nix
{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nixos-generators, ... }: {
    # if you're creating a boot image for x86_64
    packages.x86_64-linux = {
      my-iso = nixos-generators.nixosGenerate {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          ./all-firmware
        ];
        format = "install-iso";
      };
    };
  };
}

```

While we're at it, we can also include proprietary drivers in our iso, so that we know we'll increase out-of-the-box compatibility with all the hardware out there. Like for example wifi cards on old macs.

```nix
{ config } : {
  nixpkgs.allowUnfree = true;
  boot.extraModulePackages  =  [ config.boot.kernelPackages.broadcom_sta ];
  hardware.enableRedistributableHardware = true;
  hardware.enableAllFirmware = true;
}

```




Then just build the iso and find the image `./result/iso`
```bash
nix build .#my-iso
```

Next just flash it onto your usb or mount in a vm

```bash
dd if=<path/to/iso> of=<device> bs=1M status=progress
```
