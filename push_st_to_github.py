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

  remote_path = 'git@github.com:suitabletech/%s' %  m

  print 'Pushing %s to %s' % (m, remote_path)
  subprocess.check_call(['git', 'push', remote_path, 'st'], cwd=modulepath)
  