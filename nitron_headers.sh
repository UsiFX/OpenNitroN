#
# shellcheck disable=SC2148
# shellcheck disable=SC2034
#
# nitronD Headers.
#
# Copyright Identiter: GPL-3.0
# Copyright (C) 2022~2023 UsiFX <xprjkts@gmail.com>
#

export NITRON_HEADER_VERSION='1.0.0'

cmdavail() {
	PR_PREFIX="cmdavail"
	if command -v "$1" >/dev/null; then
		return 0
		printn -l "$1: available"
	else
		return 1
		printn -l "$1: unavailable"
	fi
}

# infogrbn <directory> <value>
infogrbn() { cat "$1" | grep "$2" | awk '{ print $2 }';}

# infogrblongn <directory> <value>
infogrblongn() { cat "$1" | grep "$2" | awk '{ print $3,$4,$5,$6 }';}

setmoden() { echo "$1" >> "$NITRON_LOG_DIR"/nitron.mode.lock ;}

modelockn()
{
	"$NITRON_LOG_DIR"/nitron.mode.lock || touch "$NITRON_LOG_DIR"/nitron.mode.lock
	MODES=$(cat "$NITRON_LOG_DIR"/nitron.mode.lock)
	NITRON_MODE="$MODES"
	case "$MODES" in
		"battery")
			setmoden "battery"
		;;
		"balanced")
			setmoden "balanced"
		;;
		"red")
			setmoden "red"
		;;
		*)
			setmoden "UnInitialised"
		;;
	esac
}

apin() {
	resrchk()
	{
		echo "PID: $$"
		echo "OS: $PLATFORM"
		echo "Kernel: $(uname -sr)"
		echo "Memory: $(( $(infogrbn "/proc/meminfo" "MemTotal") / 1024 / 1024))gb"
		echo "Hardware: $(infogrblongn "/proc/cpuinfo" "Hardware")"
		echo "Machine: $(uname -m)"
	}

	__api_help()
	{
		echo "
Usage: apin [OPTION(s)] (e.g. apin -rc)

Options:
  -rc, --resource-check		~ prints hardware resources information
  -h, --help			~ prints this help menu
"
	}

	case $* in
		"-rc" | "--resource-check")
			resrchk
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
			printn -l "OS: $PLATFORM"
			printn -e "Unknown Operating System, cannot start."
		;;
	esac
}

