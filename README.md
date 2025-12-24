# Network Analyzer Script (Bash)

## Description

<p>This project is a Bash script designed for local network analysis and enumeration. It allows the user to select one or more network interfaces, gather interface information, discover active hosts on the network, infer operating systems, and optionally perform full port scans using Nmap.</p>

<p>It is intended for system administrators, cybersecurity students, and pentesting practice in controlled environments.</p>

## Features

- Interactive network interface selection

- Interface validation and activation (if disabled)

- IP, MAC address, and network range detection

- Host discovery using nmap -sn

- MAC address identification

- Basic OS fingerprinting via TTL analysis

- Optional full TCP port scan per host

- Automatic scan result storage with timestamps

- Color-coded terminal output for readability

## Requeriments

- Linux System

- Bash

- **nmap**

- **iproute2**

- Root privileges (or sudo)

## Usage

> ### Clone the repository

> - `git clone` https://github.com/PcxRoot/analyzer.git

> ### Give permissions

> - `chmod +x analyzer.sh install.sh`

> ### Install dependencies

> - `sudo ./install.sh`

> ### Run the script

> - `./analyzer.sh`

<p>
*Follow the on-screen instructions to select the network interface and scanning options.*
</p>

![Input interfaces to scan](/readme/select_interfaces.png "Input interfaces to scan")

![Information about interface](/readme/info.png "Information about interface")

![Port scan](/readme/port_scan.png "Port scanner")

## Output

<p>
All port scan results are stored in:
</p>

> ./scan_results/

<p>
Each file is named using the target IP and timestamp.
</p>

# Disclaimer 
<p>
This tool is intended *only for educational purposes and authorized environments*.
Do not use it on networks or systems without explicit permission.
</p>

# Author

- **PcxRoot**

- Role: SysAdmin / Pentesting


