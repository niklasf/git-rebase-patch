#!/usr/bin/env python

"""
"""

import sys

from git import Git, Repo

def main():
    # TODO: Improve argument parsing.
    # TODO: Optionally fetch patches via HTTP.
    if len(sys.argv) != 2:
        print "Give one patch as an argument."
        return

    # Initialize a repo object.
    Git.git_binary = 'git'
    repo = Repo('.')

    # Doesn't work in bare repositories.
    # TODO: Support bare repositories.
    if repo.bare:
        print "Repo bare."

    if repo.is_dirty():
        print "Repo is dirty."
        return

    # TODO: Interactively warn.
    #for file in (repo.untracked_files):
    #  if not file.endswith('.patch'):
    #    print "Untracked non patch file."
    #    return

    # TODO: Make -p0 optional.
    # TODO: Try not to alter the working copy.
    # TODO: Start the rebase.
    looping = True
    while looping:
        try:
            repo.git.apply('-p0', sys.argv[1])
            looping = False
        except:
            repo.git.reset('--hard', 'HEAD~1')

if __name__ == '__main__':
    main()
