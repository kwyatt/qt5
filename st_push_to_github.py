import os
import os.path
import subprocess
import sys
import argparse

modules = [
  'qtbase',
  'qtsvg',
  'qtdeclarative',
  'qtmultimedia',
  'qtxmlpatterns',
  'qtwebkit',
  'qtgraphicaleffects',
  'qtquickcontrols',
  'qt3d',
]

def has_branch(branch, modulepath):
  return subprocess.call(['git', 'show-ref', '--verify', '--quiet', 'refs/heads/%s' % branch], cwd=modulepath) == 0

parser = argparse.ArgumentParser()
parser.add_argument("branch", help="Branch to push upstream")
args = parser.parse_args()

for m in modules:
  modulepath = os.path.abspath(m)

  remote_path = 'https://github.com/suitabletech/%s.git' %  m
  st_branch = 'st-%s' % args.branch

  if has_branch(st_branch, modulepath):
    print 'Pushing %s to %s' % (st_branch, remote_path)
    subprocess.check_call(['git', 'push', remote_path, st_branch], cwd=modulepath)
