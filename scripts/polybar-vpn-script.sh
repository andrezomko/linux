#!/usr/bin/bash

# Return boolena if has VPN connection.

# >>> variable declaration!
readonly version='1.0.0'
script="`basename "$0"`"

# >>> function declaration!
usage() {
cat << EOF
$script v$version

Return boolena if has VPN connection.

Usage: $script [<options>]

Options:
	-v: Print version;
	-h: Print this help.
EOF
}

# >>> pre statements!
while getopts 'vh' option; do
	case "$option" in
		v) echo "$version"; exit 0;;
		:|?|h) usage; exit 2;;
	esac
done
shift $(("$OPTIND"-1))

# ***** PROGRAM START *****
IFNAMES="`ip -br link | cut -d ' ' -f 1`"
VPNS="tun0|wg0|`hostname`"
[[ "$IFNAMES" =~ ($VPNS) ]]
