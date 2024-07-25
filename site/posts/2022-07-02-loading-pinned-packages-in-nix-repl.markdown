---
title: Loading pinned packages in nix repl
author: vhs
tags: nixos, niv
---

Once in the repl, start by importing the sources. Assuming you're using Niv, those are typically at `./nix/sources.nix`. It's easiest to assign those to a variable. Then import their nixpkgs by calling it with an empty attribute set.

```nix
x = import ./nix/sources.nix
y = import x.nixpkgs {}
```

