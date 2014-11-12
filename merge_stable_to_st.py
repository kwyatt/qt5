import os
import os.path
import subprocess
import sys

modules = [
  'qtbase',
  'qtdeclarative',
  'qtmultimedia',
  'qtquickcontrols',
  'qtwebkit',
]

if len(sys.argv < 2):
  print >> sys.stderr, "You must specify which branch to merge from (e.g. 5.4)"
  exit(1)

branch = sys.argv[1]

for m in modules:
  modulepath = os.path.abspath(m)

  print 'Merging %s %s branch to st' % (m, branch)
  subprocess.check_call(['git', 'checkout', 'st'], cwd=modulepath)
  subprocess.check_call(['git', 'merge', branch], cwd=modulepath)

