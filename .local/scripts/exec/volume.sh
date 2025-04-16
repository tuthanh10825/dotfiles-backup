#!/usr/bin/env bash

## Author  : Aditya Shakya (adi1090x)
## Github  : @adi1090x
#
## Applets : Volume

# Volume Info
amixer get Master | grep '\[on\]' &>/dev/null
if [[ "$?" == 0 ]]; then
	stext='Unmute'
	sicon='󰝟'
else
	stext='Mute'
	sicon='󰕾'
fi

# Microphone Info
amixer get Capture | grep '\[on\]' &>/dev/null
if [[ "$?" == 0 ]]; then
    [ -n "$active" ] && active+=",3" || active="-a 3"
	mtext='Unmute'
	micon=' '
else
    [ -n "$urgent" ] && urgent+=",3" || urgent="-u 3"
	mtext='Mute'
	micon=''
fi

# Theme Elements

list_col='1'
list_row='6'
win_width='120px'

# Options

option_1='󰝝'
option_2="$sicon"
option_3='󰝞'
option_4="$micon"
option_5='󰓃'
option_6=''


# Rofi CMD
rofi_cmd() {
	rofi -theme-str "window {width: $win_width;}" \
		-theme-str "listview {columns: $list_col; lines: $list_row;}" \
		-dmenu \
		-theme "~/.config/rofi/applets.rasi"
    }

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5\n$option_6" | rofi_cmd
}

# Execute Command
run_cmd() {
	if [[ "$1" == '--opt1' ]]; then
        ~/.local/scripts/exec/volumecontrol.sh -o i 20
	elif [[ "$1" == '--opt2' ]]; then
        ~/.local/scripts/exec/volumecontrol.sh -o m
	elif [[ "$1" == '--opt3' ]]; then
        ~/.local/scripts/exec/volumecontrol.sh -o d 20
	elif [[ "$1" == '--opt4' ]]; then
        ~/.local/scripts/exec/volumecontrol.sh -i m 
	elif [[ "$1" == '--opt5' ]]; then
        ~/.local/scripts/exec/volumecontrol.sh -s
	elif [[ "$1" == '--opt6' ]]; then
		pwvucontrol
	fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
    $option_1)
		run_cmd --opt1
        ;;
    $option_2)
		run_cmd --opt2
        ;;
    $option_3)
		run_cmd --opt3
        ;;
    $option_4)
		run_cmd --opt4
        ;;
    $option_5)
		run_cmd --opt5
        ;;
    $option_6)
		run_cmd --opt6
        ;;
esac

