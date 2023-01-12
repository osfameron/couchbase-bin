#!/bin/bash

git-branch-name() {
    git rev-parse --symbolic --abbrev-ref HEAD
}

git-slug() {
    git-branch-name \
        | perl -pe 's/^(\w+-\d+)-(.*)/"$1: " . join(" ", map ucfirst, split "-", $2)/e'
}

git-default-branch-ref() {
    gh repo view --json defaultBranchRef --jq .defaultBranchRef.name
}

git-root() {
    git rev-parse --show-toplevel
}

git-commits-for-pr() {
    local PR=$1
    gh pr view $PR \
        --json commits \
    | jq -r '.commits | map(.oid) | .[]'
}
