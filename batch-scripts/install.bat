@echo off

call ".\bin\BMFS\src\Debug\bmfs.exe" "bin\bmfs.image" initialize 128M "bin\bmfs_mbr.sys" "bin\pure64.sys" "bin\kernel.sys"

