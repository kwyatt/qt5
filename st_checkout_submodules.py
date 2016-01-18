#!/usr/bin/env python

import os
import os.path
import subprocess
import argparse

scriptdir = os.path.dirname(os.path.abspath(__file__))

parser = argparse.ArgumentParser()
parser.add_argument("--update", help="Pull (rebase) the branch", action="store_true")
parser.add_argument("branch", help="Submodule branch to check out")
args = parser.parse_args()

for f in os.listdir(scriptdir):
    submoduledir = os.path.join(scriptdir, f)
    if os.path.isdir(submoduledir):
        if f[0:2] == "qt":
            print "=== %s..." % f
            if 0 == subprocess.call(["git", "checkout", "%s" % args.branch], cwd=submoduledir):
                if args.update:
                    subprocess.check_call(["git", "pull", "--rebase"], cwd=submoduledir)
