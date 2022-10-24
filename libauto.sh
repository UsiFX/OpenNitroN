#
# shellcheck disable=SC2148
# shellcheck disable=SC2034
# shellcheck disable=SC2154
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
relax=$(pidof ${pkgs[@]} | tr ' ' '\n')
pidsavail() { ps -A -o PID | grep -q "$relax" && echo $?;}

auto()
{
		SOURCE="libauto"
		if [[ $(pidsavail) == 0 ]]; then
			if [[ "$batt_pctg" -lt "25" ]]; then
				if [[ "$(apin -mc | awk '{print $2}')" != "green" ]]; then
					magicn -g
					printn -ll "battery is under %25, applied green mode"
				fi
			else
				if [[ "$cputotalusage" -gt "50" ]]; then
					if [[ "$(apin -mc | awk '{print $2}')" != "yellow" ]]; then
						printn -ll "cpu usage is 50%+"
						magicn -y
						printn -ll "heavy process(es) detected, applied balance mode."
					fi
				elif [[ "$cputotalusage" -gt "65" ]]; then
					if [[ "$(apin -mc | awk '{print $2}')" != "red" ]]; then
							printn -ll "cpu usage is 65%+"
							magicn -r
							printn -ll "cpu is under load applied Red mode, consuming battery."
					fi
				fi
			fi
		fi
}

case $@ in
	"-d" | "--daemon")
		while true; do
			auto
		done
	;;
esac
