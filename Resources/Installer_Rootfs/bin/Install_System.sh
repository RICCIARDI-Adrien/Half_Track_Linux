#!/bin/sh

DisplayMessage()
{
	echo -e "\033[32m+--------------------------------------------------------------------"
	echo -e "| $1"
	echo -e "+--------------------------------------------------------------------\033[0m"
}

# Convert a Linux partition naming (like /dev/sda1) to GRUB format (hd0,msdos1)
ConvertLinuxPartitionNameToGRUB()
{
	GRUB_Partition_Name=msdos$(echo $1 | cut -c 9)

	case $(echo -n $1 | cut -c 8) in
		a)
			GRUB_Hard_Disk_Name="hd0"
			;;
		b)
			GRUB_Hard_Disk_Name="hd1"
			;;
		c)
			GRUB_Hard_Disk_Name="hd2"
			;;
		d)
			GRUB_Hard_Disk_Name="hd3"
			;;
		e)
			GRUB_Hard_Disk_Name="hd4"
			;;
		f)
			GRUB_Hard_Disk_Name="hd5"
			;;
		g)
			GRUB_Hard_Disk_Name="hd6"
			;;
		h)
			GRUB_Hard_Disk_Name="hd7"
			;;
		i)
			GRUB_Hard_Disk_Name="hd8"
			;;
		j)
			GRUB_Hard_Disk_Name="hd9"
			;;
		# Do not handle more disks because they are present in only few configurations
		*)
			GRUB_Hard_Disk_Name="Unknown hard disk"
			;;
	esac
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
	
	# TODO create keyboard init script to automatically set the mapping on system boot
	
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
	read -p "Do you want to proceed with installation (y/n) ? " -n 1 Character
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
			echo -e "\033[31mError : failed to format the partition, aborting installation.\033[0m"
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
	echo -e "\033[31mError : failed to mount the CDROM partition, aborting installation.\033[0m"
	exit 1
fi

# Mount the system partition
mkdir -p /mnt/destination
mount -t ext4 $Partition_Device /mnt/destination

# Copy the whole system rootfs (don't forget that the source file system is ISO9660, so the archive name is modified due to the file system limitations)
tar -xf /mnt/source/system_rootfs_tar.bz2 -C /mnt/destination --strip 1

# TODO copy fstab

#--------------------------------------------------------------------------------------------------
# Install system bootloader
#--------------------------------------------------------------------------------------------------
DisplayMessage "Installing GRUB"

while true
do
	read -p "Do you want to install the GRUB bootloader (y/n) ? " -n 1 Character
	echo
	
	if [ "$Character" == "y" ]
	then
		# Remove partition number to get the hard disk device
		Hard_Disk_Device=$(echo $Partition_Device | cut -c -8)
	
		echo "Installing GRUB on $Hard_Disk_Device..."
		grub-install -d /lib/grub/i386-pc --boot-directory=/mnt/destination/boot $Hard_Disk_Device
		if [ $? -ne 0 ]
		then
			echo -e "\033[31mError : failed to install GRUB, aborting installation.\033[0m"
			exit 1
		fi
		
		ConvertLinuxPartitionNameToGRUB $Partition_Device
		echo "Generating GRUB configuration file..."
		echo "set timeout=2" > /mnt/destination/boot/grub/grub.cfg
		echo "" >> /mnt/destination/boot/grub/grub.cfg
		echo "menuentry 'Half-track Linux' {" >> /mnt/destination/boot/grub/grub.cfg
		echo "	set root='$GRUB_Hard_Disk_Name,$GRUB_Partition_Name'" >> /mnt/destination/boot/grub/grub.cfg
		echo "	linux /boot/vmlinux root=$Partition_Device">> /mnt/destination/boot/grub/grub.cfg
		echo "}" >> /mnt/destination/boot/grub/grub.cfg
		break
	fi
	
	if [ "$Character" == "n" ]
	then
		break
	fi
done

# TODO
#--------------------------------------------------------------------------------------------------
# 
#--------------------------------------------------------------------------------------------------
#DisplayMessage "Creating user" TODO maybe a first install script on the system ?

#--------------------------------------------------------------------------------------------------
# Reboot system
#--------------------------------------------------------------------------------------------------
DisplayMessage "Installation terminated"

sync
umount /mnt/source
umount /mnt/destination

echo "Remove the installation medium and hit enter to reboot."
read

# Manually trigger a reboot as the busybox reboot is not working, because busybox init is not used
# Synchronize file systems
echo s > /proc/sysrq-trigger
# Unmount file systems
echo u > /proc/sysrq-trigger
# Reboot
echo b > /proc/sysrq-trigger
