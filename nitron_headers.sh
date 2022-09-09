#
# Copyright Identiter: GPL-3.0
# Copyright (C) 2022~2023 UsiFX <xprjkts@gmail.com>
#

console_dialog()
{
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