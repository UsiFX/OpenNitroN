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

pkggrab=$(ps -A -o %CPU,NAME)
cpuisinload=$(ps -A -o %CPU | awk -F: '{if($1>75)print$1}')
cpuisinsuffer=$(ps -A -o %CPU | awk -F: '{if($1>85)print$1}')

auto()
{
	apin -cl
	if [[ "$batt_sts" == "Charging" ]]; then
		magicn -g
		printn -ll "system is charging, relaxing with green mode"
	fi
	if [[ "batt_pctg" -lt "25" ]]; then
		magicn -g
		printn -ll "battery is under %25, applied green mode"
	fi
	if [[ "$cpuisinsuffer" -gt 75 ]]; then
		magicn -r
		printn -ll "cpu is under load applied Red mode, consuming battery."
	elif [[ "$cpuisinload" -gt 85 ]]; then
		magicn -y
		printn -ll "heavy process(es) detected, applied balance mode"
	else
		magicn -g
		printn -ll "no heavy load in CPU, relaxing with green mode"
	fi
	for pkgs in $(cat "$NITRON_RELAX_DIR/nitron.auto.conf")
	do
		for pids in $(pgrep -f "${pkgs[@]}")
		do
			if [[ "$pids" == *"$pkggrab"* ]]; then
				magicn -r
				printn -ll "detected running app which available in configs, applied Red mode."
			fi
		done
	done
}

while true; do
	sleep 150
	auto
done
