A tiny launcher of launcher. Just starts true launcher by relative path
========================================================================
To change target EXE name, just modify a line in sub-launcher.c :
---------------------------------------------------------------
const wchar_t *runApp = L"\\..\\SMBXLauncher.exe";
//(currently it launches SMBXLauncher.exe in parent directory at it's current location)
---------------------------------------------------------------

To build it, you need to have a MinGW in the path environment, and then run "build.bat"

Note: Any C/C++ std/stl libraries are completely disabled to reduce size of exe and has no extra DLL dependencies!
So, use WinAPI or custom implementations of some functions
