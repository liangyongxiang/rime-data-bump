#!/bin/bash

last_date=""
package_last_update=""

git_repo_sync() {
    local repo="$1"
    if git -C "$repo" rev-parse; then
        git -C "$repo" pull
    else
        mkdir -p "$repo" && git -C "$repo" clone "https://github.com/rime/$(basename $repo).git"
    fi
}

git_last_commit_hash_and_date() {
    local repo="$1"
    local pn="$(basename "$repo")"
    local prefix="${pn#*-}"
    prefix="${prefix/-/_}"
    local commit="$(git -C "$repo" rev-parse HEAD)"
    #git -C "$repo" rev-parse --short HEAD
    local date=$(git -C "$repo" --no-pager show --no-patch --format=%cs "$commit")
    echo "RIME_${prefix^^}_PN=\"${pn}\""
    echo "RIME_${prefix^^}_COMMIT=\"${commit}\""

    echo "date: $date"
    echo "last_date: $last_date"
    if [[ "$date" > "$last_date" ]]; then
        last_date="$date"
        package_last_update="$pn"
    fi
}

while IFS= read -r line; do
    repo="rime-repos/$line"
    #git_repo_sync "$repo"
    git_last_commit_hash_and_date "$repo"
done < repos.txt

echo "${package_last_update} Last Data: ${last_date//-/}"
