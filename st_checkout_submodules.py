#!/usr/bin/env python

"""Check out submodules to the same version as the root module."""

import os
import os.path
import subprocess
from urlparse import urlparse

script_dir = os.path.dirname(os.path.abspath(__file__))

def main():
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
                print "=== Submodule \"%s\"..." % submodule

                remote_url = subprocess.check_output(["git", "config", "--get", "remote.origin.url"], cwd=submodule_dir).strip()
                remote_host = urlparse(remote_url).hostname
                if remote_host == "github.com":
                    if 0 == subprocess.call(["git", "checkout", "%s" % branch], cwd=submodule_dir):
                        subprocess.check_call(["git", "fetch"], cwd=submodule_dir)
                    else:
                        print "ERROR: Could not check out branch \"%s\" from this submodule! If it doesn't exist, please create it." % branch
                elif remote_host == "code.qt.io":
                    print "This submodule has not been forked into our Git repository. Attempting to check out upstream tag %s..." % upstream_tag
                    if 0 != subprocess.call(["git", "checkout", upstream_tag], cwd=submodule_dir):
                        print "No upstream tag \"%s\" in this submodule." % upstream_tag
                else:
                    print "ERROR: This submodule has an unknown remote host. URL: %s" % remote_url

if __name__ == '__main__':
    main()
