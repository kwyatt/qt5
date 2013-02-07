import os
import os.path as path
import sys
import platform

tc_conf = os.environ.get('TEAMCITY_BUILDCONF_NAME', None)

scriptdir = path.dirname(path.abspath(__file__))
windows = platform.system() == 'Windows'
linux = platform.system() == 'Linux'
osx = platform.system() == 'Darwin'

os.system('git clean -dfx')
os.system('git submodule foreach --recursive "git clean -dfx"')
os.system('perl %s/init-repository -f' % scriptdir)

if (windows):
  arch = 'win32'
  if (tc_conf and tc_conf.lower().find('win64') != -1):
    arch = 'win64'

  exit(os.system(path.join(scriptdir, "st_build_%s.bat"%arch)))
elif (linux):
  bits = '64'
  arch = 'x64'
  if (tc_conf and tc_conf.lower().find('linux32') != -1):
    bits = '32'
    arch = 'x86'
  exit(os.system(path.join(scriptdir, "st_build_linux.sh %s %s"%(bits, arch))))
elif (osx):
  exit(os.system(path.join(scriptdir, "st_build_osx.sh")))