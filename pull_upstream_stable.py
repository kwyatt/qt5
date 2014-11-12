import os
import os.path
import subprocess
import sys

modules = [
  'qtactiveqt',
  'qtbase',
  'qtdeclarative',
  'qtdoc',
  'qtgraphicaleffects',
  'qtimageformats',
  'qtmultimedia',
  'qtquickcontrols',
  'qtsvg',
  'qttools',
  'qttranslations',
  'qtwebkit',
  'qtxmlpatterns',
]

if len(sys.argv < 2):
  print >> sys.stderr, "You must specify which branch to merge from (e.g. 5.4)"
  exit(1)

branch = sys.argv[1]

clean = False
if (len(sys.argv) > 2 and sys.argv[2] == '--clean'):
  clean = True

for m in modules:
  modulepath = os.path.abspath(m)

  if (clean):
    print 'Cleaning %s' % m
    subprocess.check_call(['git', 'reset', '--hard', 'HEAD'], cwd=modulepath)
    subprocess.check_call(['git', 'clean', '-dfx'], cwd=modulepath)

  print 'Updating %s %s branch to upstream' % (m, branch)
  upstream_path = 'git://qt.gitorious.org/qt/%s'%m
  if (subprocess.call(['git', 'show-ref', '--verify', '--quiet', 'refs/heads/%s' % branch], cwd=modulepath)):
    # local stable branch does not exist
    subprocess.check_call(['git', 'fetch', upstream_path, '%s:%s' % (branch, branch)], cwd=modulepath)
  else:
    # local stable branch exists
    subprocess.check_call(['git', 'checkout', branch], cwd=modulepath)
    subprocess.check_call(['git', 'pull', upstream_path, branch], cwd=modulepath)

