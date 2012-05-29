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

# Warn on a dirty work tree.
git rev-parse --verify HEAD >/dev/null || exit 1
git update-index -q --ignore-submodules --refresh
dirty=0
if ! git diff-files --quiet --ignore-submodules
then
        echo "WARNING (dirty work tree): The patch will only be checked against actual commits."
        dirty=1
fi

# Warn on a dirty index.
if ! git diff-index --cached --quiet --ignore-submodules HEAD --
then
        echo "WARNING (dirty index): The patch will only be checked against actual commits."
        dirty=1
fi

# Use a temporary index.
old_index=$GIT_INDEX_FILE
GIT_INDEX_FILE=$(mktemp)
export GIT_INDEX_FILE

# Go back in history while parent commits are available.
echo "Trying to find a commit the patch applies to..."
rev=$(git rev-parse HEAD)
while [ $? = 0 ]
do
        git read-tree $rev

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
                echo "Patch applied to $rev."

                if [ $dirty = 1 ]
                then
                        echo "Not rebasing, because that requires a clean work tree and index."
                        exit
                fi

                GIT_INDEX_FILE=$old_index
                export GIT_INDEX_FILE

                git checkout $rev
                git commit -q -m "$1"
                orig_head=$(git rev-parse HEAD)
                git reset --hard -q $rev
                git rebase $orig_head
                exit $?
        fi

        rev=$(git rev-parse --verify -q $rev^)
done

# No compatible commit found. Restore.
echo "Failed to find a commit the patch applies to."
exit 1
