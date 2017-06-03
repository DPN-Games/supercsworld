@echo off
rem To build this application you shuld setup a MinGW compiller into the path enveromnet

set OPTFLAGS=-O2 -O3
set LDFlags=-lkernel32 -nodefaultlibs -nostdlib -Wl,--subsystem,windows

echo Running winres to build resources...
windres iconsetup.rc  --codepage=65001 -O coff -o iconsetup.res
IF ERRORLEVEL 1 goto quit
@echo on
gcc -DUNICODE -D_UNICODE -D _STRING_H_ -c %OPTFLAGS% -nostdlib sub-launcher.c
    @IF ERRORLEVEL 1 goto quit
gcc sub-launcher.o iconsetup.res %OPTFLAGS% -o ../../../SMBX2 %LDFlags%

@echo off
del *.o
del iconsetup.res

:quit
@echo off
pause
