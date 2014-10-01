######################### GLOBAL VARIABLES #####################################

DATE=`date +%m_%d_%y`
now=$(date +"%H-%M-%S")
filesize=0

############################### WELCOME ########################################
# Startup Script to let the user know what the function does.
ScriptTopperC(){
	clear
	ScriptTopper
}

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
echo "/ * Please keept comments and suggestions to yourself for now.           \""
echo "/                                                                        \""
echo "=========================================================================="
echo
echo
}

############################ START-UP ##########################################

#Checks for device and loops until its found.
StartUp(){
ScriptTopper
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

#Logic for determining if device is connected by reading output of adb Devices
Condition(){
#HISTORICAL COMMENT: This is a messy way of finding out if there is a device connected. The problem was with locating a Android ID in a returned 'adb Devices' string.
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
GetDeviceData(){

#This gets information about the device
ProductBrand=$(adb shell getprop ro.product.brand | tr -d \\r)
Provider=$(adb shell getprop gsm.operator.alpha | tr -d \\r)
Model=$(adb shell getprop ro.product.model | tr -d \\r)
OSVersion=$(adb shell getprop ro.build.version.release | tr -d \\r)
InstalledAPKs=$(adb shell pm list packages)

#This edits the strings to make is more readable
ProductBrand="$(tr '[:lower:]' '[:upper:]' <<< ${ProductBrand:0:1})${ProductBrand:1}"
Device="$(tr '[:lower:]' '[:upper:]' <<< ${Device:0:1})${Device:1}"
Model="$(tr '[:lower:]' '[:upper:]' <<< ${Model:0:1})${Model:1}"


pM="$Provider - $ProductBrand $Model v$OSVersion"
echo $pM "is connected."
echo
sleep .5
read -p "Please press enter to continue to menu."
Menu
}

################################################################################

#Creates neccesarry folders.
CreateFolder(){
if [ ! -d ~/Documents/Android ]; then
# Control will enter here if $DIRECTORY doesn't exist.+
mkdir ~/Documents/Android
fi
if [ ! -d ~/Documents/Android/Logs_$DATE ]; then
# Control will enter here if $DIRECTORY doesn't exist.+
mkdir ~/Documents/Android/Logs_$DATE
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

LoggingNoTag(){
	read -p "Logging is about to start. Press enter to continue: "
	clear

	sleep 1
	{
		echo $pM > ~/Documents/Android/Logs_"$DATE"/"$now"_"$Model"_Logs.txt
		echo " " >> ~/Documents/Android/Logs_"$DATE"/"$now"_"$Model"_Logs.txt
		echo "Installed Apps:" >> ~/Documents/Android/Logs_"$DATE"/"$now"_"$Model"_Logs.txt
		echo $InstalledAPKs | tr -d ' ' >> ~/Documents/Android/Logs_"$DATE"/"$now"_"$Model"_Logs.txt
		echo " " >> ~/Documents/Android/Logs_"$DATE"/"$now"_"$Model"_Logs.txt

		sleep 1
		adb logcat >> ~/Documents/Android/Logs_"$DATE"/"$now"_"$Model"_Logs.txt 
		kill $(ps aux | grep 'tail -f')
	}&

		sleep 3
	
		clear
	
		tail -f  ~/Documents/Android/Logs_"$DATE"/"$now"_"$Model"_Logs.txt
		clear
		echo "ERROR: Device was disconnected. Restarting. Please wait.."
		echo
		echo
		sleep 1
		StartUp
	}

################################################################################

#Multithreading function that starts logging and then reading the file while grepping for users input.
LoggingWithTag(){
	sleep 1
	echo "Please enter the string tag to filter logs by. "
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
	read -p "Please press enter to continue: "
	clear
	{
		echo $pM > ~/Documents/Android/Logs_"$DATE"/"$now"_"$Model"_Logs.txt
		echo " " >> ~/Documents/Android/Logs_"$DATE"/"$now"_"$Model"_Logs.txt
		echo $InstalledAPKs | tr -d ' ' >> ~/Documents/Android/Logs_"$DATE"/"$now"_"$Model"_Logs.txt
		echo " " >> ~/Documents/Android/Logs_"$DATE"/"$now"_"$Model"_Logs.txt
		adb logcat > ~/Documents/Android/Logs_"$DATE"/"$now"_"$Model"_Logs.txt
	echo
	echo "Device is disconnected..."
	kill $(ps aux | grep 'tail -f')
	}&
	sleep 2
	clear
	tail -f ~/Documents/Android/Logs_"$DATE"/"$now"_"$Model"_Logs.txt | grep $UserInput
		clear
		echo "ERROR: Device was disconnected. Restarting. Please wait.."
		echo
		echo
		sleep 1
		StartUp
}

################################################################################

adbCommandFM(){
	#Clears screen when called from Menu then calls adbCommand
		clear
		adbCommand
}

adbCommand(){
	#Actual adb command function

	command=""

	#sleepCounter is a random number between .1 and .9 - This is just for fun.
	sleepCounter=$[1 + ($[RANDOM%9])]
	sleepCounter=0.$sleepCounter
	echo "Please enter adb command without adb prefix. Enter 'back' to go back to menu."
	read command
	echo
	#Fluff to account for randomized sleep interval.
    echo "Processing command. Please wait.."

    #Without this command, statement loops back to Menu. You can replace sleepCounter with 0
	sleep $sleepCounter

	if [ $command = "back" ]; then
		Menu
	fi

	adb $command

	adbCommand
}

Menu(){
 	option="null"

 	until [ $option = $return ]; do
 		clear;
 		ScriptTopper
 		echo "1) Start Logging(No Tag) "
		echo "2) Start Logging(With Tag) "
		echo "3) adb Commands"
		#echo "4) Uninstall Application"
 		read -p "Please choose an option: " option

 		# Case statement to determine which function to run

 		case $option in
 			1) LoggingNoTag;;
            2) LoggingWithTag;;
			3) adbCommandFM;;
 		esac
 	done
}

#ScriptTopper #Welcome Dialog
clear
StartUp #Verifies Device is connected
Menu
