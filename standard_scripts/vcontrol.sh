#!/usr/bin/env zsh

# necessário: terminator && xdotool && zsh

percent_volume() {
	amixer -M get 'Master' | tail -n 1 | awk '{print $4}' | sed -E "s/\[|\]//g"
}

#xdotool key "ctrl+alt+x" type 'Volume (sair = q)'; xdotool key "KP_Enter"

while :; do
	clear
	echo -n "Volume: $(percent_volume) [+/-]? "; read -k 1 VALUE
	[ "${VALUE}" = "q" -o "${VALUE}" = "Y" ] && exit 0
	amixer set 'Master' 1%${VALUE} 1>/dev/null
done

#nohup terminator -u --borderless --geometry=200x48+1100+650 --command='zsh -c volume.sh' &
