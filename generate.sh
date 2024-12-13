#! /usr/bin/env bash

DATE="$(date --iso-8601)"
File="$DATE-$1.markdown"

touch ./site/posts/"$File"

