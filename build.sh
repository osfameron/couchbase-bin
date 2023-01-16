#!/bin/bash

# build - build docs-site and grep for files changed in current repo.

BASE=~/latest-antora-build
PAT=$BASE.pattern
LOG=$BASE.log
BRANCHES=${BRANCHES:-\"HEAD\"}

PLAYBOOK=${PLAYBOOK:-lightweight-playbook.yml}
PLAYBOOK_MOD=modified-${PLAYBOOK}

EXTRA_ARGUMENTS=$*

source $NVM_DIR/nvm.sh
nvm use --lts

pushd $(git rev-parse --show-toplevel)/ > /dev/null

git status -s | awk '{ print $2 }' > $PAT
git status -s | awk '{ print $2 }' | xargs -L1 basename >> $PAT

PROJECT=$(basename $(pwd))
NAME=$(yq eval .name antora.yml)

pushd ../docs-site > /dev/null

cp $PLAYBOOK $PLAYBOOK_MOD

echo CHECKING $PROJECT
if [ "$PROJECT" != "docs-server" ]
then
	yq eval ".content.sources += [{\"url\": \"../${PROJECT}\", \"branches\": [$BRANCHES]}]" $PLAYBOOK_MOD > $PLAYBOOK_MOD.1
	mv $PLAYBOOK_MOD.1 $PLAYBOOK_MOD
fi

yq eval ".asciidoc.attributes.primary-site-url = \"https://docs-staging.couchbase.com\"" $PLAYBOOK_MOD > $PLAYBOOK_MOD.1
mv $PLAYBOOK_MOD.1 $PLAYBOOK_MOD

cat $PLAYBOOK_MOD

echo "Building $PLAYBOOK_MOD for $PROJECT ($NAME) (see $LOG for full details)"
echo "Using the pattern:"
cat $PAT | awk '{ print "    " $1 }'

PREV_SIZE=$(($(wc -c < $LOG) +0))

echo "Previous size was $PREV_SIZE"

set -x

pwd
ls -ltr $PLAYBOOK_MOD

antora $EXTRA_ARGUMENTS $PLAYBOOK_MOD 2>&1 \
    | tee $LOG \
    | pv -s $PREV_SIZE 
# \
#    | grep --file $PAT --fixed-strings \
#    | jq

set +x

# Following requires `public` to be `git init`.
# We don't need to save these, it just helps to do the diff of resulting output

pushd public > /dev/null
echo Following files were modified:
git add .
git diff --name-only --cached | xargs -L1 realpath
git commit -q -m Updating

popd > /dev/null
popd > /dev/null
popd > /dev/null
