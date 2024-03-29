#
# shellcheck disable=SC2148
# shellcheck disable=SC2034
# shellcheck disable=SC2117
# shellcheck disable=SC2148
# shellcheck disable=SC2034
# shellcheck disable=SC2154
# shellcheck disable=SC2009
# shellcheck disable=SC2068
# shellcheck disable=SC2116
# shellcheck disable=SC2120
# shellcheck disable=SC2116
# shellcheck disable=SC2086
# shellcheck disable=SC1001
#
# nitronD API Manager.
#
# Copyright Identiter: GPL-3.0
# Copyright (C) 2022~2023 UsiFX <xprjkts@gmail.com>
#

export NITRON_HEADER_VERSION='3.0.0'

# cmdavail <command> ## if available > return 0 & log; else return 1 & log
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

# printn <argument> text
printn() {
	[[ "$1" == "-n" ]] && printf "[${BLUE}*${STOCK}] $2\n"

	[[ "$1" == "-e" ]] && {
		printf "[${RED}×${STOCK}] $2\n"
		exit 1
	}

	[[ "$1" == "-w" ]] && printf "[${YELLOW}!${STOCK}] $2\n"

	[[ "$1" == "-i" ]] && printf "[${CYAN}i${STOCK}] $2\n"

	[[ "$1" == "-l" ]] && echo "[$(date +%I:%M:%S)] nitrond: $PR_PREFIX[0]: $2" >>"$NITRON_LOG_DIR"/nitron.log

	[[ "$1" == "-lf" ]] && echo "[$(date +%I:%M:%S)] nitrond: $PR_PREFIX[1]: $2" >>"$NITRON_LOG_DIR"/nitron.log

	[[ "$1" == "-ll" ]] && echo "[$(date +%I:%M:%S)] nitrond: $2" >>"$NITRON_RELAX_DIR"/nitron.log

}

# writen <file> <value>
writen() {
        [[ ! -f "$1" ]] && echo "[$(date +%I:%M:%S)] $1: not found, skipping..." >> "$NITRON_LOG_DIR"/nitron.log

        # Make file writable
        chmod +w "$1" 2>/dev/null

        # Write new value, bail out if it fail
        (echo $2 >> $1) 2>/dev/null  && echo "[$(date +%I:%M:%S)] $1: changed node[$2]" >> "$NITRON_LOG_DIR"/nitron.log || echo "[$(date +%I:%M:%S)] $1: failed to change node" >> "$NITRON_LOG_DIR"/nitron.log
}


trapper() { printn -e "shutdown signal recieved, closing..."; }

prompt_right() { echo -e "\r[${GREEN}$(echo "*")${STOCK}] ${@}";}

prompt_left() {
	case $* in
		"-t") echo -e "[  ${GREEN}$(echo " OK ")${STOCK}  ]" ;;
		"-f") echo -e "[  ${RED}$(echo "FAIL")${STOCK}  ]"
		      exit 1
		;;
		*) echo -e "[  ${PURPLE}$(echo "DONE")${STOCK}  ]" ;;
	esac
}

printcrnr() { compensate=13; printf "\r%*s\r%s\n" "$((COLUMNS+compensate))" "$1" "$(prompt_right "$2")" ; }

# usage: cmd & spin "text"
spin() {
	PID=$!
	while [ -d /proc/$PID ]; do
		for anim in / - \\ \|; do
			printf "\r[$anim] ${@}"
			sleep 0.1
		done
		[[ ! -d /proc/$PID ]] && printcrnr "$(prompt_left)" "${@}"
	done
}

## Variables
vars() {
# Resource variables
[[ -e "/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor" ]] && cpu_gov=$(cat "/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor") || printn -w "cannot grab CPU Governor, are we running on Container/CHRoot?"

# Number of CPU cores
nr_cores=$(awk -F "-" '{print $2}' "/sys/devices/system/cpu/present")
nr_cores=$((nr_cores + 1))

# CPU Usage
cputotalusage=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage ""}' | cut -f1 -d\.$cputotalusage)

# Max CPU clock
cpu_max_freq=$(cat /sys/devices/system/cpu/cpu$((nr_cores - 1 ))/cpufreq/cpuinfo_max_freq)
cpu_max_freq1=$(cat /sys/devices/system/cpu/cpu$((nr_cores - 1 ))/cpufreq/scaling_max_freq)
[[ "$cpu_max_freq1" -gt "$cpu_max_freq" ]] && cpu_max_freq="$cpu_max_freq1"

# Min CPU clock
cpu_min_freq=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq)
cpu_min_freq1=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq)
[[ "$cpu_min_freq1" -lt "$cpu_min_freq" ]] && cpu_min_freq="$cpu_min_freq1"

# HZ → MHz
cpu_min_clk_mhz=$((cpu_min_freq / 1000))
cpu_max_clk_mhz=$((cpu_max_freq / 1000))

# Battery info
# Current battery capacity available
[[ -e "/sys/class/power_supply/battery/capacity" ]] && batt_pctg=$(cat /sys/class/power_supply/battery/capacity) || cmdavail dumpsys && batt_pctg=$(dumpsys battery 2>/dev/null | awk '/level/{print $2}')

if [[ "$batt_pctg" != "" ]]; then
	# Battery health
	[[ -e "/sys/class/power_supply/battery/health" ]] && batt_hth=$(cat /sys/class/power_supply/battery/health) || cmdavail dumpsys && batt_hth=$(dumpsys battery | awk '/health/{print $2}')
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
	[[ -e "/sys/class/power_supply/battery/status" ]] && batt_sts=$(cat /sys/class/power_supply/battery/status) || cmdavail dumpsys && batt_sts=$(dumpsys battery | awk '/status/{print $2}')
	case "$batt_sts" in
		1) batt_sts="Unknown" ;;
		2) batt_sts="Charging" ;;
		3) batt_sts="Discharging" ;;
		4) batt_sts="Not charging" ;;
		5) batt_sts="Full" ;;
	esac


	# Battery total capacity
	[[ -e "/sys/class/power_supply/battery/charge_full_design" ]] && batt_cpct=$(cat /sys/class/power_supply/battery/charge_full_design) || cmdavail dumpsys && batt_cpct=$(dumpsys batterystats | awk '/Capacity:/{print $2}' | cut -d "," -f 1)

	# MA → MAh
	[[ "$batt_cpct" -ge "1000000" ]] && batt_cpct=$((batt_cpct / 1000))
else
	if cmdavail upower; then
		batt_pctg=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep "percentage:"| awk '{print $2}' | cut -f1 -d\%)
		batt_cpct=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep "capacity:"| awk '{print $2}' | cut -f1 -d\%)
		batt_sts=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep "state:"| awk '{print $2}')
		batt_hth=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep "warning-level:"| awk '{print $2}')
	fi
fi
}

## End of variables

# infogrbn <directory> <value>
infogrbn() { grep "$2" "$1" | awk '{ print $2 }';}

# infogrblongn <directory> <value>
infogrblongn() { grep "$2" "$1" | awk -F ": " '{ print $2,$3,$4,$5,$6,$7,$8,$9 }' | head -n1 && return $?;}

# setmoden <nitron mode>
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
		"Automatic")
			setmoden "Automatic"
		;;
		"Automatic green")
			setmoden "Automatic green"

		;;
		"Automatic yellow")
			setmoden "Automatic yellow"
		;;
		"Automatic red")
			setmoden "Automatic red"
		;;
	esac
}

oschk()
{
	PR_PREFIX="oschk"
	OSCHK=$(uname -o)

	case "$OSCHK" in
		"GNU/Linux")
			PLATFORM="GNU/Linux"
			if [[ -n "$WSL_DISTRO_NAME" ]]; then
					PLATFORM="GNU/Linux (WSL)"
					printn -e "Seems we are running under WSL environment, it's unusable at all with this tool."
			fi
			printn -l "OS: $PLATFORM"
			return 0
		;;
		"Linux")
			if grep -q "androidboot" /proc/cmdline; then
				cmdavail resetprop && PLATFORM="Android"
			else
				PLATFORM="Linux"
			fi
			printn -l "OS: $PLATFORM"
			return 0
		;;
		*)
			if grep -q "androidboot" /proc/cmdline; then
				PLATFORM="Android"
			else
				cmdavail resetprop && PLATFORM="Android" || { 
					PLATFORM="Unknown"
					printn -lf "OS: $PLATFORM"
					printn -e "Unknown Operating System, cannot start."
				}
			fi
		;;
	esac
}

apin() {
	# Installation type check
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

	# Android™ Device information grabber
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

	# Common Information
	resrchk()
	{
		echo "PID: $$"
		echo "OS: $PLATFORM"
		echo "Kernel: $(uname -sr)"
		echo "SU Provider: $(su --version)"
		echo "Memory: $(( $(infogrbn "/proc/meminfo" "MemTotal") / 1024 / 1024 + 1 ))GB"
		[[ "$(infogrblongn "/proc/cpuinfo" "Hardware")" ]] && echo "Hardware: $(infogrblongn "/proc/cpuinfo" "Hardware")" || echo "Hardware: $(infogrblongn "/proc/cpuinfo" "model name")"
		echo "Kernel Archticture: $(uname -m)"
		echo "CPU Governor: $cpu_gov"
		echo "CPU Cores: $nr_cores"
		echo "CPU Freq: MIN=$cpu_min_clk_mhz, MAX=$cpu_max_clk_mhz MHz"
		echo "CPU Usage: $cputotalusage%"
		[[ "$batt_pctg" != "" ]] && [[ "$batt_hth" != "unknown" ]] && {
			echo "Battery Percentage: $batt_pctg%"
			echo "Battery Health: $batt_hth"
			echo "Battery Status: $batt_sts"
			echo "Battery Capacity: $batt_cpct MAh"
		}
		[[ "$PLATFORM" == "Android" ]] && androiddevinfo
		echo "Nitron Daemon Version: $(apin -dv)"
		echo "Nitron Header Version: $(apin -hv)"
		echo "Nitron Installation type: $INSTALLATION"
		echo "Nitron Current mode: $(apin -mc)"
	}

	# API Help Menu
	__api_help()
	{
		echo "
Usage: apin [OPTION(s)] (e.g. apin -rc)

Options:
  -rc, --resource-check		~ prints hardware resources information
  -dv, --daemon-version         ~ prints daemon version
  -hv, --header-version         ~ prints header version
  -mc, --mode-check		~ prints current mode
  -as, --android-status		~ updates magisk module description overlay
  -cl, --clear-log		~ clean daemon log only
  -ad, --auto-daemon		~ start up background process for automatic
  -c, --clean			~ cleans entirely all created files by daemon
  -h, --help			~ prints this help menu
"
	}

	# Start Installation type function
	instype

	case $* in
		"-rc" | "--resource-check")
			vars
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
						"Automatic"*)
							sed -i '/description=/s/.*/description=[ ⚡ Automatic mode applied ], Extensive Optmized Kernel Tweaker Daemon By: TITΛN × Noobies./' "/data/adb/modules/nitrond.magisk/module.prop"
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
		"-cl" | "--clear-log")
			rm -rf "$NITRON_LOG_DIR"/nitron.log
		;;
		"-ad" | "--auto-daemon")
			export SOURCE="api-auto"
			autoalg() {
				vars # update variables each execution
				if (( cputotalusage >= "75" )); then
					if [[ "$(apin -mc | awk '{print $2}')" != "yellow" ]]; then
						printn -ll "cpu usage is 75%+"
						magicn -y 2>&1 >/dev/null 2>&1
						printn -ll "heavy process(es) detected, applied balance mode."
					fi
				elif (( cputotalusage <= "75" )); then
					if [[ "$(apin -mc | awk '{print $2}')" != "green" ]]; then
						printn -ll "cpu usage is 75%-"
						magicn -g 2>&1 >/dev/null 2>&1
						printn -ll "relaxing environment, applied battery mode."
					fi
				fi
			}
			autoalg
			sleep 15
		;;
		"-h" | "--help")
			__api_help
		;;
		*)
			__api_help
			return 1
		;;
	esac
}

console_legacy() {
	PR_PREFIX="console_legacy"
	__head_motd() {
		echo -e ""
		echo -e "${CYAN}    _   ___ __________  ____  _   __${STOCK}"
		echo -e "${BLUE}   / | / (_)_  __/ __ \/ __ \/ | / /${STOCK}"
		echo -e "${YELLOW}  /  |/ / / / / / /_/ / / / /  |/ / ${STOCK}"
		echo -e "${YELLOW} / /|  / / / / / _, _/ /_/ / /|  /  ${STOCK}"
		echo -e "${CYAN}/_/ |_/_/ /_/ /_/ |_|\____/_/ |_/   ${STOCK}"
		echo -e ""
		echo -e "${WHITE}Welcome to nitron CLI menu!"
		echo -e ""
		echo -e "${WHITE}--${STOCK} Current Profile  : ${YELLOW}$(apin -mc)${STOCK}"
		echo -e "${WHITE}--${STOCK} Daemon Version   : ${BLUE}$(apin -dv)${STOCK}"
		echo -e "${WHITE}--${STOCK} API Version      : ${GREEN}$(apin -hv)${STOCK}"
		echo -e ""
		echo -e "Report issues at ${WHITE}https://github.com/UsiFX/OpenNitroN/issues ${STOCK}"
	}

	__section_center() {
		printf '%.0s-' $(seq 1 ${COLUMNS})
		echo -e "[*] $1"
		printf '%.0s-' $(seq 1 ${COLUMNS})
	}

	__profile_options() {
		echo -e "\n"
		echo -e "${GREEN}[1] Battery: Focused on saving battery as much as possible"
		echo -e ""
		echo -e "${YELLOW}[2] Balance: Focused on leaving the system in balance"
		echo -e ""
		echo -e "${RED}[3] Gaming: Focused on maximize overall system performance ${STOCK}"
		echo -e ""
	}

	__others_options() {
		echo -e "\n"
		echo -e "${YELLOW}[4] Device Information ${CYAN}(grabs entire and recognised system info)"
		echo -e ""
		if [[ "$PLATFORM" == "Android" ]]; then
			echo -e "${YELLOW}[5] optimize app packages ${CYAN}(repackage and/or recompile apps)"
			echo -e ""
		fi
		echo -e "${WHITE}[0] Exit${STOCK}"
		echo -e ""
	}

	__pcs_mgr() {
		echo -e ""
		printn -n "press enter to continue or 0 to exit: \c"
		read -r SUBOPT
		if [ "$SUBOPT" == "0" ]; then
			echo -e "${BLUE}[*] Thanks for using the cli menu, see you later!${STOCK}"
			exit 0
		else
			main
		fi

	}

	main()
	{
		printn -lt "console triggered"
		clear
		__head_motd
		echo -e "${CYAN}"
		__section_center "Profile selector"
		__profile_options
		echo -e "${CYAN}"
		__section_center "Miscellaneous"
		__others_options
		echo -e "${WHITE}[?] Type desired option: \c${STOCK}"
		read -r OPTS
		case "$OPTS" in
			0) echo -e "${BLUE}[*] Thanks for using the cli menu, see you later!${STOCK}"; exit 0 ;;
			1)
				clear
				__head_motd
				echo -e "${GREEN}"
				__section_center "Applying Battery mode..."
				echo -e "${STOCK}\n"
				magicn -g
				echo "[*] Done!"
				sleep 2
				__pcs_mgr
			;;
			2)
				clear
				__head_motd
				echo -e "${YELLOW}"
				__section_center "Applying Balance mode..."
				echo -e "${STOCK}\n"
				magicn -y
				echo "[*] Done!"
				sleep 2
				__pcs_mgr
			;;
			3)
				clear
				__head_motd
				echo -e "${RED}"
				__section_center "Applying Gaming mode..."
				echo -e "${STOCK}\n"
				magicn -r
				echo "[*] Done!"
				sleep 2
				__pcs_mgr
			;;
			4)
				clear
				__head_motd
				echo -e "${CYAN}"
				__section_center "Device Information"
				echo -e "${STOCK}\n"
				apin -rc
				__pcs_mgr
			;;
			5)
				if [[ "$PLATFORM" == "Android" ]]; then
					clear
					__head_motd
					echo -e "${CYAN}"
					__section_center "Repackaging apps... (please wait)"
					echo -e "${STOCK}\n"
					(pm compile -a -f --compile-layouts | grep -e "Failure" >>"$NITRON_LOG_DIR"/nitron.log)& spin "compiling layout resources..."
					cmd package bg-dexopt-job & spin "running background optimizer... "
					echo "[*] Done!"
					sleep 2
					__pcs_mgr
				else
					printn -e "illegal instruction, bad platform"
				fi
			;;
			*) echo "${RED}[!] Bad option, refreshing...${STOCK}"; sleep 2; main ;;
		esac
	}
	main
}
