#!/bin/bash
# ADB SCRIPT
return='`'
browser="awb"
agent="agent"
work="work"
launcher="launcher"
DATE=`date +%d_%m_%y`
now=$(date +"%T")
timerPid=$!

function enter_text {
	text="null"
	until [ $text = $return ]; do	
		echo -e "Type text to be pushed to the devices (1 = enter, 2 = tab)"
		read text
		if [ $text != $return ]; then
			if [ $text = "1" ]; then
				./adb shell input keyevent 66
			elif [ $text = "2" ]; then
				./adb shell input keyevent 20
			else
				./adb shell input text $text
			fi
		fi
	done
}
function close_and_clear {

}
function install {
	adb devices
	app=""
	echo "Drag apk to install here ---> "
	read app
	adb install -r $app
}
function uninstall {

}
function insert_wifi {

}
function insert_gmail {

}
function adb_command {
	echo "Insert command (without ./adb) "
	read command
	./adb $command
}

# Startup Script to let the user know what the function does.
ScriptTopper() {
echo "=========================================================================="
echo "/                                                                        \""
echo "/                                Welcome!                                \""
echo "/                                                                        \""
echo "/                                                                        \""
echo "/ NOTES:                                                                 \""
echo "/ * Make sure device is connected and on debug (type adb devices in term)\""
echo "/ * If script fails, press CTRL+C to stop it and restart.                \""
echo "/ * By default all logs are saved to a Documents/Android folder.         \""
echo "/ * Send cjones@air-watch.com with any comments/suggestions.             \""
echo "/                                                                        \""
echo "=========================================================================="
echo
echo

}

#Checks for device and loops until its found.
StartUp(){
clear
ScriptTopper
echo
read -p "Press [Enter] key when device is connected via USB..."
echo
CheckForDevice
}

CheckForDevice(){
echo Checking for device...
echo
sleep 1
ADBDevices=$(adb devices) 
echo $ADBDevices > ~/Documents/Android/tmp
Condition
}

#Logic for determining if device is connected by reading output of ADB Devices

Condition(){
	#This is a messy way of finding out if there is a device connected. The problem was with locating a Android ID in a returned 'ADB Devices' string.
	#This looks for numbers, if theres a number in the string then there is a Device connected, possible to have bugs here where theres a Device ID without a 0, 2, or 3.

#Old code that didnt workie.

# if [ -n "$(grep -F '0' ~/Documents/Android/tmp)" ]
# then
# 	GetDeviceData
# elif [ -n "$(grep -F '2' ~/Documents/Android/tmp)" ];
# then
# 	#If Device ID is found proceeds.
# 	GetDeviceData
# elif [ -n "$(grep -F '3' ~/Documents/Android/tmp)" ];
# then
# 	#If Device ID is found proceeds.
# 	GetDeviceData
# else
# 	  # Loops back to the top.
#   	read -p "No devices detected, make sure USB Debugging is turned on. Press Enter to try again..."
#   	sleep 1
# 	CheckForDevice
# fi

#Read the size of the temp file to see if a device is connected.
filesize=$(stat -c '%s' ~/Documents/Android/tmp)
if [[ filesize > 25]]; then
	GetDeviceData
	#If device is found move on to the next step.
else
	# 	  # Loops back to the top.
  	read -p "No devices detected, make sure USB Debugging is turned on. Press Enter to try again..."
  	sleep 1
	CheckForDevice

fi
}

#Fetches device details and logs them into variables.
#TO DO change the awk to actually edit the variable. 
GetDeviceData(){

ProductBrand=$(adb shell getprop ro.product.brand)
Device=$(adb shell getprop ro.product.device)
Model=$(adb shell getprop ro.product.model)
ProductBrand=`echo ${ProductBrand:0:1} | tr  '[a-z]' '[A-Z]'`${ProductBrand:1}
Device=`echo ${Device:0:1} | tr  '[a-z]' '[A-Z]'`${Device:1}
ProductBrand=${ProductBrand:0:6}
ProductBrand=${ProductBrand/ /}
Model=${Model:0:7}
Model=${Model/ /}
echo  "$ProductBrand - $Model is connected..."
PromptUser
}

#Tells user that the script will start logging.
PromptUser(){
while true; do
	echo
    read -p "Do you wish to filter by Tag? " yn
    case $yn in
        [Yy]* ) echo "Yes"; StartLoggingTagCustom; break;;
        [Nn]* ) echo "No"; StartLoggingNoTag; break;;
        * ) echo "Please answer yes or no.";;
    esac
done	
}

#Creates neccesarry folders.
CreateFolder(){
	if [ ! -d ~/Documents/Android ]; then
  # Control will enter here if $DIRECTORY doesn't exist.+
  mkdir ~/Documents/Android
fi
	if [ ! -d ~/Documents/Android/Logs$DATE ]; then
  # Control will enter here if $DIRECTORY doesn't exist.+
  mkdir ~/Documents/Android/Logs$DATE
fi
}

StartLoggingNoTag(){

	CreateFolder
	sleep 1
	{
		adb logcat > ~/Documents/Android/Logs"$DATE"/"$now"_"$Model"_Logs.txt 
	echo
	echo "Device is disconnected...exiting logging."
	kill $(ps aux | grep 'tail -f')
	sleep 1
	}&
	sleep 2
	clear
	ScriptTopper
	tail -f  ~/Documents/Android/Logs"$DATE"/"$now"_"$Model"_Logs.txt
	echo "Restarting..."

}

#Multithreading function that starts logging and then reading the file while grepping for users input.
StartLoggingTagCustom(){
	CreateFolder
	sleep 1
	echo "Please enter the string to filter logs by. "
	read UserInput
	while true; do
	echo
    read -p "Log's will be filtered by '$UserInput' is this correct?" yn
    case $yn in
        [Yy]* ) echo "Yes"; break;;
        [Nn]* ) echo "No"; StartLoggingTagCustom;;
        * ) echo "Please answer yes or no.";;
    esac
done	
	{
		adb logcat > ~/Documents/Android/Logs"$DATE"/"$now"_"$Model"_Logs.txt
	echo
	echo "Device is disconnected...exiting logging."
	sleep 1
	kill $(ps aux | grep 'tail -f')
	}&
	sleep 2
	clear
	ScriptTopper
	tail -f ~/Documents/Android/Logs"$DATE"/"$now"_"$Model"_Logs.txt | grep $UserInput

}

option = "null"
until [ $option = $return ]; do
	clear;
	echo "1) Enter text script "
	echo "2) Close and clear script "
	echo "3) Install Application "
	echo "4) Uninstall Application "
	echo "5) Insert gmail "
	echo "6) Insert wifi password "
	echo "7) adb "
	echo "8) Start logging to file"
	echo "Please choose an option "
	read option
	# Case statement to determine which function to run
	case $option in
		1) enter_text;;
		2) close_and_clear;;
		3) install;;
		4) uninstall;;
		5) insert_gmail;;
		6) insert_wifi;;
		7) adb_command;;
		8) StartUp;;
	esac
done
