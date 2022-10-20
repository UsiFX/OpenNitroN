#!/system/bin/sh
#
# Service Runner, Simple MMT
#
# Copyright Identiter: GPL-3.0
# Copyright (C) 2022~2023 UsiFX <xprjkts@gmail.com>
# Copyright (C) 2022~2023 Pedrozzz0 <guitopzika26@gmail.com>
#

modpath="/data/adb/modules/nitrond.magisk"

# Wait to boot be completed
until [[ "$(getprop sys.boot_completed)" -eq "1" ]] || [[ "$(getprop dev.bootcomplete)" -eq "1" ]]; do
	sleep 1
done

# work on clean
nitrond clean >/dev/null

sleep 100

# update on every boot
nitrond --update >/dev/null

# dump information
nitrond deviceinfo >> "/sdcard/nitron.boot.log"

nitrond &
