#!/bin/bash

clear

# Definimos variables para los colores del texto
RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
RESET='\e[0m'
BLUE='\e[1;34m'

salida () {
	echo -e "\n\n${YELLOW}(+) Closing script...${RESET}"
	exit 1
}

int_interfaz () {

	echo -e "${YELLOW}"
	read -p "Enter the interfaces to scan: " interfaces
	echo -e "${RESET}"
}



info_interfaz () {

	# Banner de la interfaz procesada
	echo -e "${YELLOW}###############################"
	echo -e "    Interface data ${GREEN}$1"
	echo -e "${YELLOW}###############################${RESET}\n"



	# Informacion de la interfaz
	IP=$(ip addr show $interfaz | grep -oE 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}' | awk '{print $2}')
	RANGO_IP=${IP%.*}.0/${IP#*/}
	echo -e "${GREEN}(+) MAC Address: $(ip link show dev $interfaz | grep link | awk '{print $2}')"
	echo "(+) Network range: $RANGO_IP"
	echo -e "(+) IP Address: $IP\n${RESET}"
}



info_ip () {

	# Empezamos el escaneo de la red
	echo -e "${YELLOW}###################################################"
	echo -e "    Scanning network ${GREEN}$RANGO_IP${YELLOW} on ${GREEN}$interfaz"
	echo -e "${YELLOW}###################################################${RESET}\n"


	ips=$(sudo nmap -sn $RANGO_IP | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
	for ip in $ips; do
		echo -e "${GREEN}(+) Device detected with IP: ${BLUE}$ip${RESET}"

		mac=$(sudo nmap -sn $ip | grep 'MAC' | awk '{print $3}')
		if [ -z "$mac" ]; then
			echo -e "${RED}(-) Unable to identify the device MAC address.${RESET}"
		else
			echo -e "${GREEN}(+) Device MAC address: ${BLUE}$mac${RESET}"
		fi

		ttl=$(ping -c 1 $ip 2>/dev/null| grep -oE 'ttl=[0-9]+' | grep -oE '[0-9]+')
		if [ -z "$ttl" ]; then
			echo -e "${RED}(-) Unable to identify the operating system${RESET}"
		elif [ "$ttl" -eq "64" ]; then
			echo -e "${GREEN}(+) The device is a ${BLUE}Linux${GREEN} machine${RESET}"
		elif [ "$ttl" -eq "128" ]; then
			echo -e "${GREEN}(+) The device is a ${BLUE}Windows${GREEN} machine${RESET}"
		else
			echo -e "${RED}(-) Unable to identify the operating system${RESET}"
		fi

		echo -e "${YELLOW}"
		read -p "Perform port scan?[Y/n]: " escaneo
		echo -e "${RESET}"
		if [[ "$escaneo" =~ ^[Yy]([Es][Ss])?$ || -z "$escaneo" ]]; then
			enumeracion_nmap $ip $RANGO_IP
		else
			echo
		fi
	done	
	echo -e "${YELLOW}All devices on network ${GREEN}$1${YELLOW} have been scanned${RESET}\n"
}



enumeracion_nmap () {

	echo -e "${YELLOW}(+) Scanning ports on host: ${GREEN}$1${RESET}"
	mkdir -p ./scan_results
	sudo nmap -Pn -p- -sS $1 | grep -E '[0-9]+/(tcp|udp)[[:space:]]+open' |
		{
		while read -r linea; do
			echo -e "\n${GREEN}---------------------------------------------------"
			puerto=$(echo "$linea" | awk -F'[[:space:]]+open[[:space:]]+' '{print $1}')
			servicio=$(echo "$linea" | awk -F'[[:space:]]+open[[:space:]]+' '{print $2}')
			echo -e "Port: ${RESET}$puerto${GREEN} | Service: ${RESET}$servicio${GREEN}"
			echo -e "-------------------------------------------------${RESET}"
		done
		echo -e "\n${YELLOW}+++++++++++++++++++++++++++++++++++++++++++++++++${RESET}\n"
	} | tee "./scan_results/$1_$(date +'%Y_%m_%d_%H_%M').txt"
}


trap salida SIGINT


echo -e "${GREEN}"
cat <<EOF
############################################################
#                                                          #
#               ██████╗  ██████╗ ██╗  ██╗                  #
#               ██╔══██╗██╔════╝ ╚██╗██╔╝                  #
#               ██████╔╝██║       ╚███╔╝                   #
#               ██╔═══╝ ██║       ██╔██╗                   #
#               ██║     ╚██████╗ ██╔╝ ██╗                  #
#               ╚═╝      ╚═════╝ ╚═╝  ╚═╝                  #
#                                                          #
#   Script : analyzer.sh                                   #
#   Author : PcxRoot                                       #
#   Role   : SysAdmin / Pentesting                         #
#                                                          #
############################################################
EOF
echo -e "${RESET}"

sleep 1 
# Definimos la interfaz
int_interfaz

for interfaz in $interfaces; do

	# Si la interfaz no existe se vuelve a pedir hasta que exista
	if ! /usr/bin/ip link show dev "$interfaz" &>/dev/null; then
		echo -e "${RED}(-) Interface \"$interfaz\" does not exist${RESET}\n"
		continue

	fi

	#Si la interfaz esta deshabilitada informamos y damos opcion de activarla	
	if /usr/bin/ip link show dev "$interfaz" | grep -q "state DOWN"; then
		echo -e "${RED}(-) Interface ${BLUE}$interfaz${RED} is disabled.${RESET}${GREEN}"
		read -p "Do you want to enable it?[Y/n]: " habilitar
		echo -e "${RESEST}"

		# Si habilitamos la interfaz corroboramos que haya sido exitoso
		if [[ -z "$habilitar" || "$habilitar" =~ ^[Yy]([eE][sS])?$ ]]; then
			/usr/bin/sudo /usr/bin/ip link set up "$interfaz"
			sleep 1
			estado=$(/usr/bin/ip -o link show "$interfaz" | awk '{print $9}')
			if [[ "$estado" == "DOWN" ]]; then
				echo -e "${RED}(-) Interface could not be enabled${RESET}"
				continue
			else
				echo -e "${GREEN}(+) Interface enabled succesfully${RESET}"
			fi
		else
			continue
		fi	
	fi


	info_interfaz $interfaz

	if [ "$interfaz" = 'lo' ]; then
		echo -e "${RED}(-) Loopback interface \"lo\" cannot be scanned.\n${RESET}"
		continue
	fi

	info_ip $RANGO_IP
	
done
