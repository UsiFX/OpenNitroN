#!/usr/bin/env bash
#
# shellcheck disable=SC2145
# shellcheck disable=SC2181
# shellcheck disable=SC2015
# shellcheck disable=SC2157
# shellcheck disable=SC2199
#
# Simple nitronD simpleMMT Builder
#
# Copyright Identiter: GPL-3.0
# Copyright (C) 2022~2023 UsiFX <xprjkts@gmail.com>
#

TIMESTAMP=$(date +%Y%m%d)
VERSION='1.1.3-staging'
OBJECTS=("nitrond" "nitronapi.sh")
MMT_OBJECTS=("magisk/META-INF/com/google/android/update-binary" "magisk/setup.sh" "magisk/common/functions.sh" "magisk/uninstall.sh" "magisk/system.prop")
PLACEHOLDERS=("debian/usr/placeholder" "debian/usr/bin/placeholder" "debian/usr/include/placeholder")
FILENAME="NitronX-$VERSION-$RANDOM-$TIMESTAMP"

if [[ -z "$object_directory" ]]; then
	export OUT=$(pwd)/out
	echo "Using $OUT as source of NitroN"
else
	export OUT="$object_directory"
	echo "Using $OUT as source of NitroN"
fi

[[ -d "$OUT" ]] || mkdir "$OUT"

compile()
{
	[[ -d "$OUT/target" ]] || mkdir "$OUT/target"
	[[ -d "$OUT/product" ]] || mkdir "$OUT/product"
	cp -afr "magisk/." "$OUT/product"
	cp -af "${OBJECTS[@]}" "$OUT/product"
	cd "$OUT/product" || exit
	zip -0 -r9 -ll "$OUT/target/$FILENAME.zip" . -x "$FILENAME" >/dev/null && echo " ZIP  $OUT/target/$FILENAME.zip"
	cd ../..
	return 0
}


debcompile()
{
	[[ -d "$OUT/target" ]] || mkdir -p "$OUT/target"
	[[ -d "$OUT/debian" ]] || mkdir -p "$OUT/debian/product"
	rm -f "${PLACEHOLDERS[@]}" && echo " RM   ${PLACEHOLDERS[@]}"
	cp -afr "debian/." "$OUT/debian/product"
	cp -af "${OBJECTS[@]}" "$OUT/debian/product"
	cd "$OUT/debian/product" || exit
	mv -f "$OUT/debian/product/nitrond" "$OUT/debian/product/usr/bin"
	mv -f "$OUT/debian/product/nitronapi.sh" "$OUT/debian/product/usr/include"
	dpkg-deb --build --root-owner-group "$OUT/debian/product" "$OUT/target/$FILENAME.deb" && echo " DPKG  $OUT/target/$FILENAME.deb"
	cd ../../..
	return 0
}

aurcompile()
{
	[[ -d "$OUT/target" ]] || mkdir -p "$OUT/target"
	[[ -d "$OUT/archlinux" ]] || mkdir -p "$OUT/archlinux/product"
	cp -afr "archlinux/." "$OUT/archlinux/product"
	cp -af "${OBJECTS[@]}" "$OUT/archlinux/product"
	cd "$OUT/archlinux/product" || exit
	makepkg --config ../../../makepkg.conf -f "$OUT/archlinux/product" && 	echo " MKPKG  $OUT/target/$FILENAME.pkg.tar.xz"
	cd ../../..
	return 0
}

help()
{
echo "usage: smmt_builder.sh [OPTIONS] e.g: smmt_builder.sh --shellcheck

options:
 [FOR ANDROID ONLY]
  --compile       ~ execute with dirty compilation
  --shellcheck    ~ execute with compilation check
  --sign          ~ sign with AOSP keys
 [FOR DPKG ONLY]
  --dpkg-compile  ~ execute with dirty compilation
 [FOR AUR ONLY]
  --aur-compile   ~ execute with dirty compilation

others:
  --clean         ~ clean the out directory
"
}

for opts in "${@}"
do
	case "${opts}" in
		"--shellcheck")
			[[ ${opts[@]} == *"--compile"* ]] && shellcheck "${MMT_OBJECTS[@]}"; echo " SHCHK  ${MMT_OBJECTS[@]}"
			shellcheck "${OBJECTS[@]}"
			echo " SHCHK  ${OBJECTS[@]}"
			[[ $? == "0" ]] || echo "failed"
		;;
		"--compile")
			compile
		;;
		"--sign")
			[[ "$OUT/target/$FILENAME.zip" ]] && {
				java -jar "$(pwd)/etc/zipsigner/zipsigner-3.0.jar" "$OUT/target/$FILENAME.zip" "$OUT/target/$FILENAME-signed-OFFICIAL.zip"
				echo " SIGN  $OUT/target/$FILENAME-signed-OFFICIAL.zip"
				exit $?
			} || { echo "There is no compiled ZIP file to Sign. Error"; exit 1 ;}
		;;
		"--clean")
			rm -rf "$OUT"
			echo " CLEAN  $OUT"
			mkdir "$OUT"
		;;
		"--dpkg-compile")
			debcompile
		;;
		"--aur-compile")
			aurcompile
		;;
		*)
			help
		;;
	esac
done

[[ $# -lt "1" ]] && help
