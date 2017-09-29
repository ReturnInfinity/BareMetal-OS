@echo off

set topdir=%CD%

If Not Exist "bin/BMFS" (
	mkdir "bin/BMFS"
)
cd "bin/BMFS"
cmake "%topdir%/src/BMFS"
cmake --build "."
cd "../.."

cd "src/Pure64"
call "./build.bat"
move "*.sys" "../../bin"
cd "../.."

cd "src/BareMetal-kernel"
call "./build_x86-64.bat"
move "*.sys" "../../bin"
move "*.txt" "../../bin"
cd "../.."
