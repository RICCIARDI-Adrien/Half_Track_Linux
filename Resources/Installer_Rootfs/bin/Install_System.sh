#!/bin/sh

DisplayMessage()
{
	echo -e "\033[32m+--------------------------------------------------------------------"
	echo -e "| $1"
	echo -e "+--------------------------------------------------------------------\033[0m"
}

#--------------------------------------------------------------------------------------------------
# Ask for keyboard mapping
#--------------------------------------------------------------------------------------------------
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

#--------------------------------------------------------------------------------------------------
# Continue installation ?
#--------------------------------------------------------------------------------------------------
DisplayMessage "Installation confirmation"

while true
do
	read -p "Do you want to proceed for installation (y/n) ? " -n 1 Character
	echo
	
	if [ "$Character" == "y" ]
	then
		break;
	fi
	
	if [ "$Character" == "n" ]
	then
		exit
	fi
done

#--------------------------------------------------------------------------------------------------
# Select root partition
#--------------------------------------------------------------------------------------------------
DisplayMessage "Root partition configuration"
echo "Starting a shell to allow you to configure what will be your root partition."
echo "Execute 'fdisk' for the disk you want to use and create a partition. Look in /dev for the partition name, like '/dev/sda1'."
echo "When you have finished, type 'exit' to return to the installation program."
sh

echo -n "Enter partition device (for example, /dev/sda1) : "
read Partition_Device

while true
do
	read -p "Do you want to format the partition (y/n) ? " -n 1 Character
	echo
	
	if [ "$Character" == "y" ]
	then
		echo "Formatting partition..."
		mkfs.ext4 $Partition_Device
		if [ $? -ne 0 ]
		then
			echo -e "\033[31mError : failed to format the partition.\033[0m"
			exit 1
		fi
	fi
	break
done

# TODO create system fstab with this partition

#--------------------------------------------------------------------------------------------------
# Copy system to root partition
#--------------------------------------------------------------------------------------------------
DisplayMessage "Copying system files"

# Mount the CDROM partition
mkdir -p /mnt/source
mount /dev/sr0 /mnt/source
if [ $? -ne 0 ]
then
	echo -e "\033[31mError : failed to mount the CDROM partition. Aborting installation.\033[0m"
	exit 1
fi

# Mount the system partition
mkdir -p /mnt/destination
mount -t ext4 $Partition_Device /mnt/destination

# Copy the whole system rootfs
# TODO tar -xf /mnt/source/System.tar.bz2 -C /mnt/destination

# TODO copy fstab

#--------------------------------------------------------------------------------------------------
# Install system bootloader
#--------------------------------------------------------------------------------------------------
DisplayMessage "Installing GRUB"
sbin/grub-install -d /lib/grub/i386-pc --boot-directory=/mnt/destination/boot $Partition_Device
# TODO
#--------------------------------------------------------------------------------------------------
# 
#--------------------------------------------------------------------------------------------------
#DisplayMessage "Creating user" TODO maybe a first install script on the system ?

#--------------------------------------------------------------------------------------------------
# Reboot system
#--------------------------------------------------------------------------------------------------
sync
umount /mnt/source
umount /mnt/destination

echo "Remove the installation medium and hit enter to reboot."
read

reboot
