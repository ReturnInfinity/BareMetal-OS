#!/bin/sh

if [ ! -e src/BareMetal-newlib ]; then
  git clone https://github.com/ReturnInfinity/BareMetal-newlib.git src/BareMetal-newlib
else
  git --git-dir=src/BareMetal-newlib/.git pull origin master
fi

cd src/BareMetal-newlib
./build-newlib.sh
