import os
import os.path
import subprocess
import argparse

modules = [
  'qtbase',
  'qtdeclarative',
  'qtmultimedia',
  'qtquickcontrols',
  'qtwebkit',
]

parser = argparse.ArgumentParser()
parser.add_argument("--clean", help="Reset and clean submodules first", action="store_true")
parser.add_argument("branch", help="Upstream release branch to fetch")
args = parser.parse_args()

for m in modules:
  modulepath = os.path.abspath(m)

  # ST derived branch doesn't exist
  if (subprocess.call(['git', 'show-ref', '--verify', '--quiet', 'refs/heads/st-%s' % args.branch], cwd=modulepath)):
    print 'Creating st-%s branch from %s for %s' % (args.branch, args.branch, m)
    subprocess.check_call(['git', 'checkout', args.branch], cwd=modulepath)
    subprocess.check_call(['git', 'checkout', '-b', 'st-%s' % args.branch], cwd=modulepath)

    print 'Here are the available branches for %s' % m
    subprocess.check_call(['git', 'branch', '--list'], cwd=modulepath)

    #print 'Please pick one to rebase (this will run (git rebase --onto st-%s ): '
    #rebase_from  = sys.stdin.readline().rstrip()

  else:
    subprocess.check_call(['git', 'checkout', 'st-%s' % args.branch], cwd=modulepath)
    print '%s exists in %s, skipping' % (args.branch, m)
