#!/system/bin/sh

# External Tools 
chmod -R 0755 "$MODPATH/addon/Volume-Key-Selector/tools"
export PATH="$MODPATH/addon/Volume-Key-Selector/tools/$ARCH32:$PATH"

keytest() {
  ui_print "[*] Vol Key Test"
  ui_print "[*] Press a Vol Key: "
  if $(timeout 9 /system/bin/getevent -lc 1 2>&1 | /system/bin/grep "VOLUME" | /system/bin/grep "DOWN" > $TMPDIR/events); then
    return 0
  else
    ui_print "[*] Try again:"
    timeout 9 keycheck
    local SEL=$?
    [[ "$SEL" == "143" ]] && abort "[!] Vol key not detected!" || return 1
  fi
}

chooseport_legacy() {
  # Keycheck binary by someone755 @Github, idea for code below by Zappo @xda-developers
  # Calling it first time detects previous input. Calling it second time will do what we want
	if [ $1 == * ]; then
		set delay=$1
	else
		set delay=3
	fi
	error=false
	while true; do
		timeout $delay $MODPATH/common/addon/Volume-Key-Selector/tools/arm/keycheck
		local sel=$?
		if [ $sel == 42 ]; then
			return 0
		elif [ $sel == 41 ]; then
			return 1
			error=true
		elif $error; then
			abort "Volume key not detected!"
		else
			echo "Volume key not detected. Try again"
		fi
	done
}

chooseport() {
  # Original idea by chainfire @xda-developers, improved on by ianmacd @xda-developers
  # Note from chainfire @xda-developers: getevent behaves weird when piped, and busybox grep likes that even less than toolbox/toybox grep
	if [ $1 == * ]; then
		set delay=$1
	else
		delay=3
	fi
	error=false
  	while true; do
    	count=0
    		while true; do
			timeout $delay /system/bin/getevent -lqc 1 2>&1 > $TMPDIR/events
			sleep 0.5
			count=$((count + 1))
			if (`grep -q 'KEY_VOLUMEUP *DOWN' $TMPDIR/events`); then
				return 0
			elif (`grep -q 'KEY_VOLUMEDOWN *DOWN' $TMPDIR/events`); then
				return 1
			fi
    			[ $count -gt 6 ] && break
		done
		if $error; then
			echo "Volume key not detected. Trying keycheck method"
			export chooseport=chooseport_legacy VKSEL=chooseport_legacy
			chooseport_legacy $delay
			return $?
		else
      			error=true
			echo "Volume key not detected. Try again"
		fi
	done
}

# Have user option to skip vol keys
OIFS=$IFS; IFS=\|; MID=false; NEW=false
case $(echo $(basename $ZIPFILE) | tr '[:upper:]' '[:lower:]') in
  *novk*) ui_print "[*] Skipping Vol Keys...";;
  *) if keytest; then
       VKSEL=chooseport
     else
       VKSEL=chooseport_legacy
       ui_print "[!] Legacy device detected, using old keycheck method."
       ui_print "[*] Vol Key Programming [*]"
       ui_print "[*] Press Vol Up Again:"
       $VKSEL "UP"
       ui_print "[*] Press Vol Down"
       $VKSEL "DOWN"
     fi;;
esac
IFS=$OIFS
