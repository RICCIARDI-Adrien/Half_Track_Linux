#!/bin/sh

DisplayMessage()
{
	echo -e "\033[32m+--------------------------------------------------------------------"
	echo -e "| $1"
	echo -e "+--------------------------------------------------------------------\033[0m"
}

while true
do
	DisplayMessage "Select keyboard layout"
	echo "1. English (default)"
	echo "2. French"
	echo "3. German"
	echo "4. Italian"
	echo "5. Spanish"
	
	# Get a single character
	read -n 1 Character
	case $Character in
		1)
			Keyboard_Mapping_File=us
			;;
		2)
			Keyboard_Mapping_File=fr
			;;
		3)
			Keyboard_Mapping_File=de
			;;
		4)
			Keyboard_Mapping_File=it
			;;
		5)
			Keyboard_Mapping_File=es
			;;
	esac
	echo
	
	# Set chosen language
	if [ ! -z $Keyboard_Mapping_File ]
	then
		loadkmap < /etc/keyboard_mapping/$Keyboard_Mapping_File.bmap
		break
	fi
done