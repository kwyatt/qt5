import os
import os.path
import sys
import platform
import subprocess
import shutil
from optparse import OptionParser

# This script assumes that you have a 'sw-dev' checkout at the same level as this script (unless you pass --swdev)
# and that the working directory is the qt5 repo

def parse_options(args):
  parser = OptionParser()
  parser.add_option("--swdev", dest="swdev", default='sw-dev', type="string")
  parser.add_option("--os", dest="os", default=None, type="string")
  (options, args) = parser.parse_args(args)
  return options

options = parse_options(sys.argv)

if (not options.os):
  print "--os [win32|win64|macosx|linux] is required"
  sys.exit(1)

def swdevpath(path):
  return os.path.join(options.swdev, path)

dump_syms = {
  'Windows': swdevpath('stacks/texas_videoconf/third_party/third_party/breakpad/tools/windows/binaries/dump_syms.exe'),
  'Linux': swdevpath('stacks/texas_videoconf/third_party/third_party/breakpad/tools/linux/dump_syms/dump_syms'),
  'Darwin': swdevpath('stacks/texas_videoconf/third_party/third_party/breakpad/tools/mac/dump_syms/build/Release/dump_syms')
}

build_dump_syms = {
  'Windows': None, 
  'Linux': swdevpath('build_scripts/build_dump_syms_linux.sh'),
  'Darwin': swdevpath('build_scripts/build_dump_syms_osx.sh')
}

windows = platform.system() == 'Windows'

if (options.os == 'win64'):
  print "Symbol upload for x64 not yet supported. See http://code.google.com/p/google-breakpad/issues/detail?id=427"
  sys.exit(0)

shutil.rmtree('symbols', True)

symbolstore = swdevpath('stacks/texas_videoconf/third_party/third_party/breakpad/tools/symbolstore.py')
symbolupload = swdevpath('stacks/texas_videoconf/scripts/upload_symbols.py')

if (build_dump_syms[platform.system()]):
  subprocess.check_call([build_dump_syms[platform.system()]])

args = ['python', symbolstore, dump_syms[platform.system()], 'symbols', '.']
print args
subprocess.check_call(args)

cmd = ['python', symbolupload, 'symbols', '-o', options.os, '-c', 'Final', '--software-channel', 'qt-symbols', '--software-version', '1']
subprocess.check_call(cmd)