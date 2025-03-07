#!/usr/bin/env sh

# Prevent multiple instances of the script
if [ "$(pgrep -fx "$(realpath "$0")" | wc -l)" -gt 1 ]; then
    echo "An instance of the script is already running..."
    exit 1
fi

scrDir=$(dirname "$(realpath "$0")")

# Check if SwayOSD is installed and running
use_swayosd=false
if command -v swayosd-client >/dev/null 2>&1 && pgrep -x swayosd-server >/dev/null; then
    use_swayosd=true
fi

print_error() {
cat << EOF
Usage: $(basename "$0") <action> [step] [mode]
Valid actions:
    i -- Increase brightness [+5%]
    d -- Decrease brightness [-5%]

Examples:
    $(basename "$0") i 10    # Increase brightness by 10%
    $(basename "$0") d       # Decrease brightness by default step (5%)
    $(basename "$0") i 5 -q  # Increase brightness by 5% quietly
EOF
}

notify=true  # Default: notifications enabled
action=""    # Will store 'increase' or 'decrease'
step=5       # Default step value

# Parse arguments
for arg in "$@"; do
    case $arg in
        i|-i)   [ -n "$action" ] && { echo "Only one action is allowed"; print_error; exit 1; }
                action="increase" ;;
        d|-d)   [ -n "$action" ] && { echo "Only one action is allowed"; print_error; exit 1; }
                action="decrease" ;;
        q|-q)   notify=false ;;
        [0-9]*) step=$arg ;; # Custom step value
        *)      print_error; exit 1 ;;
    esac
done

if [ -z "$action" ]; then
    echo "Error: No action provided"
    print_error
    exit 1
fi

send_notification() {
    brightness=$(brightnessctl info | grep -oP "(?<=\()\d+(?=%)")
    brightinfo=$(brightnessctl info | awk -F "'" '/Device/ {print $2}')
    angle=$(( (brightness + 2) / 5 * 5 ))
    ico="$HOME/.config/dunst/icons/vol/vol-${angle}.svg"
    [ ! -f "$ico" ] && ico="$HOME/.config/dunst/icons/vol/default.svg"
    bar=$(printf '%.0s.' $(seq 1 $((brightness / 15))))
    notify-send -a "t2" -r 91190 -t 800 -i "$ico" "${brightness}${bar}" "${brightinfo}"
}

get_brightness() {
    brightnessctl -m | grep -o '[0-9]\+%' | head -c-2
}

case $action in
increase)
    [ $(get_brightness) -lt 10 ] && step=1
    $use_swayosd && swayosd-client --brightness raise "$step" && exit 0
    brightnessctl set +${step}%
    [ "$notify" = true ] && send_notification ;;

decrease)
    [ $(get_brightness) -le 10 ] && step=1
    if [ $(get_brightness) -le 1 ]; then
        brightnessctl set ${step}%
        $use_swayosd && exit 0
    else
        $use_swayosd && swayosd-client --brightness lower "$step" && exit 0
        brightnessctl set ${step}%-
    fi
    [ "$notify" = true ] && send_notification ;;
esac
