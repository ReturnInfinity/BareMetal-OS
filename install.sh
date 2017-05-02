#!/bin/sh

cd bin
echo Writing Pure64+Software
cat pure64.sys kernel64.sys > software.sys
dd if=software.sys of=bmfs.image bs=512 seek=16 conv=notrunc
# ignore creation error because it probably
# is because the file already exists
./bmfs bmfs.image create alloy.app 2M || true
./bmfs bmfs.image write alloy.app
