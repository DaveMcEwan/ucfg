#!/usr/bin/env bash
#if 0 // {{{
# Bash header to compile and execute the rest of the file with a C compiler.
# Based on https://github.com/wd5gnr/cscript

# Compile iff this file is newer than exe, or exe doesn't exist.
if [ "$0" -nt "$0.exe" ]
then
  CC="gcc" # Either gcc or clang will work (if installed).
  CCOPTS="-O2 -lm"; #echo $CC $CCOPTS

  # Pipe this file through compiler.
  # NOTE: 25 is size of this Bash header, which is discarded by tail for CC.
  if ! tail -n +25 "$0" | ${CC} ${CCOPTS} -o "$0.exe" -xc -
  then
    echo Compiler error on $0
    exit 999
  fi
fi

# Replace current shell process with executable
# No further lines are touched by the Bash interpreter.
exec "$0.exe" $@
#endif // }}} End of Bash header. C begins on next line.

// Run with something like this:
//    $ ./hello.c.sh 1stArg 2ndArg

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int main(int argc, char *argv[]) {
  printf("Hello from C acting like a Bash script!\n");
  printf("pi=%f\n", acos(-1.0));
  for (int i=1; i < argc; i++) {
    printf("arg%d=%s\n", i, argv[i]);
  }
  exit(0);
}
