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
    Patch applied to f8cc98cff6fb273532336194066378649c5d2ab1.
    First, rewinding head to replay your work on top of it...
    Applying: Move the file.
    Using index info to reconstruct a base tree...
    Falling back to patching base and 3-way merge...

Now your latest commit has the changes of your path. It's message is the patch
file name. Then proceed as usual.

Reroll the patch:

    git diff HEAD~1 > new-patch.patch

Change the commit message:
    git commit --amend

