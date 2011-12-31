#!/usr/bin/env python

"""
"""

import optparse

from git import Git, Repo

def main():
    # Initialize a repo object.
    Git.git_binary = 'git'
    repo = Repo('.')

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
    #    print "Untracked non patch file."
    #    return

    # TODO: Make -p0 optional.
    # TODO: Try not to alter the working copy.
    # TODO: Start the rebase.
    looping = True
    while looping:
        try:
            repo.git.apply('-p0', patch)
            looping = False
        except:
            repo.git.reset('--hard', 'HEAD~1')
if __name__ == '__main__':
    main()
