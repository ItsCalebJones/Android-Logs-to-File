!/bin/bash

############################### WELCOME ########################################
# Startup Script to let the user know what the function does.
ScriptTopper() {
clear
echo "=========================================================================="
echo "/                                                                        \""
echo "/                                Welcome!                                \""
echo "/                                                                        \""
echo "/                                                                        \""
echo "/ NOTES:                                                                 \""
echo "/ * Make sure device is connected and on debug (type adb devices in term)\""
echo "/ * If script fails, press CTRL+C to stop it and restart.                \""
echo "/ * By default all logs are saved to a Documents/Android folder.         \""
echo "/ * Please keept comments and suggestions to yourself for now.           \""
echo "/                                                                        \""
echo "=========================================================================="
echo
echo
}

############################ START-UP ##########################################

#Checks for device and loops until its found.
StartUp(){
echo
read -p "Press [Enter] key when device is connected via USB..."
echo
CheckForDevice
}

############################## DEVICE CHECK ####################################

CheckForDevice(){
echo Checking for device...
echo

CreateFolder
sleep 1
ADBDevices=$(adb devices)
echo $ADBDevices > ~/Documents/Android/tmp

Condition
}

################################################################################

#Logic for determining if device is connected by reading output of ADB Devices
Condition(){
#HISTORICAL COMMENT: This is a messy way of finding out if there is a device connected. The problem was with locating a Android ID in a returned 'ADB Devices' string.
#HISTORICAL COMMENT: This looks for numbers, if theres a number in the string then there is a Device connected, possible to have bugs here where theres a Device ID without a 0, 2, or 3.
#CODE HISTORICAL COMMENTS WAS REFERENCING HAS BEEN REMOVED FOR READER'S SANITY
#Compares file size of tmp to see if it contains any devices. If so, run. Else, prompt user.

filesize=$(stat -f%z ~/Documents/Android/tmp)
#echo $filesize #DEBUG COMMAND

if [[ $filesize > 25 ]]; then
GetDeviceData
#If device is found move on to the next step.

else

#Loops back to the top.
read -p "No devices detected, make sure USB Debugging is turned on. Press Enter to try again..."
sleep 1
CheckForDevice

fi
}

################################################################################

#Fetches device details and logs them into variables.
#TO DO change the awk to actually edit the variable.
GetDeviceData(){
ProductBrand=$(adb shell getprop ro.product.brand)
Provider=$(adb shell getprop gsm.operator.alpha)
Device=$(adb shell getprop ro.product.device)
Model=$(adb shell getprop ro.product.model)
ProductModel=$ProductBrand}" "${Model}
#TestS= $Provider$Device
#ProductBrand=`echo ${ProductBrand:0:1} | tr  '[a-z]' '[A-Z]'`${ProductBrand:1}
#Device=`echo ${Device:0:1} | tr  '[a-z]' '[A-Z]'`${Device:1}
#ProductBrand=${ProductBrand:0:${#ProductBrand}-1}
#ProductBrand=${ProductBrand/ /}
#Model=${Model:0:${#Model}-1}
#Model=${Model/ /}
echo  "$ProductBrand - $Model is connected..."
# echo $ProductBrand
# echo $Provider
# echo $Device
echo $Model$Device
echo $ProductModel
#echo $TestS
#echo $Model

#[ro.build.version.release]: [4.4.2]
#[ro.com.google.clientidbase.am]: [android-tmobile-us]
#[gsm.operator.alpha]: [T-Mobile]
}

################################################################################

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

################################################################################

ScriptTopper #Welcome Dialog
StartUp #S
