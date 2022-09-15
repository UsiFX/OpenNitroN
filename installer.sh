#!/usr/bin/env bash
#
# Copyright Identiter: GPL-3.0
# Copyright (C) 2022~2023 UsiFX <xprjkts@gmail.com>
#

set -x

# Ensures proper use
if ! [[ $(uname -s) == "Linux" ]]; then
  echo "ERROR: run NitronD Installer on Linux" >&2
  if [[ $(whoami) == root ]]; then
    echo "ERROR: do not run NitronD Installer as root" >&2
  fi
  exit 1
fi

# Required variables
repo="https://github.com/UsiFX/OpenNitroN.git"
target="${HOME}/OpenNitroN-temp"
bin="${PREFIX/\/usr}/usr/bin"
etc="${PREFIX/\/usr}/usr/etc"
required_deps=(git)

if [[ "$(which getprop)" ]] && [[ "$(id -u)" -ne "0" ]]; then
	echo "being used in Android SU session..."
else
	[[ ! "$(which ${required_deps[@]} 2>/dev/null)" ]] && {
	        echo "please download following packages, (${required_deps[@]})"
		exit 1
	}
fi

case $1 in
	install)
		[[ "$(grep -nr "androidboot" /proc/cmdline)" ]] && {
			[[ "$(id -u)" -ne "0" ]] && {
				echo "downloading nitrond files..."
				curl -o "/system/bin/nitrond" "https://raw.githubusercontent.com/UsiFX/OpenNitroN/main/nitrond"
				curl -o "/system/etc/nitron_headers.sh" "https://raw.githubusercontent.com/UsiFX/OpenNitroN/main/nitron_headers.sh"
				chmod +x "/system/bin/nitrond"
				chmod +x "/system/etc/nitron_headers.sh"
				chmod 755 "/system/bin/nitrond"
				chmod 755 "/system/etc/nitron_headers.sh"
			} || { echo "please run with SU."; exit 1 ;}
		} || {
			echo "downloading nitrond..."
			git clone "$repo" "$target"
			echo "installing nitrond..."
			chmod 755 "${target}"
			chmod +x "${target}/nitrond"
			chmod +x "${target}/nitron_headers.sh"
			sudo cp -f "${target}/nitrond" "${bin}/nitrond"
			sudo cp -f "${target}/nitron_headers.sh" "${etc}/nitron_headers.sh"
			sudo chmod 755 "${bin}/nitrond"
			sudo chmod 755 "${etc}/nitron_headers.sh"
		}
	;;
	*)	echo "test." ;;
esac
