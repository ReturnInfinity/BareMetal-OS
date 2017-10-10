@echo off

If Not Exist "src" (
	mkdir "src"
)

If Not Exist "bin" (
	mkdir "bin"
)

If Not Exist "src/BMFS" (
	cd "src"
	git clone "https://github.com/ReturnInfinity/BMFS"
	cd ".."
) Else (
	cd "src/BMFS"
	git pull origin master
	cd "../.."
)

If Not Exist "src/Pure64" (
	cd "src"
	git clone "https://github.com/ReturnInfinity/Pure64"
	cd ".."
) Else (
	cd "src/Pure64"
	git pull origin master
	cd "../.."
)

If Not Exist "src/BareMetal-kernel" (
	cd "src"
	git clone "https://github.com/ReturnInfinity/BareMetal-kernel"
	cd ".."
) Else (
	cd "src/BareMetal-kernel"
	git pull origin master
	cd "../.."
)

call ".\build.bat"
call ".\install.bat"
