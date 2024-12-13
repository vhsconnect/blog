
---
tags: nixos, linux, nix
title: Setting up an eval loop for nix modules
author: vhs
---

I am yet to find an ergonomic way to use the Nix repl. I'm sure it's a great but I typically find myself needing to fiddle with Nix expressions over and over again sometimes before getting what I want and typing the code in a repl gets in my way. What if I need to change a function or a value.  

### Setting up a watcher

We can use an inotifywait loop to watch a file and execute it when it changes. Nix's `eval` command can process an expression and that is all the main components we need for setting up a live Read Eval Process Loop. Just pass it the path to a file you want to evaluate. This particular command will evaluate an attribute called `x`. So you can have a bunch of Nix expressions in there and just move the one you want to evaluate at any moment to x.

```bash
 #!/usr/bin/env bash
 echo "watching..."
 while inotifywait -e close_write "$1"; do
 	nix eval --expr "builtins.getAttr \"x\" (import $(realpath "$1") { lib = (import <nixpkgs> {}).lib; })" --impure
 done
```

Note that for flake users to get `<nixpkgs>` to point to your store you need to setup it as your `nix.nixPath`. So define this value in your configuration somewhere and pass your `nixpkgs` reference to it.

### Evaluation File

it should look something like this.

```nix

{ lib }:
{
  x =
    with lib;
    with builtins;
    let
      fonts = [
        { Hermit = "Hurmit"; }
        { Lekton = "Lekton"; }
        { AurulentSansMono = "AurulentSansM"; }
        { AnonymousPro = "AnonymicePro"; }
        { EnvyCodeR = "EnvyCodeR"; }
      ];

      generateFontTemplate = font_name: "family = ${font_name} Nerd Font";

      firstAttrName = z: head (attrNames z);
      firstAttrValue = z: head (attrValues z);
      mappedFonts = map (y: {
        name = "alacritty/fonts/${firstAttrName y}.toml";
        value = {
          text = generateFontTemplate (firstAttrValue y);
        };
      }) fonts;

    in

    listToAttrs mappedFonts;

}
```
