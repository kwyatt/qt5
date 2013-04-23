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
  'qtjsbackend',
  'qtmultimedia',
  'qtquickcontrols',
  'qtscript',
  'qtsvg',
  'qttools',
  'qttranslations',
  'qtwebkit',
  'qtxmlpatterns',
]

clean = False
if (len(sys.argv) > 1 and sys.argv[1] == '--clean'):
  clean = True

for m in modules:
  modulepath = os.path.abspath(m)

  if (clean):
    print 'Cleaning %s' % m
    subprocess.check_call(['git', 'reset', '--hard', 'HEAD'], cwd=modulepath)
    subprocess.check_call(['git', 'clean', '-dfx'], cwd=modulepath)

  print 'Updating %s stable branch to upstream' % m
  upstream_path = 'git://qt.gitorious.org/qt/%s'%m
  if (subprocess.call(['git', 'show-ref', '--verify', '--quiet', 'refs/heads/stable'], cwd=modulepath)):
    # local stable branch does not exist
    subprocess.check_call(['git', 'fetch', upstream_path, 'stable:stable'], cwd=modulepath)
  else:
    # local stable branch exists
    subprocess.check_call(['git', 'checkout', 'stable'], cwd=modulepath)
    subprocess.check_call(['git', 'pull', upstream_path, 'stable'], cwd=modulepath)
  