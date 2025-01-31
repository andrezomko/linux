#!/usr/bin/bash

# Setup packages and dot files for emoji fonts.

# >>> variable declaration!
readonly version='1.0.0'
script="`basename "$0"`"
uid="${UID:-`id -u`}"
user="`id -un "${uid/#0/1000}"`"
home="/home/$user"

SUDO='sudo'

# >>> function declaration!
usage() {
cat << EOF
$script v$version

Automaticlly set emoji fonts for browsers.

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
PACKAGES=('fonts-symbola' 'fonts-noto-color-emoji')
PATHWAY="$home/.config/fontconfig/conf.d"

for package in "${PACKAGES[@]}"; do
	if ! dpkg -s "$package" &>/dev/null; then
		echo "$script: NEEDS the \"$package\" package but not installed, it will be installed"
		if $SUDO apt install -y "$package"; then
			echo "$script: package \"$package\" that's OK"
		else
			cat <<- eof
				$script: some WRONG occured with package "$package"
				$script: exiting (with 1) WITHOUT complete the script
			eof
		fi
	fi
done

[ ! -d "$PATHWAY" ] && mkdir -pv "$PATHWAY"
cat << \EOF > "$PATHWAY/fonts.conf"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
	<!-- ## serif ## -->
	<alias>
		<family>serif</family>
		<prefer>
			<family>Noto Serif</family>
			<family>emoji</family>
			<family>Liberation Serif</family>
			<family>Nimbus Roman</family>
			<family>DejaVu Serif</family>
		</prefer>
	</alias>
	<!-- ## sans-serif ## -->
	<alias>
		<family>sans-serif</family>
		<prefer>
			<family>Noto Sans</family>
			<family>emoji</family>
			<family>Liberation Sans</family>
			<family>Nimbus Sans</family>
			<family>DejaVu Sans</family>
		</prefer>
	</alias>
</fontconfig>
EOF
fc-cache -f

echo "$script: ALL DONE, restart the applications to see the changes"
