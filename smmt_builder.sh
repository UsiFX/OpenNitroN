#!/usr/bin/env bash
#
# shellcheck disable=SC2181
# shellcheck disable=SC2145
#
# Simple nitronD simpleMMT Builder
#
# Copyright Identiter: GPL-3.0
# Copyright (C) 2022~2023 UsiFX <xprjkts@gmail.com>
#
#set -x
TIMESTAMP=$(date +%Y%m%d)
VERSION='0.7.4'
OBJECTS=("nitrond" "nitron_headers.sh")
MMT_OBJECTS=("magisk/META-INF/com/google/android/update-binary" "magisk/setup.sh" "magisk/common/functions.sh" "magisk/uninstall.sh")
FILENAME="NitronX-$VERSION-$TIMESTAMP"

if [[ -z "$object_directory" ]]; then
	OUT=$(pwd)/out
	echo "Using $OUT as source of NitroN"
else
	OUT="$object_directory"
	echo "Using $OUT as source of NitroN"
fi

[[ -d "$OUT" ]] || mkdir "$OUT"

compile()
{
	[[ -d "$OUT/target" ]] || mkdir "$OUT/target"
	[[ -d "$OUT/product" ]] || mkdir "$OUT/product"
	cp -af "${OBJECTS[@]}" "$OUT/product"
	cp -af "${MMT_OBJECTS[@]}" "$OUT/product"
	[[ -d "$OUT/product/META-INF/com/google/android" ]] || mkdir -p "$OUT/product/META-INF/com/google/android"
	mv -f "$OUT/product/update-binary" "$OUT/product/META-INF/com/google/android"
	zip -0 -r9 -ll "$OUT/target/$FILENAME.zip" "$OUT/product/." -x "$FILENAME" >/dev/null
	echo " ZIP  $FILENAME"
}

help()
{
echo "usage: smmt_builder.sh [OPTIONS] e.g: smmt_builder.sh --shellcheck

options:
  --compile    ~ execute with dirty compilation
  --shellcheck ~ execute with compilation check
  --clean      ~ clean the out directory"
}

for opts in "${@}"
do
	case "${opts}" in
		"--shellcheck")
			shellcheck "${MMT_OBJECTS[@]}"
			shellcheck "${OBJECTS[@]}"
			echo " SHCHK  ${MMT_OBJECTS[@]}"
			echo " SHCHK  ${OBJECTS[@]}"
			[[ $? == "0" ]] && compile || echo "failed"
		;;
		"--compile")
			compile
		;;
		"--clean")
			rm -rf "$OUT"
			echo " CLEAN  $OUT"
			mkdir "$OUT"
		;;
		*)
			help
		;;
	esac
done

[[ $# -lt "1" ]] && help
