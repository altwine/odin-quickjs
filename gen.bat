@echo off

:: select currect script dir
cd /d "%~dp0"

:: clean
rmdir /s /q ".\windows"

:: generate .lib for windows
call "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat"
mkdir ".\windows"
pushd ".\quickjs-amalgam"
cl /nologo /c /std:c11 /experimental:c11atomics /O2 /D_WIN32 /DCONFIG_WIN32 "quickjs-amalgam.c" /Fo..\windows\quickjs.obj
popd
pushd .\windows
lib /nologo /OUT:.\libquickjs.lib .\quickjs.obj
del /f ".\quickjs.obj"
popd

:: put lib dir to odin-quickjs
move ".\windows" ".\odin-quickjs\windows"

:: remove leftovers
rmdir /s /q ".\quickjs-amalgam"
