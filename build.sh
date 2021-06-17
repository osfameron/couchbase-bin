#!/bin/bash

# build - build docs-site and grep for files changed in current repo.

BASE=~/latest-antora-build
PAT=$BASE.pattern
LOG=$BASE.log
BRANCHES=${BRANCHES:-\"HEAD\"}

PLAYBOOK=lightweight-playbook.yml
PLAYBOOK_MOD=lightweight-playbook-modified.yml

source $NVM_DIR/nvm.sh
nvm use --lts

pushd $(git rev-parse --show-toplevel)/ > /dev/null

git status -s | awk '{ print $2 }' > $PAT

PROJECT=$(basename $(pwd))
NAME=$(yq eval .name antora.yml)

pushd ../docs-site > /dev/null

yq eval ".content.sources += [{\"url\": \"../${PROJECT}\", \"branches\": [$BRANCHES]}]" $PLAYBOOK > $PLAYBOOK_MOD

echo "Building $PLAYBOOK_MOD for $PROJECT ($NAME) (see $LOG for full details)"
echo "Using the pattern:"
cat $PAT | awk '{ print "    " $1 }'

PREV_SIZE=$(($(wc -c < $LOG) +0))

echo "Previous size was $PREV_SIZE"


antora --stacktrace $PLAYBOOK_MOD 2>&1 \
    | tee $LOG \
    | pv -s $PREV_SIZE \
    | grep --color=auto --file $PAT --fixed-strings \

echo
echo Open file:$(pwd)/public/${NAME} to view docs

popd > /dev/null
popd > /dev/null
