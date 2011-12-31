#!/usr/bin/env python

"""
"""

import sys
import optparse

from git import Git, Repo

def main():
    # Initialize a repo object.
    Git.git_binary = 'git'
    repo = Repo('.')
    try:
        oldref = repo.active_branch.name
    except:
        oldref = repo.commit('HEAD').hexsha


    # Parse arguments.
    usage = 'usage: %prog [-p0] [(-b | --branch) <branch>] <patch>'
    description = 'Finds a commit the patch applies against and rebases.'
    parser = optparse.OptionParser(usage, description = description)
    parser.add_option('-p', dest = 'p', default = '1',
        help = 'Indicates an old p0 style patch.')
    parser.add_option('-b', '--branch', dest = 'branch', default = None,
        help = 'Checkout a new branch before rebasing.')
    options, args = parser.parse_args()

    # Validate the patch style argument.
    patch_style = '-p' + options.p
    if not patch_style in ['-p0', '-p1']:
        parser.error('Unkown patch style: ' + patch_style)

    # Get the patch file path.
    if (len(args) != 1):
        parser.error('Give exactly one patch as an argument.')
    # TODO: Optionally fetch patches via HTTP.
    patch = args[0]

    # Doesn't work in bare repositories.
    # TODO: Support bare repositories.
    if repo.bare:
        print 'Bare repositories not supported.'
        return

    if repo.is_dirty():
        print 'Working copy is dirty. Commit or stash changes before proceeding.'
        return

    # TODO: Interactively warn.
    #for file in (repo.untracked_files):
    #  if not file.endswith('.patch'):
    #    print 'Untracked non patch file.'
    #    return

    # TODO: Validate the patch.

    # Optionally checkout a new branch before starting.
    if options.branch:
        repo.git.checkout('-b', options.branch)

    # TODO: Try not to alter the working copy.
    try:
        looping = True
        while looping:
            try:
                sys.stdout.write('Trying to apply against: ' + repo.commit('HEAD').hexsha + "\r")
                sys.stdout.flush()
                repo.git.apply(patch_style, patch)
                looping = False
            except:
                repo.git.reset('--hard', 'HEAD~1')
        sys.stdout.write("\n")
    except:
        # Restore state.
        sys.stdout.write("\n")
        repo.git.checkout(oldref)
        if options.branch:
            repo.git.branch('-d', options.branch)
        print 'Fail. Restored working copy.'
        return

    # Commit.
    repo.git.commit('-a', '-m', patch)

    # Do the rebase.
    print 'Starting rebase now.'
    repo.git.rebase(oldref)

if __name__ == '__main__':
    main()
