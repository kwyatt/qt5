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

for m in modules:
  modulepath = os.path.abspath(m)

  print 'Merging %s stable branch to st' % m
  subprocess.check_call(['git', 'checkout', 'st'], cwd=modulepath)
  subprocess.check_call(['git', 'merge', 'stable'], cwd=modulepath)
  