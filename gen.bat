:: clean
rmdir /s /q ".\windows"

:: generate .lib for windows
call "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvars64.bat"
mkdir ".\windows"
cd ".\quickjs-amalgam"
cl /nologo /c /std:c11 /experimental:c11atomics /O2 /D_WIN32 /DCONFIG_WIN32 "quickjs-amalgam.c" /Fo..\windows\quickjs.obj
cd ..\windows
lib /nologo /OUT:.\libquickjs.lib .\quickjs.obj
del /f ".\quickjs.obj"
cd ".."

:: put lib dir to odin-quickjs
move ".\windows" ".\odin-quickjs\windows"

:: remove leftovers
rmdir /s /q ".\quickjs-amalgam"
