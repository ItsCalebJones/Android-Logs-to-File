#Fetches device details and logs them into variables.
#TO DO change the awk to actually edit the variable.
ProductBrand=$(adb shell getprop ro.product.brand)
Provider=$(adb shell getprop gsm.operator.alpha)
Device=$(adb shell getprop ro.product.device)
Model=$(adb shell getprop ro.product.model)


echo "$ProductBrand $Model $Device $Provider"
echo "$ProductBrand $Model $Device" 
echo "$ProductBrand $Model" 
echo "$ProductBrand" 


var1="Here is"
var2="some text"
var3="for you."

echo $var1 $var2 $var3