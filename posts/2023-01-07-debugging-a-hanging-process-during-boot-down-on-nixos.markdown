---
tags: nixos, linux, systemd
title: Debugging a hanging process during boot down on NixOs
author: vhs
---

Recently, powering down my machine has been taking around 90 seconds. The time to it takes to timeout a hanging process and indeed that seems to be what is happening.

```
A stop job is running for User Manager for UID 1000
```

At first I tried to just lower the timeout value to soemthing like 10 seconds - surprisingly that didn't work.

```nix
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=10s
    DefaultDeviceTimeoutSec=10s
    TimeoutSec=10s
  '';
```

Next I found out that you can pop a root shell during your root shell to examine the state of the machine at that point. Here is how to get that done on NixOs

- modify your configuration to enable the systemd module

```nix
  systemd.additionalUpstreamSystemUnits = [ "debug-shell.service" ];
```

- add the kernel params to enable the debug-shell.service

```nix
  boot.kernelParams = [ "systemd.debug-shell=1" ];
```

then you can just `atl+F9` and drop into a shell and do some debugging.
Some helpful commands to use

```
systemd-cgls
ps -xawuf

```

sources: [mostly this systemd issue] (https://github.com/systemd/systemd/issues/12262)
