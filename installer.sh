#!/usr/bin/env bash
#
# shellcheck disable=SC2145
#
# Simple nitronD installer
#
# Copyright Identiter: GPL-3.0
# Copyright (C) 2022~2023 UsiFX <xprjkts@gmail.com>
#

# Ensures proper use
if ! [[ $(uname -s) =~ ^(Linux|GNU*)$ ]]; then
	echo "ERROR: run nitronD Installer on Linux" >&2
	exit 1
elif ! [[ -t 0 ]]; then
	echo "ERROR: run nitronD Installer from a terminal" >&2
	exit 1
elif [[ $(whoami) == root ]]; then
	echo "ERROR: do not run nitronD Installer as root" >&2
	exit 1
elif [[ ${BASH_SOURCE[0]} != "$0" ]]; then
	echo "ERROR: nitronD Installer cannot be sourced" >&2
	return 1
fi

# Shell options
set -e
shopt -s progcomp
shopt -u dirspell progcomp_alias

# Required variables
REPO="https://github.com/UsiFX/OpenNitroN.git"
TARGET_REPO="${HOME}/OpenNitroN-temp"
BIN_DIR="${PREFIX/\/usr}/usr/bin"
INCLUDE_DIR="${PREFIX/\/usr}/usr/include"
REQUIRED_DEPS=(git dialog)

which "${REQUIRED_DEPS[@]}" >/dev/null || echo "please download following packages, '${REQUIRED_DEPS[@]}'"

case $1 in
	install)
		echo "downloading nitrond..."
		git clone --depth=1 "$REPO" "$TARGET_REPO"
		echo "installing nitrond..."
		chmod 755 "${TARGET_REPO}"
		chmod +x "${TARGET_REPO}/nitrond"
		chmod +x "${TARGET_REPO}/nitron_headers.sh"
		sudo cp -f "${TARGET_REPO}/nitrond" "${BIN_DIR}/nitrond"
		sudo cp -f "${TARGET_REPO}/nitron_headers.sh" "${INCLUDE_DIR}/nitron_headers.sh"
		sudo chmod 755 "${BIN_DIR}/nitrond"
		sudo chmod 755 "${INCLUDE_DIR}/nitron_headers.sh"
	;;
	uninstall)
		echo "uinstalling nitrond..."
		sudo rm -f "$(which nitrond)"
		sudo rm -f "$INCLUDE_DIR"/nitron_headers.sh
		echo "finished uninstallation!"
	;;
	*)	echo "usage: installer.sh [install] [uninstall]" ;;
esac
