#!/bin/sh

__save_setting_normalize_path() {
	echo "$1" | sed -zE -e 's@/\./@/@g' -e 's@/+@/@g' -e :top -e 's@^/\.\.(/|$)@/@' -e 's@/([^/]+)/\.\.(/|$)@\2@' -e '/\/\.\.\//b top'
}

save_setting() {
	local path _save_once=""
	test -r "$HOME/.config/saved-settings-path" || {
		echo "Error: need to configure path with 'save-setting-path'" >&2
		return 1
	}
	case "$1" in
	-h | --help)
		echo "Usage: $FUNCNAME [[{--del|--once}] <path>]"
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
			path="$(__save_setting_normalize_path "$path")"
			systemctl --user disable --now "save-setting@$(systemd-escape -p "$path").path"
			(
				# shellcheck disable=SC1091
				. "$HOME/.config/saved-settings-path"
				rm -v "$SETTINGS_PATH$HOME/.config/systemd/user/default.target.wants/save-setting@$(systemd-escape -p "$path").path"
			)
		done
		;;
	--once | *)
		case "$1" in --once)
			_save_once=1
			shift
			;;
		esac
		for path; do
			case "$path" in /*) ;; *) path="$PWD/$path" ;; esac
			path="$(__save_setting_normalize_path "$path")"
			systemctl --user start "save-setting@$(systemd-escape -p "$path").service"
			test -z "$_save_once" || continue
			systemctl --user enable --now "save-setting@$(systemd-escape -p "$path").path"
			systemctl --user start "save-setting@$(systemd-escape -p "$HOME/.config/systemd/user/default.target.wants/save-setting@$(systemd-escape -p "$path").path").service"
		done
		;;
	esac
}

save_setting_path() {
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
