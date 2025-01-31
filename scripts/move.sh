#!/usr/bin/bash

# Move all or some specifies scripts to the PATH directories.

# >>> variable declaration!
readonly version='1.1.0'
script="`basename "$0"`"
uid="${UID:-`id -u`}"

SUDO='sudo'
GIT_URL='https://raw.githubusercontent.com/rhuanpk/linux/main/scripts/.private/setload.sh'
SCRIPTS_PATH="${PK_LOAD_LINUX:-`wget -qO - "$GIT_URL" | bash - 2>&- | grep -F linux`}"

# >>> function declaration!
usage() {
cat << EOF
$script v$version

Move all or some specifies scripts to the \`/usr/local/bin\` folder.
NOTE: Execute this script first time inside your self folder with \`./\`.

Usage:
	- To move all: $script
	- To move some scripts: $script 'script-1.sh' 'script-2.sh'

Options:
	-s: Forces keep sudo;
	-r: Forces unset sudo;
	-v: Print version;
	-h: Print this help.
EOF
}

# >>> pre statements!
[ -z "$SCRIPTS_PATH" ] && SCRIPTS_PATH="`pwd`" || SCRIPTS_PATH+='/scripts'

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
[ "$#" -eq 0 ] && {
	for file in "$SCRIPTS_PATH"/*.sh; do
		$SUDO cp -v "$file" "/usr/local/bin/`basename ${file%.*}`"
	done
} || {
	for file; do
		if ! $SUDO cp -v "$SCRIPTS_PATH/$file" "/usr/local/bin/${file%.*}"; then
			print_usage
			exit 1
		fi
	done
}
