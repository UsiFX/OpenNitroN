#
# nitronD AutoMaticProfiler
#
# Copyright Identiter: GPL-3.0
# Copyright (C) 2022~2023 UsiFX <xprjkts@gmail.com>
#

[[ ! -f "$NITRON_RELAX_DIR/nitron.auto.conf" ]] && echo "# The nitrond Config File
# Optimise packages up on resource usage and load
# List all package/app names according to your needs
com.tencent.ig
com.mojang.minecraftpe
com.activision.callofduty.shooter
" >> "$NITRON_RELAX_DIR/nitron.auto.conf"

NITRON_LIBAUTO_VERSION='1.0.2'
pkgs=$(cat "$NITRON_RELAX_DIR/nitron.auto.conf")
printavailpids=$(ps -A -o PID)
cpuisinload=$(ps -A -o %CPU | awk -F: '{if($1>75)print$1}')
cpuisinsuffer=$(ps -A -o %CPU | awk -F: '{if($1>85)print$1}')

printn -ll "nitrond: starting modifying modes up on Packages availability & Resource usage"

auto()
{
	apin -cl
	for relax in $(pidof ${pkgs[@]})
	do
		if [[ "$relax" == *"$printavailpids"* ]]; then
			if [[ "batt_pctg" -lt "25" ]]; then
				magicn -g
				printn -ll "battery is under %25, applied green mode"
			fi
			if [[ "$cpuisinsuffer" -gt 75 ]]; then
				magicn -y
				printn -ll "heavy process(es) detected, applied balance mode"
			elif [[ "$cpuisinload" -gt 85 ]]; then
				magicn -r
				printn -ll "cpu is under load applied Red mode, consuming battery."
			fi
		fi
	done
}

case $@ in
	"-d" | "--daemon")
		while true; do
			sleep 120
			auto
		done
	;;
esac
