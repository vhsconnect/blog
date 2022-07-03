---
tags: nixos
title: running a python script with virtualenv on NixOs
author: vhs
---

I am not a python developer. But what I know that newer packages tend to use `requirements.txt` to declare their dependencies.

For python packages that are not part of nixpkgs, I found the easiest to way to run them typically is to use virtualenv. Which as I understand it, is the python way to install a project's dependencies in a contained way and not pollute your global environment.

If the project happens to have a requirements.txt. I found that the process is pretty straightforward. Just follow the section from the nixos python wiki page  about (using virtualenv) [https://nixos.wiki/wiki/Python].

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

```

If the project has a setup.py run that as well

```bash
python setup.py install

```

When you need to use these packages, just drop into the virtualenv of the project and you'll have access to it `source <path_to_your_project>/.venv/bin/activate` then run the setup script again. 🤷
