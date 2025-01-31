#!/usr/bin/bash

# Checks the battery percentage and suspend for safety when necessary.

# >>> built-in sets!
set +o histexpand

# >>> variable declaration!
readonly version='1.1.0'
script="`basename "$0"`"
uid="${UID:-`id -u`}"

SUDO='sudo'

# >>> function declaration!
usage() {
cat << EOF
$script v$version

Checks the battery percentage, if it is 9% or less the system is suspended.

Usage: $script [<options>]

Options:
	-s: Forces keep sudo;
	-r: Forces unset sudo;
	-v: Print version;
	-h: Print this help.
EOF
}

privileges() {
	FLAG_SUDO="${1:?needs sudo flag}"
	FLAG_ROOT="${2:?needs root flag}"
	if [[ -z "$SUDO" && "$uid" -ne 0 ]]; then
		echo "$script: run with root privileges"
		exit 1
	elif ! "$FLAG_SUDO"; then
		if "$FLAG_ROOT" || [ "$uid" -eq 0 ]; then
			unset SUDO
		fi
	fi
}

check-needs() {
	PACKAGES=('acpi' 'libnotify-bin')
	for package in "${PACKAGES[@]}"; do
		if ! dpkg -s "$package" &>/dev/null; then
			read -p "$script: this script needs the \"$package\" package but not installed, install this? [Y/n] " answer
			[ -z "$answer" ] || [ 'y' = "${answer,,}" ] && $SUDO apt install -y "$package"
		fi
	done
}

# >>> pre statements!
while getopts 'srvh' option; do
	case "$option" in
		s) privileges true false;;
		r) privileges false true;;
		v) echo "$version"; exit 0;;
		:|?|h) usage; exit 2;;
	esac
done
shift $(("$OPTIND"-1))

check-needs

# ***** PROGRAM START *****
# cron: */2 * * * * export DISPLAY=:0; /usr/local/bin/pk/suspend2safety 2>/tmp/cron_error.log
# export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/`id -u`/bus

BATTERY_POWER=`acpi | tr -d '[[:blank:]]' | cut -d ',' -f 2`
[ "`acpi --ac-adapter | tr -d '[[:blank:]]' | cut -d ':' -f 2`" = 'on-line' ] && IS_PLUGED=true || IS_PLUGED=false

if ! $IS_PLUGED; then
	if [ ${BATTERY_POWER%\%} -le 9 ]; then
		systemctl suspend
	elif [ ${BATTERY_POWER%\%} -le 11 ]; then
		notify-send 'Battery Power low!' "Low battery: $BATTERY_POWER or less, plug it into outlet."
	fi
fi
