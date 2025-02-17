#!/bin/bash

# Creates and starts editing a new TIL entry.
read -p "Title: " title
slug=$(echo "${title}" | iconv -t ascii//TRANSLIT | sed -E -e 's/[^[:alnum:]]+/-/g' -e 's/^-+|-+$//g' | tr '[:upper:]' '[:lower:]')

newfile="til/_posts/$(date +'%Y-%m-%d')-${slug}.md"
if [ ! -f "${newfile}" ]; then
    cat <<EOF >"${newfile}"
---
layout: post
title: "${title}"
date: "$(date +'%Y-%m-%d 00:00:00 +0900')"
# tags: <tags>
render_with_liquid: false
---

EOF
fi

${EDITOR} "${newfile}"
