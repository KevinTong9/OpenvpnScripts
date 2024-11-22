#!/bin/bash
trap final SIGINT
final() {
	echo "CTRL^C Detected,exiting ..."
	exit 0
}

P="$(find ./ -mindepth 1 -maxdepth 1 -type f -iname "*.conf" | sed -e 's/\.conf$//g' -e "s@\./@@g" | uniq | nl | sed -e 's/^ \+//g')"
while true; do
	echo -e "\033[36m---\t----------\033[0m"
	echo -e "\033[36m${P}\033[0m"
	echo -e "\033[36m---\t----------\033[0m"
	echo "Please select one server to manage,Press CTRL^C to exit"
	read input_line
	case $input_line in
	q | Q)
		echo -e "\033[31mExiting...\033[0m"
		break
		;;
	*) ;;
	esac

	s_bool=-1
	while read pline; do
		si=$(echo -e "$pline" | cut -f1)
		sd=$(echo -e "$pline" | cut -f2)
		if [[ $si == $input_line ]]; then
			s_bool=1
			while true; do
				echo -e "\033[36m------------------\033[0m"
				echo -e "$sd"
				echo -e "\033[36m---\t----------\033[0m"
				echo -e "\033[36m1.\tmanage shell\033[0m"
				echo -e "\033[36m2.\tstatus\033[0m"
				echo -e "\033[36m3.\trestart\033[0m"
				echo -e "\033[36mq.\tquit\033[0m"
				echo -e "\033[36m---\t----------\033[0m"
				echo -e "Enter your choice: "
				read choice </dev/tty
				case $choice in
				1)
					tar_dst=$(cat "./${sd}.conf" | grep "^management " | cut -d" " -f2-3) </dev/tty >/dev/tty 2>/dev/tty
					if [[ -z $tar_dst ]]; then
						echo "Management Not Set, exiting..."
					else
						bash -i <(echo telnet "${tar_dst}") </dev/tty >/dev/tty 2>/dev/tty
					fi
					;;
				2)
					systemctl status openvpn@${sd}.service </dev/tty
					;;
				3)
					systemctl restart openvpn@${sd}.service </dev/tty
					;;
				4 | q | Q)
					echo -e "\033[31mExiting...\033[0m"
					break
					;;
				*)
					echo -e "\033[31mInvalid option. Please try again.\033[0m"
					;;
				esac
			done
		fi
	done < <(echo -e "$P")

	if [[ $s_bool == -1 ]]; then
		echo -e "\033[31mInvalid option. Please try again.\033[0m"
		continue
	fi
done
echo -e "Bye."

