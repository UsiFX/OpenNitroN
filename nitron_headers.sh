#
# shellcheck disable=SC2148
# shellcheck disable=SC2034
#
# nitronD Headers.
#
# Copyright Identiter: GPL-3.0
# Copyright (C) 2022~2023 UsiFX <xprjkts@gmail.com>
#

export NITRON_HEADER_VERSION='2.0.0'

cmdavail() {
	PR_PREFIX="cmdavail"
	if command -v "$1" >/dev/null; then
		printn -l "$1: available"
		return 0
	else
		printn -lf "$1: unavailable"
		return 1
	fi
}

# infogrbn <directory> <value>
infogrbn() { grep "$2" "$1" | awk '{ print $2 }';}

# infogrblongn <directory> <value>
infogrblongn() { grep "$2" "$1" | awk '{ print $3,$4,$5,$6 }';}

setmoden() { echo "$1" > "$NITRON_LOG_DIR"/nitron.mode.lock ;}

modelockn()
{
	if [[ ! -f "$NITRON_LOG_DIR"/nitron.mode.lock ]]; then
		setmoden "UnInitialised"
	fi
	MODES=$(cat "$NITRON_LOG_DIR"/nitron.mode.lock)
	case "$MODES" in
		"Battery")
			setmoden "Battery"
		;;
		"Balanced")
			setmoden "Balanced"
		;;
		"Gaming")
			setmoden "Gaming"
		;;
	esac
}

apin() {
	cpu_gov=$(cat "/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor")

	# Number of CPU cores
	nr_cores=$(awk -F "-" '{print $2}' "/sys/devices/system/cpu/possible")
	nr_cores=$((nr_cores + 1))

	# Battery info
	# Current battery capacity available
	[[ -e "/sys/class/power_supply/battery/capacity" ]] && batt_pctg=$(cat /sys/class/power_supply/battery/capacity) || batt_pctg=$(dumpsys battery 2>/dev/null | awk '/level/{print $2}')

	# Battery health
	batt_hth=$(dumpsys battery | awk '/health/{print $2}')
	[[ -e "/sys/class/power_supply/battery/health" ]] && batt_hth=$(cat /sys/class/power_supply/battery/health)
	case "$batt_hth" in
		1) batt_hth="Unknown" ;;
		2) batt_hth="Good" ;;
		3) batt_hth="Overheat" ;;
		4) batt_hth="Dead" ;;
		5) batt_hth="OV" ;;
		6) batt_hth="UF" ;;
		7) batt_hth="Cold" ;;
	esac

	# Battery status
	batt_sts=$(dumpsys battery | awk '/status/{print $2}')
	[[ -e "/sys/class/power_supply/battery/status" ]] && batt_sts=$(cat /sys/class/power_supply/battery/status)
	case "$batt_sts" in
		1) batt_sts="Unknown" ;;
		2) batt_sts="Charging" ;;
		3) batt_sts="Discharging" ;;
		4) batt_sts="Not charging" ;;
		5) batt_sts="Full" ;;
	esac

	# Battery total capacity
	batt_cpct=$(cat /sys/class/power_supply/battery/charge_full_design)
	[[ "$batt_cpct" == "" ]] && batt_cpct=$(dumpsys batterystats | awk '/Capacity:/{print $2}' | cut -d "," -f 1)

	instype()
	{
		if [[ "$(su --version)" == *"MAGISK"* ]]; then
			if [[ -d "/data/adb/modules/nitrond.magisk" ]]; then
				INSTALLATION="Magisk Module"
			fi
		else
			INSTALLATION="Custom"
		fi
	}

	androiddevinfo()
	{
		# Device info
		# Codename
		dvc_cdn=$(getprop ro.product.device)

		# Device brand
		dvc_brnd=$(getprop ro.product.brand)

		# ROM info
		# Fingerprint, keys and related stuff
		rom_info=$(getprop ro.build.description | awk '{print $1,$3,$4,$5}')
		[[ "$rom_info" == "" ]] && rom_info=$(getprop ro.bootimage.build.description | awk '{print $1,$3,$4,$5}')
		[[ "$rom_info" == "" ]] && rom_info=$(getprop ro.system.build.description | awk '{print $1,$3,$4,$5}')

		# ARV (Android release version)
		arv=$(getprop ro.build.version.release)

		echo "Android Device Codename: $dvc_cdn"
		echo "Android Device Brand: $dvc_brnd"
		echo "Android ROM Info: $rom_info"
		echo "Android Release Version: $arv"
	}
	resrchk()
	{
		echo "PID: $$"
		echo "OS: $PLATFORM"
		echo "Kernel: $(uname -sr)"
		echo "SU Provider: $(su --version)"
		echo "Memory: $(( $(infogrbn "/proc/meminfo" "MemTotal") / 1024 / 1024))gb"
		echo "Hardware: $(infogrblongn "/proc/cpuinfo" "Hardware")"
		echo "Machine: $(uname -m)"
		echo "CPU Governor: $cpu_gov"
		echo "CPU Cores: $nr_cores"
		echo "Battery Percentage: $batt_pctg%"
		echo "Battery Health: $batt_hth"
		echo "Battery Status: $batt_sts"
		echo "Battery Capacity: $batt_cpct"
		[[ "$PLATFORM" == "Android" ]] && androiddevinfo
		echo "Nitron Daemon Version: $(apin -dv)"
		echo "Nitron Header Version: $(apin -hv)"
		echo "Nitron Installation type: $INSTALLATION"
	}

	__api_help()
	{
		echo "
Usage: apin [OPTION(s)] (e.g. apin -rc)

Options:
  -rc, --resource-check		~ prints hardware resources information
  -dv, --daemon-version         ~ prints daemon version
  -hv, --header-version         ~ prints header version
  -h, --help			~ prints this help menu
"
	}

	instype
	case $* in
		"-rc" | "--resource-check")
			resrchk
		;;
		"-dv" | "--daemon-version")
			echo "$NITRON_VERSION"
		;;
		"-hv" | "--header-version")
			echo "$NITRON_HEADER_VERSION"
		;;
		"-mc" | "--mode-check")
			modelockn
			echo "$MODES"
		;;
		"-as" | "--android-status")
			if [[ "$PLATFORM" == "Android" ]]; then
				if [[ "$INSTALLATION" == "Magisk Module" ]]; then
					case "$(apin -mc)" in
						"Battery")
							sed -i '/description=/s/.*/description=[ 🟩 Green mode applied ], Extensive Optmized Kernel Tweaker Daemon By: TITΛN × Noobies./' "/data/adb/modules/nitrond.magisk/module.prop"
						;;
						"Balanced")
							sed -i '/description=/s/.*/description=[ 🟨 Balanced mode applied ], Extensive Optmized Kernel Tweaker Daemon By: TITΛN × Noobies./' "/data/adb/modules/nitrond.magisk/module.prop"
						;;
						"Gaming")
							sed -i '/description=/s/.*/description=[ 🟥 Gaming mode applied ], Extensive Optmized Kernel Tweaker Daemon By: TITΛN × Noobies./' "/data/adb/modules/nitrond.magisk/module.prop"
						;;
						*)
							sed -i '/description=/s/.*/description=[ 🤔 Uninitialized ], Extensive Optmized Kernel Tweaker Daemon By: TITΛN × Noobies./' "/data/adb/modules/nitrond.magisk/module.prop"
						;;
					esac
				fi
			fi
		;;
		"-c" | "--clean")
			UPDATECACHE=("$NITRON_LOG_DIR/nitrond_src_cache" "$NITRON_LOG_DIR/nitronh_src_cache")
			BACKUPCACHE=("$NITRON_LOG_DIR/nitrond_current" "$NITRON_LOG_DIR/nitronh_current")
			MODELOCK="$NITRON_LOG_DIR/nitron.mode.lock"
			printn -i "Removing update caches..."
			rm -rf "${UPDATECACHE[@]}"
			printn -i "Removing Old Backups..."
			rm -rf "${BACKUPCACHE[@]}"
			printn -i "Resetting Mode information..."
			rm -rf "$MODELOCK"
			modelockn
		;;
		*)
			__api_help
		;;
	esac
}

console_dialog() {
	PR_PREFIX="console_dialog"
	HEIGHT=16
	WIDTH=40
	CHOICE_HEIGHT=30
	BACKTITLE="The Open NitroN Kernel tweaking Project"
	MENU="Choose one of the following options: "
	OPTIONS=(1 "Switch Mode"
		2 "Show device stats"
		3 "Update"
		4 "Show help menu"
		5 "Exit"
	)
	CHOICE=$(dialog --clear \
		--backtitle "$BACKTITLE" \
		--title "$TITLE" \
		--menu "$MENU" \
		$HEIGHT $WIDTH $CHOICE_HEIGHT \
		"${OPTIONS[@]}" \
		2>&1 >/dev/tty)
	clear
	case "${CHOICE}" in
		*) printn -e "WIP" ;;
	esac
}

print_banner() {
	echo "
███╗░░██╗██╗████████╗██████╗░░█████╗░███╗░░██╗
████╗░██║░░║╚══██╔══╝██╔══██╗██╔══██╗████╗░██║
██╔██╗██║██║░░░██║░░░██████╔╝██║░░██║██╔██╗██║
██║╚████║██║░░░██║░░░██╔══██╗██║░░██║██║╚████║
██║░╚███║██║░░░██║░░░██║░░██║╚█████╔╝██║░╚███║
╚═╝░░╚══╝╚═╝░░░╚═╝░░░╚═╝░░╚═╝░╚════╝░╚═╝░░╚══╝
"
}

console_legacy() {
	PR_PREFIX="console_legacy"
	while :
	do
	clear
	print_banner
	COLUMNS=150
	OPTIONS=("Switch Mode" "Show device state" "Update" "Show help menu" "Exit")
	PS3="?): "
		select CHOICE in "${OPTIONS[@]}"; do
			num=$REPLY
			case $num in
				1)
					while :; do
						clear
						print_banner
						COLUMNS=150
						MODE_OPTIONS=("Gaming" "Balance" "Battery" "Back to main menu" "Exit")
						PS3="?): "
						select MODE_CHOICE in "${MODE_OPTIONS[@]}"; do
							mode_num=$REPLY
							case $mode_num in
								1)
									magicn -r
									printn -i "Process complete!"
									sleep 2
									break
									;;
								2)
									magicn -y
									printn -i "Process complete!"
									sleep 2
									break
									;;
								3)
									magicn -g
									printn -i "Process complete!"
									sleep 2
									break
									;;
								4)
									break 3
									;;
								5)
									exit 0
									;;
								*)
									printn -e "[$mode_num] unknown option"
									sleep 2
									break
									;;
							esac
						done
					done
					;;
				2)
					apin -rc
					;;
				3)
					updaten
					break
					;;
				4)
					__nitron_help
					;;
				5)
					break 2
					;;
				*)
					printn -w "[$num] unknown option"
					sleep 2
					break
					;;
			esac
		done
	done
}

oschk()
{
	PR_PREFIX="oschk"
	OSCHK=$(uname -o)

	case "$OSCHK" in
		"GNU/Linux")
			PLATFORM="GNU/Linux"
			printn -l "OS: $PLATFORM"
			return 0
		;;
		"Linux")
			if grep -q "androidboot" /proc/cmdline; then
				PLATFORM="Android"
			else
				PLATFORM="Linux"
			fi
			printn -l "OS: $PLATFORM"
			return 0
		;;
		*)
			PLATFORM="Unknown"
			printn -lf "OS: $PLATFORM"
			printn -e "Unknown Operating System, cannot start."
		;;
	esac
}
