echo off
set masm_dir=C:\masm32
set include=%masm_dir%\Include
set lib=%masm_dir%\lib
set path=%masm_dir%\Bin;%masm_dir%;%path%

rem 由于需要用到vc++的nmake程序来对项目进行构建，所以请设定好VsDevCmd的路径
set vc_dev_bat_path="C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\Tools\VsDevCmd.bat"
call %vc_dev_bat_path%

nmake %1
