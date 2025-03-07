if pgrep -x "wlogout" > /dev/null
then
    pkill -x "wlogout"
    exit 0
fi

x_mon=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width')
y_mon=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .height')
hypr_scale=$(hyprctl -j monitors | jq '.[] | select (.focused == true) | .scale' | sed 's/\.//')

export mgn=$(( y_mon * 28 / hypr_scale ))
export hvr=$(( y_mon * 23 / hypr_scale )) 


export fntSize=$(( y_mon * 2 / 100 ))

wlTmplt="/home/tuthanh/.config/wlogout/style.css"
wlStyle="$(envsubst < $wlTmplt)"

wlogout -b 6 -c 0 -r 0 -m 0 --css <(echo "${wlStyle}") --protocol layer-shell
