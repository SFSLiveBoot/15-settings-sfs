#!/bin/sh

save-setting() {
	test -r "$HOME/.config/saved-settings-path" || {
		echo "Error: need to configure path with 'save-setting-path'" >&2
		return 1
	}
	case "$1" in
	-h | --help)
		echo "Usage: $FUNCNAME [[{--del}] <path>]"
		return
		;;
	"")
		systemctl --user list-units -o json "save-setting@*.path" |
			jq -r ".[].unit" | sort |
			sed -e 's/^save-setting@//' -e 's/\.path$//' |
			while read -r path; do
				systemd-escape -p -u "$path"
			done
		;;
	--del)
		shift
		for path; do
			case "$path" in /*) ;; *) path="$PWD/$path" ;; esac
      path="$(echo "$path" | sed -E -e 's@/\./@/@g' -e 's@/+@/@g' -e :top -e 's@^/\.\./@/@' -e '/^\/\.\.\//b top' -e 's@/([^/]+)/\.\.(/|$)@\2@g')"
			systemctl --user disable --now "save-setting@$(systemd-escape -p "$path").path"
			(
				. "$HOME/.config/saved-settings-path"
				rm -v "$SETTINGS_PATH$HOME/.config/systemd/user/default.target.wants/save-setting@$(systemd-escape -p "$path").path"
			)
		done
		;;
	*)
		for path; do
			case "$path" in /*) ;; *) path="$PWD/$path" ;; esac
      path="$(echo "$path" | sed -E -e 's@/\./@/@g' -e 's@/+@/@g' -e :top -e 's@^/\.\.(/|$)@/@' -e 's@/([^/]+)/\.\.(/|$)@\2@' -e '/\/\.\.\//b top')"
			systemctl --user enable --now "save-setting@$(systemd-escape -p "$path").path"
			systemctl --user start "save-setting@$(systemd-escape -p "$path").service"
			systemctl --user start "save-setting@$(systemd-escape -p "$HOME/.config/systemd/user/default.target.wants/save-setting@$(systemd-escape -p "$path").path").service"
		done
		;;
	esac
}

save-setting-path() {
	if test -n "$1"; then
		test -d "$1" || {
			echo "Usage: $FUNCNAME [<directory>]" >&2
			return 1
		}
		echo "SETTINGS_PATH=$1" | tee "$HOME/.config/saved-settings-path"
		cp --parents -b -S ".bkup-$(date +%s)" -avt "$1" "$HOME/.config/saved-settings-path"
	else
		cat "$HOME/.config/saved-settings-path"
	fi
}
