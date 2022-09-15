#!/usr/bin/env bash
#
# Copyright Identiter: GPL-3.0
# Copyright (C) 2022~2023 UsiFX <xprjkts@gmail.com>
#

set -x

# Ensures proper use
if ! [[ $(uname -s) =~ ^(Linux|GNU*)$ ]]; then
  echo "ERROR: run NitronD Installer on Linux" >&2
  exit 1
elif ! [[ -t 0 ]]; then
  echo "ERROR: run NitronD Installer from a terminal" >&2
  exit 1
elif [[ $(whoami) == root ]]; then
  echo "ERROR: do not run NitronD Installer as root" >&2
  exit 1
elif [[ ${BASH_SOURCE[0]} != "$0" ]]; then
  echo "ERROR: NitronD Installer cannot be sourced" >&2
  return 1
fi

# Required variables
repo="https://github.com/UsiFX/OpenNitroN.git"
target="${HOME}/OpenNitroN-temp"
bin="${PREFIX/\/usr}/usr/bin"

required_deps=(git)

[[ ! "$(which ${required_deps[@]} 2>/dev/null)" ]] && {
        echo "please download following packages, (${required_deps[@]})"
	exit 1
}

case $1 in
	install)
		echo "downloading nitrond..."
		git clone "$repo" "$target"
		echo "installing nitrond..."
		chmod 755 "${target}"
		chmod +x "${target}/nitrond"
		sudo cp -f "${target}/nitrond" "${bin}/nitrond"
		sudo chmod 755 "${bin}/nitrond"
	;;
	*)	echo "test." ;;
esac
