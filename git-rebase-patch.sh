#!/bin/sh
#
# Copyright (c) 2012 Niklas Fiekas <niklas.fiekas@googlemail.com>.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Require a clean work tree.
git rev-parse --verify HEAD >/dev/null || exit 1
git update-index -q --ignore-submodules --refresh
err=0
if ! git diff-files --quiet --ignore-submodules
then
        echo >&2 "Cannot rebase: You have unstaged changes."
        err=1
fi

# Require a clean index.
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

# Say the user what to do when work tree or index are dirty.
if [ $err = 1 ]
then
        echo >&2 "Please commit or stash them."
        exit 1
fi

# Remember what the original HEAD is.
orig_head=$(git rev-parse HEAD)

# Go back in history while parent commits are available.
echo "Trying to find a commit the patch applies to..."
err=0
while [ $err = 0 ]
do
        # Try to apply the patch.
        git apply --cached $1 >/dev/null 2>&1
        patch_failed=$?

        # Do it again, but show the error, if the problem is the patch itself.
        if [ $patch_failed = 128 ]
        then
                git apply --index --check $1
                exit $path_failed
        fi

        # The patch applied. Commit and rebase.
        if [ $patch_failed = 0 ]
        then
                git commit -q -m "$1"
                compatible_head=$(git rev-parse HEAD)
                echo "Patch applied to $compatible_head."
                git reset --hard -q $orig_head
                git reset --hard -q $compatible_head
                git rebase $orig_head
                exit $?
        fi

        # Set the index to be the parent of the current commit.
        git reset -q HEAD^1 -- >/dev/null 2>&1
        err=$?
done

# No compatible commit found. Restore.
echo "Failed to find a commit the patch applies to."
git reset --hard -q $orig_head
exit 1
