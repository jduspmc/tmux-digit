#!/usr/bin/env bash
# shellcheck disable=SC2155,SC2034
digits_circle=(⓪ ① ② ③ ④ ⑤ ⑥ ⑦ ⑧ ⑨ ⑩ ⑪ ⑫ ⑬ ⑭ ⑮ ⑯ ⑰ ⑱ ⑲ ⑳)
digits_circle_inv=(0 󰲠 󰲢 󰲤 󰲦 󰲨 󰲪 󰲬 󰲮 󰲰)
digits_square=(󰎣 󰎦 󰎩 󰎬 󰎮 󰎰 󰎵 󰎸 󰎻 󰎾)
digits_square_inv=(󰎡 󰎤 󰎧 󰎪 󰎭 󰎱 󰎳 󰎶 󰎹 󰎼)
digits_layer=(󰎢 󰎥 󰎨 󰎫 󰎲 󰎯 󰎴 󰎷 󰎺 󰎽)
digits_layer_inv=(󰼎 󰼏 󰼐 󰼑 󰼒 󰼓 󰼔 󰼕 󰼖 󰼗)
digits_number=( 󰬺 󰬻 󰬼 󰬽 󰬾 󰬿 󰭀 󰭁 󰭂)

interpolation=(
	"#S"
	"#I"
)

get_command() {
	local name="$1"
	local -i i=0
	shift
	for digit; do
		echo -n "#{?#{==:#$name,$i},$digit,}"
		i=$((i + 1))
	done
}

get_tmux_option() {
	local option=$1
	local default_value=$2
	local option_value=$(tmux show-option -gqv "$option")
	if [ -z "$option_value" ]; then
		echo "$default_value"
	else
		echo "$option_value"
	fi
}

set_tmux_option() {
	local option="$1"
	local value="$2"
	tmux set-option -gq "$option" "$value"
}

do_interpolation() {
	local style="digits_$(get_tmux_option @digit-style circle)"
	eval 'local digits=("${'"$style"'[@]}")'
	local commands=(
		"$(get_command S "${digits[@]}")"
		"$(get_command I "${digits[@]}")"
	)
	local all_interpolated="$1"
	for ((i = 0; i < ${#commands[@]}; i++)); do
		all_interpolated=${all_interpolated//${interpolation[$i]}/${commands[$i]}}
	done
	echo "$all_interpolated"
}

update_tmux_option() {
	local option="$1"
	local option_value="$(get_tmux_option "$option")"
	local new_option_value="$(do_interpolation "$option_value")"
	set_tmux_option "$option" "$new_option_value"
}

main() {
	update_tmux_option set-titles-string
	update_tmux_option status-left
	update_tmux_option status-right
	update_tmux_option window-status-current-format
	update_tmux_option window-status-format
}
main
