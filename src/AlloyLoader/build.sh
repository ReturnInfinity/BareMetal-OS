#!/bin/sh

set -e

CC=${CROSS_COMPILE}gcc
CFLAGS="${CFLAGS} -Wall -Wextra -Werror -Wfatal-errors"
CFLAGS="${CFLAGS} -fno-stack-protector -fomit-frame-pointer"
CFLAGS="${CFLAGS} -mno-red-zone"
CFLAGS="${CFLAGS} -std=gnu99"
CFLAGS="${CFLAGS} -g"

LD=${CROSS_COMPILE}ld
LDFLAGS="-T alloy-loader.ld"

OBJCOPY=${CROSS_COMPILE}objcopy

$CC $CFLAGS -c alloy-loader.c
$CC $CFLAGS -c syscalls.c
$LD $LDFLAGS alloy-loader.o syscalls.o -o alloy-loader
$OBJCOPY -O binary alloy-loader alloy-loader.bin
