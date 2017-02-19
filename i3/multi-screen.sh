set -x
# melchior
MON1="DisplayPort-0"
MON2="DVI-1"

xrandr | grep ${MON2} | grep " connected "
connected=$?
if [ $connected ]; then
    xrandr --output ${MON1} --auto --output ${MON2} --auto --right-of ${MON1}
else
    xrandr --output ${MON1} --auto --output ${MON2} --off
fi

