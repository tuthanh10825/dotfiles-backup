#!/usr/bin/env sh

#// set variables
scrDir="$(dirname "$(realpath "$0")")"
rofiConf="/home/tuthanh/.config/rofi/selection.rasi"
thmbDir="/home/tuthanh/.cache/thumbnails/wallpaper"
wallSource="/home/tuthanh/.config/theme/wallpaper/"

mkdir -p "$thmbDir"

#// set rofi scaling
[[ "${rofiScale}" =~ ^[0-9]+$ ]] || rofiScale=10
r_scale="configuration {font: \"JetBrainsMono Nerd Font ${rofiScale}\";}"
elem_border=$(( hypr_border * 3 ))

#// scale for monitor
mon_x_res=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width')
mon_scale=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .scale' | sed "s/\.//")
mon_x_res=$(( mon_x_res * 100 / mon_scale ))

#// generate config
elm_width=$(( (28 + 8 + 5) * rofiScale ))
max_avail=$(( mon_x_res - (4 * rofiScale) ))
col_count=$(( max_avail / elm_width ))
r_override="window{width:100%; height: 100%; } listview{columns:${col_count};spacing:5em;} element{border-radius:${elem_border}px;orientation:vertical;} element-icon{size:28em;border-radius:0em;} element-text{padding:1em;} configuration{show-icons:true;}"


#// launch rofi menu
currentWall="$(basename "$(readlink ~/.config/theme/wall.set)")"

hashMap=$(find "${wallSource}" -type f \( -iname "*.gif" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -exec sha1sum {} + | sort)

if [ -z "${hashMap}" ] ; then
    echo "WARNING: No image found in \"${wallSource}\""
    exit 1
fi

wallList=()
wallHash=()

while read -r hash image ; do
    wallHash+=("${hash}")
    wallList+=("${image}")
    [[ -f "${thmbDir}/${hash}.sqre" ]] || magick "${image}" -strip -thumbnail 500x500^ -gravity center -extent 500x500 "${thmbDir}/${hash}.sqre" &
done <<< "${hashMap}"

rofiSel=$(parallel --link echo -en "\$(basename "{1}")"'\\x00icon\\x1f'"${thmbDir}"'/'"{2}"'.sqre\\n' ::: "${wallList[@]}" ::: "${wallHash[@]}" | rofi -dmenu  -theme-str "${r_override}" -config "${rofiConf}" -select "${currentWall}")

wallSet="$HOME/.config/theme/wall.set"
#// apply wallpaper
if [ ! -z "${rofiSel}" ] ; then
    setWall="$(find "${wallSource}" -type f -name "${rofiSel}")"
    if [ -n "$setWall" ]; then
        ln -sf "$setWall" "$wallSet"
        "$scrDir/wallpaper.sh" "$wallSet"
        notify-send -a "t1" "Choosing $setWall"
    fi
fi

