#!/usr/bin/env python

import os
import os.path as path
import sys
import platform
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--android', dest='android', action='store_true')
parser.add_argument('--ios', dest='ios', action='store_true')
parser.add_argument('--nacl', dest='nacl', action='store_true')
parser.add_argument('--arch', dest='arch', action='store')

args = parser.parse_args()

tc_conf = os.environ.get('TEAMCITY_BUILDCONF_NAME', None)

if tc_conf:
  if (tc_conf.find('android') != -1):
    args.android = True
    if (tc_conf.find('x86') != -1):
      args.arch = 'x86'
    elif (tc_conf.find('arm') != -1):
      args.arch = 'armeabi-v7a'
  if (tc_conf.find('nacl') != -1):
    args.nacl = True
  if (tc_conf.find('ios') != -1):
    args.ios = True
  
scriptdir = path.dirname(path.abspath(__file__))
windows = platform.system() == 'Windows'
linux = platform.system() == 'Linux'
osx = platform.system() == 'Darwin'

os.system('git clean -dfx --exclude=sw-dev')
os.system('git submodule foreach --recursive "git clean -dfx"')
os.system('perl %s/init-repository -f' % scriptdir)

if args.android:
  if not args.arch:
    print >> sys.stderr, "Must specify arch when compiling for Android"
    exit(-1)
  if osx:
    plat = 'osx'
  elif linux:
    plat = 'linux'
  else:
    plat = 'win32'
    if (tc_conf and tc_conf.lower().find('win64') != -1):
      plat = 'win64'
  print "st_build_android.sh %s %s" % (plat, args.arch)
  exit(os.system(path.join(scriptdir, "st_build_android.sh %s %s" % (plat, args.arch))))
elif args.nacl:
  if osx:
    build_os = 'osx'
    plat = 'mac'
  elif linux:
    build_os = 'linux'
    plat = 'linux'
  print "st_build_nacl.sh %s %s" % (build_os, plat)
  exit(os.system(path.join(scriptdir, "st_build_nacl.sh %s %s" % (build_os, plat))))
elif args.ios:
  print "st_build_ios.sh"
  exit(os.system(path.join(scriptdir, "st_build_ios.sh")))
elif (windows):
  arch = 'win32'
  if (tc_conf and tc_conf.lower().find('win64') != -1):
    arch = 'win64'
  print "st_build_%s.bat" % arch
  exit(os.system(path.join(scriptdir, "st_build_%s.bat" % arch)))
elif (linux):
  bits = '64'
  arch = 'x64'
  if (tc_conf and tc_conf.lower().find('linux32') != -1):
    bits = '32'
    arch = 'x86'
  print "st_build_linux.sh %s %s" % (bits, arch)
  exit(os.system(path.join(scriptdir, "st_build_linux.sh %s %s" % (bits, arch))))
elif (osx):
  print "st_build_osx.sh"
  exit(os.system(path.join(scriptdir, "st_build_osx.sh")))
