#Fetches device details and logs them into variables.
#TO DO change the awk to actually edit the variable.
ProductBrand=$(adb shell getprop ro.product.brand)
Provider=$(adb shell getprop gsm.operator.alpha)
Device=$(adb shell getprop ro.product.device)
Model=$(adb shell getprop ro.product.model)
clear
empty=' '
c=$Provider$Model
echo $c
echo
echo $ProductBrand
echo $Model 
echo $Provider

echo
a='hello'
b='world'
c=$a$b
echo $c
