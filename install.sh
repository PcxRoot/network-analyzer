#!/bin/bash

REQUIREMENT_FILE="./requirements"

if [[ "$EUID" -ne 0 ]]; then
	echo "[!] Please run this script as root"
	exit 1
fi

if [[ ! -f "$REQUIREMENT_FILE" ]]; then
	echo "[!] Requirements file not found: $REQUIREMENT_FILE"
	exit 2
fi

echo "[+] Updating package list..."
apt update -y

echo "[+] Installing dependencies..."

while read -r package; do
	[[ -z "$package" ]] && continue

	if dpkg -s "$package" &>/dev/null; then
		echo "[+] $package is already installed"
	else
		echo "[+] Installing $package..."
	fi
done < "$REQUIREMENT_FILE"

echo "[+] All dependencies installed succesfully" 
