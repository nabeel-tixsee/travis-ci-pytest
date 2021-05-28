#!/usr/bin/env bash
set -o errexit -o nounset
echo "Setting git user name"
git config user.name $GH_USER_NAME

echo "Setting git user email"
git config user.email $GH_USER_EMAIL

