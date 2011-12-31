#!/usr/bin/env python

"""
"""

import sys

from git import Git, Repo

def main():
    if len(sys.argv) != 2:
        print "Give one patch as an argument."
        return

    Git.git_binary = 'git'

    repo = Repo('.')

    if repo.bare:
        print "Repo bare."

    if repo.is_dirty():
        print "Repo is dirty."
        return

#    for file in (repo.untracked_files):
#      if not file.endswith('.patch'):
#        print "Untracked non patch file."
#        return

    looping = True
    while looping:
        try:
            repo.git.apply('-p0', sys.argv[1])
            looping = False
        except:
            repo.git.reset('--hard', 'HEAD~1')

if __name__ == '__main__':
    main()
