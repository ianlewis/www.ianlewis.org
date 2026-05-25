#!/usr/bin/env bash

set -euo pipefail

# Creates and starts editing a new blog post.

_usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Creates and starts editing a new blog post.

Options:
  --blog <name>   Blog to add the post to (e.g. til, en, jp). Prompted if omitted.
  --title <text>  Title of the post. Prompted if omitted.
  --tag <tag>     Tag for the post. Can be specified multiple times. Prompted if omitted.
  --draft         Save the post as a draft in content/_drafts/.
  --help          Show this help message and exit.
EOF
}

_main() {
    local blog=""
    local draft=false
    local title=""
    local tags=()

    while [[ $# -gt 0 ]]; do
        case "$1" in
        --help)
            _usage
            exit 0
            ;;
        --blog)
            if [[ $# -lt 2 || "$2" == --* ]]; then
                echo "Error: --blog requires an argument." >&2
                exit 1
            fi
            blog="$2"
            shift 2
            ;;
        --draft)
            draft=true
            shift
            ;;
        --title)
            if [[ $# -lt 2 || "$2" == --* ]]; then
                echo "Error: --title requires an argument." >&2
                exit 1
            fi
            title="$2"
            shift 2
            ;;
        --tag)
            if [[ $# -lt 2 || "$2" == --* ]]; then
                echo "Error: --tag requires an argument." >&2
                exit 1
            fi
            tags+=("$2")
            shift 2
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        esac
    done

    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local content_dir="${script_dir}/../content"

    if [[ -n ${blog} ]]; then
        if [[ ! -d "${content_dir}/${blog}/_posts" ]]; then
            echo "Error: blog '${blog}' not found." >&2
            exit 1
        fi
    else
        while true; do
            read -rp "Blog (til, en, jp): " blog
            if [[ -d "${content_dir}/${blog}/_posts" ]]; then
                break
            fi
            echo "Error: blog '${blog}' not found." >&2
        done
    fi

    if [[ -z ${title} ]]; then
        while true; do
            read -rp "Title: " title
            if [[ -n ${title} ]]; then
                break
            fi
            echo "Error: title cannot be empty." >&2
        done
    fi

    if [[ ${#tags[@]} -eq 0 ]]; then
        local tags_input=""
        read -rp "Tags (space-separated): " tags_input
        read -ra tags <<<"${tags_input}"
    fi

    local slug
    slug=$(echo "${title}" | iconv -t ascii//TRANSLIT | sed -E -e 's/[^[:alnum:]]+/-/g' -e 's/^-+|-+$//g' | tr '[:upper:]' '[:lower:]')

    local post_title
    if [[ ${blog} == "til" ]]; then
        post_title="TIL: ${title}"
    else
        post_title="${title}"
    fi

    local tags_yaml="tags:"
    local tag
    for tag in "${tags[@]+"${tags[@]}"}"; do
        tags_yaml="${tags_yaml}"$'\n'"- ${tag}"
    done

    local extra_fields=""
    if [[ ${blog} == "en" || ${blog} == "jp" ]]; then
        extra_fields=$'\n'"permalink: /${blog}/${slug}"
    fi

    local newfile
    if [[ ${draft} == true ]]; then
        newfile="${content_dir}/_drafts/${slug}.md"
        mkdir -p "${content_dir}/_drafts"
    else
        newfile="${content_dir}/${blog}/_posts/$(date +'%Y-%m-%d')-${slug}.md"
    fi

    if [[ ! -f ${newfile} ]]; then
        cat <<EOF >"${newfile}"
---
layout: post
title: "${post_title}"
date: "$(date +'%Y-%m-%d 00:00:00 +0900')"
blog: ${blog}
${tags_yaml}${extra_fields}
render_with_liquid: false
---

EOF
    fi

    ${EDITOR:-vi} "${newfile}"
}

_main "$@"
