#!/usr/bin/env python

"""Check out submodules to the same version as the root module."""

import argparse
import os
import os.path
import subprocess
import sys
from urlparse import urlparse

script_dir = os.path.dirname(os.path.abspath(__file__))

def parse_args(args):
    parser = argparse.ArgumentParser(description=__doc__)

    parser.add_argument("-c", "--create", default=False, action="store_true", help="Create the branch from upstream if the forked submodule doesn't contain it.")

    args = parser.parse_args(args)
    return args

def run(args):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("-c", "--create", default=False, action="store_true", help="Create the branch from upstream if the forked submodule doesn't contain it.")

    branch = subprocess.check_output(["git", "rev-parse", "--abbrev-ref", "HEAD"], cwd=script_dir).strip();

    prefix = "st-"
    prefix_length = len(prefix)
    if branch[:prefix_length] != prefix:
        print "ERROR: Branch \"%s\" invalid; must start with \"%s\"." % (branch, prefix)
        exit(1)
    version = branch[prefix_length:]
    upstream_tag = "v%s" % version
    print "Checking out each submodule to version %s..." % version

    submodule_prefix = "qt"
    submodule_prefix_length = len(submodule_prefix)
    for file_name in os.listdir(script_dir):
        submodule_dir = os.path.join(script_dir, file_name)
        if os.path.isdir(submodule_dir):
            if file_name[:submodule_prefix_length] == submodule_prefix:
                submodule = file_name
                print
                print "=== Submodule \"%s\"..." % submodule
                print

                remote_url = subprocess.check_output(["git", "config", "--get", "remote.origin.url"], cwd=submodule_dir).strip()
                remote_host = urlparse(remote_url).hostname
                if remote_host == "github.com":
                    if 0 == subprocess.call(["git", "checkout", "%s" % branch], cwd=submodule_dir):
                        subprocess.check_call(["git", "fetch"], cwd=submodule_dir)
                    elif args.create:
                        print "Could not check out branch \"%s\" from this submodule. Attempting to create branch from upstream..." % branch

                        subprocess.check_call(["git", "fetch", "--tags", "git://code.qt.io/qt/%s.git" % submodule], cwd=submodule_dir)
                        if 0 == subprocess.call(["git", "checkout", upstream_tag], cwd=submodule_dir):
                            subprocess.check_call(["git", "checkout", "-b", branch], cwd=submodule_dir)
                            print "Created branch \"%s\" from upstream tag %s." % (branch, upstream_tag)
                            print "*IMPORTANT*: Ensure that all of our changes from the previous version are cherry-picked into this new branch!"
                        else:
                            print "No upstream tag \"%s\" in this submodule." % upstream_tag
                    else:
                        print "ERROR: Could not check out branch \"%s\" from this submodule! If it doesn't exist, please create it." % branch
                        print "You can create the branch automatically by calling this script with the \"--create\" argument."

                elif remote_host == "code.qt.io":
                    print "This submodule has not been forked into our Git repository. Attempting to check out upstream tag %s..." % upstream_tag
                    if 0 != subprocess.call(["git", "checkout", upstream_tag], cwd=submodule_dir):
                        print "No upstream tag \"%s\" in this submodule." % upstream_tag
                else:
                    print "ERROR: This submodule has an unknown remote host. URL: %s" % remote_url

if __name__ == '__main__':
    sys.exit(run(parse_args(sys.argv[1:])))
