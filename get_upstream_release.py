import os
import os.path
import subprocess
import argparse

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

parser = argparse.ArgumentParser()
parser.add_argument("--clean", help="Reset and clean submodules first", action="store_true")
parser.add_argument("branch", help="Upstream release branch to fetch")
args = parser.parse_args()

for m in modules:
  modulepath = os.path.abspath(m)

  if (args.clean):
    print 'Cleaning %s' % m
    subprocess.check_call(['git', 'reset', '--hard', 'HEAD'], cwd=modulepath)
    subprocess.check_call(['git', 'clean', '-dfx'], cwd=modulepath)

  print 'Updating %s %s branch to upstream' % (m, args.branch)
  upstream_path = 'git://qt.gitorious.org/qt/%s'%m
  # Branch already exists
  if (subprocess.call(['git', 'show-ref', '--verify', '--quiet', 'refs/heads/%s' % args.branch], cwd=modulepath)):
    subprocess.check_call(['git', 'fetch', upstream_path, '%s:%s' % (args.branch, args.branch)], cwd=modulepath)
    subprocess.check_call(['git', 'checkout', '%s' % args.branch], cwd=modulepath)
  else:
    subprocess.check_call(['git', 'checkout', '%s' % args.branch], cwd=modulepath)
    subprocess.check_call(['git', 'pull', upstream_path, '%s' % (args.branch)], cwd=modulepath)
