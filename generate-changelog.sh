#!/bin/bash

set -x
set -o errexit
set -o nounset

# Setup git for github action 
git config --global --add safe.directory '*'

CHANGELOG_FILE_NAME="CHANGELOG.md"
CHANGELOG_TMP_FILE_NAME="CHANGELOG.tmp"
TARGET_SHA=$(git rev-parse HEAD)
PREVIOUS_RELEASE_TAG=$(git tag -l | sort -V | grep -E 'v[0-9]+.[0-9]+.[0-9]+$' | tail -n 1)
PREVIOUS_RELEASE_SHA=$(git rev-list -n 1 "$PREVIOUS_RELEASE_TAG")

if [ "$TARGET_SHA" == "$PREVIOUS_RELEASE_SHA" ]; then
  echo "Nothing to do"
  exit 0
fi

PREVIOUS_CHANGELOG=$(sed -n -e "/# ${PREVIOUS_RELEASE_TAG#v}/,\$p" /github/workspace/$CHANGELOG_FILE_NAME)

if [ -z "$PREVIOUS_CHANGELOG" ]
then
    echo "Unable to locate previous changelog contents."
    exit 1
fi 

CHANGELOG=$(/usr/local/bin/changelog-build -this-release "$TARGET_SHA" \
                      -last-release "$PREVIOUS_RELEASE_SHA" \
                      -git-dir /github/workspace \
                      -entries-dir .changelog \
                      -changelog-template /changelog/changelog.tmpl \
                      -note-template /changelog/release-note.tmpl)
if [ -z "$CHANGELOG" ]
then
    echo "No changelog generated."
    exit 0
fi

rm -f $CHANGELOG_TMP_FILE_NAME

sed -n -e "1{/# /p;}" /github/workspace/$CHANGELOG_FILE_NAME > $CHANGELOG_TMP_FILE_NAME
echo "$CHANGELOG" >> "$CHANGELOG_TMP_FILE_NAME"
echo >> $CHANGELOG_TMP_FILE_NAME
echo "$PREVIOUS_CHANGELOG" >> $CHANGELOG_TMP_FILE_NAME

cp $CHANGELOG_TMP_FILE_NAME $CHANGELOG_FILE_NAME

rm $CHANGELOG_TMP_FILE_NAME

echo "Successfully generated changelog."

exit 0