import os
import sys

os.execvp(sys.executable, [sys.executable] + sys.argv[1:])
