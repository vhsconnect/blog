#! /usr/bin/env bash

echo "._. site:8700 | hoogle:8701"
cabal run site watch & hoogle server --local -p 8701 && fg
