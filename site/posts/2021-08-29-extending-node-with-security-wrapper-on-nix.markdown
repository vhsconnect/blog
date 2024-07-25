---
tags: nixos, linux, setcap
title: Extending Node with a security wrapper on Nixos
author: vhs
---

In my current work we use a host file to bind our local machine ip to our development infrastructure. We do this so that we can test our front-end application locally but with all the deployed production-ready micro-services without the need for a ton of running (or one giant) container(s). 

There is a small issue however. Linux does not allow a ```Node``` process to bind to ports `<1024`. On typcial systems you just use ```setcap``` to allow the Node executable the "capability" to do so

```bash
PATH_TO_NODE=$(which node) && \
sudo setcap 'cap_net_bind_service=+ep' $PATH_TO_NODE
```

Enter NixOS and the immutable operating system I've been running as of late. Without going in to too much detail about how it works, the way you set execuatable capabilities in NixOS is by creting a [security wrapper](https://search.nixos.org/options?channel=20.09&show=security.wrappers&from=0&size=50&sort=relevance&type=packages&query=security.wrappers) for it. Think of these wrappers as proxies for the underlying programs throughwhich the capabilities get "propogated" through the underlying program. Security wrappers live in `/nix/wrappers/bin` directory. 


```bash
/home/vhs/bin
/home/vhs/.npm-global/bin
/nix/store/qy5z9gcld7dljm4i5hj3z8a9l6p37y81-python3-3.8.8/bin
/nix/store/28sdgfrdvw5sh64f04p064ah528zi26m-terminator-1.92/bin
/nix/store/014nvaxlfr0r24kamh8nmya66g4jcxry-cairo-1.16.0-dev/bin
/nix/store/w44y4a1k06x86hg7pzfdma29b7m7nc5v-freetype-2.10.2-dev/bin
/nix/store/6v59a9iszrs0kxk1b79v7fasn9bwi79q-bzip2-1.0.6.0.1-bin/bin
/nix/store/0z6y1qgais33xl348ls0jdc0i56p0yan-libpng-apng-1.6.37-dev/bin
/nix/store/z7wjsy4q6hbsk7zqwzl36addwiql5hn9-fontconfig-2.13.92-bin/bin
/nix/store/rw7hl4xd60z9qq724klhrikdcyh00w17-expat-2.2.8-dev/bin
/nix/store/1bfigag8ys62ib0qxd1bd0walfbrmw5i-glib-2.64.6-dev/bin
/nix/store/409dk4w32xq7w8mznxh5xg0dyp72igvb-gettext-0.21/bin
/nix/store/xv7zirb6i1ydwp80877akyyfc7skh02r-glib-2.64.6-bin/bin
/run/wrappers/bin # <-
/home/vhs/.nix-profile/bin
/etc/profiles/per-user/vhs/bin
/nix/var/nix/profiles/default/bin
/run/current-system/sw/bin
```

These are the directories in my ```$PATH```.
Note that run/wrappers/bin is read prior to the bin to nix-profile, user-profile and current-system. Thus they shortcircuit the namespace of the executables they wrap, again in this case `Node`


You can give the wrapper any "name" you want (and by name I mean the attribute on the security wrapper). For my use case I wanted my tooling (i.e webpack) to bind to port so using some kind of alias was not an option. I just added this to my configuration and I was up and running

```nix
  security.wrappers.node = {
    source = "${pkgs.nodejs}/bin/node";
    capabilities = "cap_net_bind_service=+ep";
  };
```

