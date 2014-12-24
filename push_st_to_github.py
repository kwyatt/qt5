import os
import os.path
import subprocess
import sys
import argparse

modules = [
  'qtbase',
  'qtdeclarative',
  'qtmultimedia',
  'qtquickcontrols',
  'qtwebkit',
]

def has_branch(branch, modulepath):
  return subprocess.call(['git', 'show-ref', '--verify', '--quiet', 'refs/heads/%s' % branch], cwd=modulepath) == 0

parser = argparse.ArgumentParser()
parser.add_argument("branch", help="Branch to push upstream")
args = parser.parse_args()

for m in modules:
  modulepath = os.path.abspath(m)

  remote_path = 'git@github.com:suitabletech/%s' %  m
  st_branch = 'st-%s' % args.branch
  st_staging_branch = 'st-%s-staging' % args.branch

  if has_branch(st_branch, modulepath):
    print 'Pushing %s to %s' % (st_branch, remote_path)
    subprocess.check_call(['git', 'push', remote_path, st_branch], cwd=modulepath)

  if has_branch(st_staging_branch, modulepath):
    print 'Pushing %s to %s' % (st_staging_branch, remote_path)
    subprocess.check_call(['git', 'push', remote_path, st_staging_branch], cwd=modulepath)
  
