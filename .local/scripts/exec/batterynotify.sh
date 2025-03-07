#!/usr/bin/env bash

undock=false
scrDir=$(dirname "$(realpath "$0")")

config_info() {
cat <<  EOF

      STATUS      THRESHOLD    INTERVAL
      Full        $battery_full_threshold          $notify Minutes
      Critical    $battery_critical_threshold           $timer Seconds then '$execute_critical'
      Low         $battery_low_threshold           $interval Percent    then '$execute_low'
      Unplug      $unplug_charger_threshold          $interval Percent   then '$execute_unplug'

      Charging: $execute_charging
      Discharging: $execute_discharging
EOF
}

is_laptop() { # Check if the system is a laptop
    if grep -q "Battery" /sys/class/power_supply/BAT*/type; then
        return 0  # It's a laptop
    else
    echo "No battery detected. If you think this is an error please post a report to the repo"
        exit 0  # It's not a laptop
    fi
}
is_laptop

fn_verbose () {
if $verbose; then
cat << VERBOSE
=============================================
        Battery Status: $battery_status
        Battery Percentage: $battery_percentage
=============================================
VERBOSE
fi
}

fn_notify () { # Send notification

    notify-send -a "Power" $1 -u $2 "$3" "$4" -p # Call the notify-send command with the provided arguments \$1 is the flags \$2 is the urgency \$3 is the title \$4 is the message
}
fn_percentage () {
                    if [[ "$battery_percentage" -ge "$unplug_charger_threshold" ]] &&  [[ "$battery_status" != "Discharging" ]] && [[ "$battery_status" != "Full" ]]  && (( (battery_percentage - last_notified_percentage) >= $interval )); then if $verbose; then echo "Prompt:UNPLUG: $battery_unplug_threshold $battery_status $battery_percentage" ; fi
                        fn_notify  "-t 5000 " "CRITICAL" "Battery Charged" "Battery is at $battery_percentage%. You can unplug the charger!"
                        last_notified_percentage=$battery_percentage
                    elif [[ "$battery_percentage" -le "$battery_critical_threshold" ]]; then
                        count=$(( timer > $mnt ? timer :  $mnt )) # reset count
                        while [ $count -gt 0 ] && [[ $battery_status == "Discharging"* ]]; do
                        for battery in /sys/class/power_supply/BAT*; do  battery_status=$(< "$battery/status") ; done
                        if [[ $battery_status != "Discharging" ]] ; then break ; fi
                            fn_notify "-t 5000 -r 69 " "CRITICAL" "Battery Critically Low" "$battery_percentage% is critically low. Device will execute $execute_critical in $((count/60)):$((count%60)) ."
                            count=$((count-1))
                            sleep 1
                        done
                        [ $count -eq 0 ] && fn_action
                    elif [[ "$battery_percentage" -le "$battery_low_threshold" ]] && [[ "$battery_status" == "Discharging" ]] && (( (last_notified_percentage - battery_percentage) >= $interval )); then  if $verbose; then echo  "Prompt:LOW: $battery_low_threshold $battery_status $battery_percentage" ; fi
                        fn_notify  "-t 5000 " "CRITICAL" "Battery Low" "Battery is at $battery_percentage%. Connect the charger."
                        last_notified_percentage=$battery_percentage
                    fi
}
fn_action () { #handles the $execute_critical command #? This is special as it will try to execute always
                  count=$(( timer > $mnt ? timer :  $mnt )) # reset count
                  nohup $execute_critical
}

fn_status () {
if [[ $battery_percentage -ge $battery_full_threshold ]] && [[ "$battery_status" != *"Discharging"* ]]; then echo "Full and $battery_status"
 battery_status="Full" ;fi
case "$battery_status" in         # Handle the power supply status
                "Discharging") if $verbose; then echo "Case:$battery_status Level: $battery_percentage" ;fi
                    if [[ "$prev_status" != "Discharging" ]] || [[ "$prev_status" == "Full" ]] ; then
                        prev_status=$battery_status
                        urgency=$([[ $battery_percentage -le "$battery_low_threshold" ]] && echo "CRITICAL" || echo "NORMAL")
                        fn_notify   "-t 5000 -r 54321 " "$urgency" "Charger Plug OUT" "Battery is at $battery_percentage%."
                        $execute_discharging
                    fi
                    fn_percentage
                    ;;
                "Not"*|"Charging") if $verbose; then echo "Case:$battery_status Level: $battery_percentage" ;fi
                    if [[ "$prev_status" == "Discharging" ]] || [[ "$prev_status" == "Not"* ]] ; then
                        prev_status=$battery_status
                        count=$(( timer > $mnt ? timer :  $mnt )) # reset count
                        urgency=$([[ "$battery_percentage" -ge $unplug_charger_threshold ]] && echo "CRITICAL" || echo "NORMAL")
                        fn_notify  "-t 5000 -r 54321 " "$urgency" "Charger Plug In" "Battery is at $battery_percentage%."
                    $execute_charging
                    fi
                    fn_percentage
                    ;;
                "Full") if $verbose; then echo "Case:$battery_status Level: $battery_percentage" ;fi
                    if [[ $battery_status != "Discharging" ]]; then
                    now=$(date +%s)
                    if [[ "$prev_status" == *"Charging"* ]] || ((now - lt >= $((notify*60)) )); then
                     fn_notify "-t 5000 -r 54321" "CRITICAL" "Battery Full" "Please unplug your Charger"
                    prev_status=$battery_status lt=$now
                    $execute_charging
                    fi
                    fi
                    ;;
                    *)
                    fn_percentage
                    ;;
            esac
}

get_battery_info() { #TODO Might change this if we can get an effective way to parse dbus. I will do it some time...
	total_percentage=0 battery_count=0
	for battery in /sys/class/power_supply/BAT*; do
		battery_status=$(<"$battery/status") battery_percentage=$(<"$battery/capacity")
		total_percentage=$((total_percentage + battery_percentage))
		battery_count=$((battery_count + 1))
	done
	battery_percentage=$((total_percentage / battery_count)) #? For Multiple Battery
}

fn_status_change () { # Handle when status changes
get_battery_info
  # Add these two lines at the beginning of the function
  local executed_low=false
  local executed_unplug=false

  if [ "$battery_status" != "$last_battery_status" ] || [ "$battery_percentage" != "$last_battery_percentage" ]; then
    last_battery_status=$battery_status
    last_battery_percentage=$battery_percentage    # Check if battery status or percentage has changed
    fn_verbose
    fn_percentage

    if [[ "$battery_percentage" -le "$battery_low_threshold" ]] && ! $executed_low; then $execute_low
    executed_low=true executed_unplug=false
    fi
    if [[ "$battery_percentage" -ge "$unplug_charger_threshold" ]] && ! $executed_unplug; then $execute_unplug
        executed_unplug=true executed_low=false
    fi

    if $undock; then fn_status; fi
  fi
}

# resume_processes() { for pid in $pids ; do  if [ "$pid" -ne "$current_pid" ] ; then kill -CONT $pid ; notify-send -a "Battery Notify" -t 2000 -r 9889 -u "CRITICAL" "Debugging ENDED, Resuming Regular Process" ; fi ; done }

main() { # Main function

battery_full_threshold=${battery_full_threshold:-100}
battery_critical_threshold=${battery_critical_threshold:-5}
unplug_charger_threshold=${unplug_charger_threshold:-80}
battery_low_threshold=${battery_low_threshold:-20}
timer=${timer:-120}
notify=${notify:-1140}
interval=${interval:-5}
execute_critical=${execute_critical:-"systemctl suspend"}
execute_low=${execute_low:-}
execute_unplug=${execute_unplug:-}

config_info
if $verbose; then for line in "Verbose Mode is ON..." "" "" "" ""  ; do echo $line ; done;
#TODO Might still need this in the future but for now we don't have any battery notify issues
# current_pid=$$
# pids=$(pgrep -f "/usr/bin/env bash ${scrDir}/batterynotify.sh" )
# for pid in $pids ; do if [ "$pid" -ne $current_pid ] ;then kill -STOP "$pid" ;notify-send -a "Battery Notify" -t 2000 -r 9889 -u "CRITICAL" "Debugging STARTED, Pausing Regular Process" ;fi ; done  ; trap resume_processes SIGINT ;
fi
    get_battery_info # initiate the function
    last_notified_percentage=$battery_percentage
    prev_status=$battery_status
dbus-monitor --system "type='signal',interface='org.freedesktop.DBus.Properties',path='$(upower -e | grep battery)'" 2> /dev/null | while read -r battery_status_change; do fn_status_change  ; done
}

verbose=false
  case "$1" in
        -i|--info)
            config_info
            exit 0
            ;;
        -v|--verbose)
            verbose=true
            ;;
        -*)
        cat << HELP
Usage: $0 [options]

[-i|--info]                    Display configuration information
[-v|--verbose]                 Debugging mode
[-h|--help]                    This Message
HELP
            exit 0
            ;;
  esac

mnc=2 mxc=50 mnl=10 mxl=80 mnu=50  mxu=100 mnt=60 mxt=1000 mnf=80 mxf=100 mnn=1 mxn=1140 mni=1 mxi=10 #Defaults Ranges
check_range() {
    local var=$1 min=$2 max=$3 error_message=$4
    if [[ $var =~ ^[0-9]+$ ]] && (( var >= min && var <= max )); then
        var=$var ; shift 2
    else
        echo -e "$1 WARNING: $error_message must be $min - $max." >&2
    fi
}

 check_range "$battery_full_threshold" $mnf $mxf "Full Threshold"
 check_range "$battery_critical_threshold" $mnc $mxc "Critical Threshold"
 check_range "$battery_low_threshold" $mnl $mxl "Low Threshold"
 check_range "$unplug_charger_threshold" $mnu $mxu "Unplug Threshold"
 check_range "$timer" $mnt $mxt "Timer"
 check_range "$notify" $mnn $mxn "Notify"
 check_range "$interval" $mni $mxi "Interval"

main
