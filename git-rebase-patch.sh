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
if ! git diff-files --quiet --ignore-submodules
then
        echo "WARNING (dirty work tree): The patch will only be checked against actual commits."
fi

# Warn on a dirty index.
if ! git diff-index --cached --quiet --ignore-submodules HEAD --
then
        echo "WARNING (dirty index): The patch will only be checked against actual commits."
fi

# Use a temporary index.
index="/tmp/$(basename $0).$$.tmp"
cleanup() {
        rm $index
        exit 2
}
trap cleanup 2

# Go back in history while parent commits are available.
echo "Trying to find a commit the patch applies to..."
rev=$(git rev-parse HEAD)
while [ $? = 0 ]
do
        GIT_INDEX_FILE=$index git read-tree $rev

        # Try to apply the patch.
        GIT_INDEX_FILE=$index git apply --cached $1 >/dev/null 2>&1
        patch_failed=$?

        # Do it again, but show the error, if the problem is the patch itself.
        if [ $patch_failed = 128 ]
        then
                GIT_INDEX_FILE=$index git apply --index --check $1
                exit $patch_failed
        fi

        # The patch applied. Commit and rebase.
        if [ $patch_failed = 0 ]
        then
                # Manufacture a commit.
                tree=$(GIT_INDEX_FILE=$index git write-tree)
                commit=$(git commit-tree $tree -p $rev -m "$1")
                rm $index

                echo "Patch applied to $(git rev-parse --short $rev) as $(git rev-parse --short $commit)"

                git cherry-pick $commit
                exit $?
        fi

        rev=$(git rev-parse --verify -q $rev^)
done

# No compatible commit found. Restore.
echo "Failed to find a commit the patch applies to."
rm $index
exit 1
