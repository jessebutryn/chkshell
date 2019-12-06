#!/usr/bin/env bash
#
#######################################
usage () {
	cat <<-EOF >&2
		foobar
	EOF
}
whatis_sh () {
	local sh=$1
	local ln=$(ls -l "$sh" | awk '{print $NF}')
	local s=${ln##*/}
	local v
	if [[ $sh != "$ln" ]]; then
		get_shell_version "$ln"
	else
		v=$("$sh" --version)
		if grep -q bash <<<"$v"; then
			printf 'bash: %s\n' "$(get_shell_version "$sh" bash)"
		elif grep -q ksh <<<"$v"; then
			printf 'ksh: %s\n' "$(get_shell_version "$sh" ksh)"
		elif grep -q zsh <<<"$v"; then
			printf 'zsh: %s\n' "$(get_shell_version "$sh" zsh)"
		else
			printf '%s\n' 'Unable to determine sh version' >&2
		fi
	fi
}
get_shell_version () {
	local spath=$1
	local s=${spath##*/}
	[[ -n $2 ]] && s=$2
	case $s in
		bash)
			"$spath" --version | egrep -o '[0-9]+\.[0-9]+\.[0-9]+\([0-9]\)-release'
		;;
		csh|tcsh)
			"$spath" --version | egrep -o '([0-9]{1,}\.)+[0-9]{1,}'
		;;
		ksh)
			"$spath" --version |& egrep -o '(85|86|88|93).+\s' | tr -d ' '
		;;
		sh)
			whatis_sh "$spath"
		;;
		zsh)
			"$spath" --version | egrep -o '([0-9]{1,}\.)+[0-9]{1,}\s' | tr -d ' '
		;;
		dash)
			printf '%s\n' 'Unable to determine dash version' >&2
		;;
		fish)
			"$spath" --version | egrep -o '([0-9]{1,}\.)+[0-9]{1,}'
		;;
		pwsh)
			"$spath" --version | egrep -o '([0-9]{1,}\.)+[0-9]{1,}'
		;;
	esac
}
line_break () {
	local s=$1
	printf '%*s\n' 80 | tr ' ' "${s:--}"
}
execute_command () {
	local sh=$1
	local command=$2
	echo
	line_break '='
	printf 'Command: %s\nShell: %s\nVersion: %s\n' \
	"$c" "$s" "$(get_shell_version "$s")"
	line_break
	time "$sh" -c "$c"
	ec=$?
	line_break
	printf 'exit code: %s\n' "$ec"
	line_break '='
	echo
}
filter_shells () {
	local f=$1
	shift
	local -a sh=( "$@" )
	for s in "${sh[@]}"; do
		echo "$s" | grep "$f"
	done
}