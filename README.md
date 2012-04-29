git rebase-patch
================

Given you have a patch that doesn't apply to the current HEAD, but you know it
applied to some commit in the past, `git rebase-patch` will help you find that
commit and do a rebase.

Usage: `git rebase-patch <patch-file.patch>`

Example
-------

You can reroll a patch against the current HEAD like this:

    git rebase-patch old-patch.patch

That might give you:

    Trying to find a commit the patch applies to...
    Patch applied to dbcf408dd26392d7421a73745042dbc9b5bcdceb.
    First, rewinding head to replay your work on top of it...
    Applying: remove-second-paragraph.patch
    Using index info to reconstruct a base tree...
    Falling back to patching base and 3-way merge...
    Auto-merging new-file-name.txt

Now your latest commit has the changes of your path. It's message is the patch
file name. Then proceed as usual.

Reroll the patch:

    git diff HEAD~1 > new-patch.patch

Change the commit message:

    git commit --amend

Automated testing
-----------------
[![Build Status](https://secure.travis-ci.org/niklasf/git-rebase-patch.png?branch=master)](http://travis-ci.org/niklasf/git-rebase-patch)
