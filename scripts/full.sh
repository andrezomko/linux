#!/usr/bin/bash

# Script that updates, fixes and cleans the system in one go.

# >>> built-in sets!
set -e

# >>> variable declaration!
readonly version='2.1.0'
script="`basename "$0"`"
uid="${UID:-`id -u`}"

SUDO='sudo'

# >>> function declaration!
usage() {
cat << EOF
$script v$version

Execute "all" apt commands to fix, update and cleanup.

Usage: $script [<options>]

Options:
	-s: Forces keep sudo;
	-r: Forces unset sudo;
	-v: Print version;
	-h: Print this help.
EOF
}

# >>> pre statements!
while getopts 'srvh' OPTION; do
	case "$OPTION" in
		s) FLAG_SUDO=true;;
		r) FLAG_ROOT=true;;
		v) echo "$version"; exit 0;;
		:|?|h) usage; exit 2;;
	esac
done
shift $(("$OPTIND"-1))

if [[ -z "$SUDO" && "$uid" -ne 0 ]]; then
	echo "$script: run with root privileges"
	exit 1
elif ! "${FLAG_SUDO:-false}"; then
	if "${FLAG_ROOT:-false}" || [ "$uid" -eq 0 ]; then
		unset SUDO
	fi
fi

# ***** PROGRAM START *****
# Fix
${SUDO:+sudo -v}
echo '> dpkg --configure -a'
$SUDO dpkg --configure -a
echo '> apt install -fy'
$SUDO apt install -fy

# Update
${SUDO:+sudo -v}
echo '> apt update'
$SUDO apt update
echo '> apt upgrade -y'
$SUDO apt upgrade -y
echo '> apt install --upgradeable'
$SUDO apt list --upgradable 2>&- \
	| sed -nE 's~^(.*)/.*$~\1~p' \
	| xargs $SUDO apt install -y

# Clean
${SUDO:+sudo -v}
echo '> apt clean -y'
$SUDO apt clean -y
echo '> apt autoclean -y'
$SUDO apt autoclean -y
echo '> apt autoremove -y'
$SUDO apt autoremove -y

# Update and Clean
${SUDO:+sudo -v}
echo '> apt full-upgrade -y'
$SUDO apt full-upgrade -y
