#!/usr/bin/env python

"""Check out submodules to the same branch as the root module."""

import os
import os.path
import subprocess
from urlparse import urlparse

script_dir = os.path.dirname(os.path.abspath(__file__))

def main():
    branch = subprocess.check_output(["git", "rev-parse", "--abbrev-ref", "HEAD"], cwd=script_dir).strip();
    print "Checking out each submodule to %s..." % branch

    for file_name in os.listdir(script_dir):
        submodule_dir = os.path.join(script_dir, file_name)
        if os.path.isdir(submodule_dir):
            if file_name[0:2] == "qt":
                submodule = file_name
                print "=== Submodule \"%s\"..." % submodule

                remote_url = subprocess.check_output(["git", "config", "--get", "remote.origin.url"], cwd=submodule_dir).strip()
                remote_host = urlparse(remote_url).hostname
                if remote_host == "github.com":
                    if 0 == subprocess.call(["git", "checkout", "%s" % branch], cwd=submodule_dir):
                        subprocess.check_call(["git", "fetch"], cwd=submodule_dir)
                    else:
                        print "ERROR: Could not check out branch \"%s\" from this submodule! If it doesn't exist, please create it." % branch
                elif remote_host == "code.qt.io":
                    print "This submodule has not been forked into our Git repository."
                else:
                    print "This submodule has an unknown remote URL: %s" % remote_url

if __name__ == '__main__':
    main()
