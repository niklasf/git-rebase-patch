#!/bin/sh

#
# Require a clean work tree.
#

git rev-parse --verify HEAD >/dev/null || exit 1
git update-index -q --ignore-submodules --refresh
err=0
if ! git diff-files --quiet --ignore-submodules
then
        echo >&2 "Cannot rebase: You have unstaged changes."
        err=1
fi

if ! git diff-index --cached --quiet --ignore-submodules HEAD --
then
        if [ $err = 0 ]
        then
                echo >&2 "Cannot rebase: Your index contains uncommitted changes."
        else
                echo >&2 "Additionally, your index contains uncommitted changes."
        fi
        err=1
fi

if [ $err = 1 ]
then
        echo >&2 "Please commit or stash them."
        exit 1
fi

