#!./roundup/roundup.sh
#
# Copyright (c) 2012 Niklas Fiekas <niklas.fiekas@googlemail.com>

describe "Rebasing a basic patch."

before() {
        tar -xvzf test-repo.tar.gz
        cd test-repo
}

it_gets_rebased() {
        git-rebase-patch remove-second-paragraph.patch

        log=$(git log -n 1 --pretty=format:%s)
        test "$log" "=" "remove-second-paragraph.patch"

        log=$(git log -n 1 --pretty=format:%s HEAD~1)
        test "$log" "=" "Move the file."

        log=$(git log -n 1 --pretty=format:%s HEAD~2)
        test "$log" "=" "Create a patch to remove the second paragraph."
}

after() {
        cd ..
        rm -rf test-repo
}
