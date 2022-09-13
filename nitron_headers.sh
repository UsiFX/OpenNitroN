#
# Copyright Identiter: GPL-3.0
# Copyright (C) 2022~2023 UsiFX <xprjkts@gmail.com>
#

console_dialog() {
	PR_PREFIX="console_dialog():"
	HEIGHT=16
	WIDTH=40
	CHOICE_HEIGHT=30
	BACKTITLE="The Open NitroN Kernel tweaking Project"
	TITLE="nitron v0.7"
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
	clear
	print_banner
	PR_PREFIX="console_legacy():"
	COLUMNS=45
	OPTIONS=("Switch Mode" "Show device state" "Update" "Show help menu" "Exit")
	PS3="Choose one of the following Main options: "
	select CHOICE in "${OPTIONS[@]}"; do
		num=$REPLY
		case $num in
			1)
				while :; do
					COLUMNS=45
					MODE_OPTIONS=("Gaming" "Balance" "Battery" "Back to main menu" "Exit")
					PS3="Choose one of the following Mode options: "
					select MODE_CHOICE in "${MODE_OPTIONS[@]}"; do
						mode_num=$REPLY
						case $mode_num in
							1)
								magicn -r
								printn -i "Process complete!"
								break
								;;
							2)
								magicn -y
								printn -i "Process complete!"
								break
								;;
							3)
								magicn -g
								printn -i "Process complete!"
								break
								;;
							4)
								break 2
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
				printn -e "wip"
				break 2
				;;
			3)
				updaten
				break 2
				;;
			4)
				__nitron_help
				;;
			5)
				break 2
				;;
			*)
				printn -e "[$num] unknown option"
				sleep 2
				break
				;;
		esac
	done
}
