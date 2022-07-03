---
tags: nixos, niv
title: Loading pinned packages in nix repl
author: vhs
---

Once in the repl, start by importing the sources. Those are typically at `./nix/sources.nix`. It's easiest to assign those to a variable. Then import their nixpkgs with an empty attribute set.

```nix
x = import ./nix/sources.nix
y = import x.nixpkgs {}
```

