@echo off

git submodule update --init --recursive

call ".\build.bat"
call ".\install.bat"
