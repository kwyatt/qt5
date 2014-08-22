import os
import os.path
import sys
import platform
import subprocess
import shutil
from optparse import OptionParser

# This script assumes that you have a 'sw-dev' checkout at the same level as this script (unless you pass --swdev)
# and that the working directory is the qt5 build directory (which is the qt5 repo directory by default)

def parse_options(args):
  parser = OptionParser()
  parser.add_option("--swdev", dest="swdev", default='sw-dev', type="string")
  parser.add_option("--os", dest="os", default=None, type="string")
  (options, args) = parser.parse_args(args)
  return options

options = parse_options(sys.argv)

if (not options.os):
  print "--os [win32|win64|macosx|linux|android|ios] is required"
  sys.exit(1)

def swdevpath(path):
  return os.path.join(options.swdev, path)

win_dump_syms = swdevpath('stacks/texas_videoconf/third_party/third_party/breakpad/tools/windows/binaries/dump_syms.exe')
linux_dump_syms = swdevpath('stacks/texas_videoconf/third_party/third_party/breakpad/tools/linux/dump_syms/dump_syms')
mac_dump_syms = swdevpath('stacks/texas_videoconf/third_party/third_party/breakpad/tools/mac/dump_syms/build/Release/dump_syms')

dump_syms = {
  'win64': win_dump_syms,
  'win32': win_dump_syms,
  'linux': linux_dump_syms,
  'android': linux_dump_syms,
  'macosx': mac_dump_syms,
  'ios': mac_dump_syms,
}

linux_build_dump_syms = swdevpath('build_scripts/build_dump_syms_linux.sh')
mac_build_dump_syms = swdevpath('build_scripts/build_dump_syms_osx.sh')

build_dump_syms = {
  'win32': None,
  'win64': None,
  'linux': linux_build_dump_syms,
  'android': linux_build_dump_syms,
  'macosx': mac_build_dump_syms,
  'ios': mac_build_dump_syms,
}

if (options.os == 'win64'):
  print "Symbol upload for x64 not yet supported. See http://code.google.com/p/google-breakpad/issues/detail?id=427"
  sys.exit(0)

shutil.rmtree('symbols', True)

symbolstore = swdevpath('stacks/texas_videoconf/third_party/third_party/breakpad/tools/symbolstore.py')
symbolupload = swdevpath('stacks/texas_videoconf/scripts/upload_symbols.py')

build = build_dump_syms[options.os]
if (build):
  subprocess.check_call([build])

args = ['python', symbolstore, dump_syms[options.os], 'symbols', '.']
subprocess.check_call(args)

cmd = ['python', symbolupload, 'symbols', '-o', options.os, '-c', 'Final', '--software-channel', 'qt-symbols', '--software-version', '1']
subprocess.check_call(cmd)