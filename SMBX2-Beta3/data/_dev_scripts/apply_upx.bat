set STUFF=%CD%\..
call :packit Qt5Core.dll
call :packit Qt5Gui.dll
call :packit Qt5Widgets.dll
call :packit Qt5WebKit.dll
call :packit Qt5Quick.dll
call :packit Qt5Qml.dll
call :packit Qt5Network.dll
call :packit MemoryScanner.exe
call :packit icudt54.dll
call :packit icuin54.dll
call :packit icuuc54.dll
call :packit libstdc++-6.dll
call :packit libmikmod-3.dll
call :packit SDL2.dll
call :packit SDL2_mixer_ext.dll

goto ExitX

:packit
    upx.exe -9 %STUFF%\%1
	GOTO :EOF

:ExitX