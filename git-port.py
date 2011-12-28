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

    for file in (repo.untracked_files):
      if not file.endswith('.patch'):
        print "Untracked non patch file."
        return

    repo.git.apply(sys.argv[1])


if __name__ == '__main__':
    main()
