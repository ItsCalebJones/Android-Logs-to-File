#Fetches device details and logs them into variables.
#TO DO change the awk to actually edit the variable.

Provider=$(adb shell getprop gsm.operator.alpha)
Model=$(adb shell getprop ro.product.model)
c=$Provider$Model
echo $c


echo
a='hello '
b='world'
c=$a$b
echo $c
