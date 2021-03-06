#!/bin/bash
# $HOME/.config/i3/status.sh
# ------------------------------------------------------
# Dzen settings & Variables
# -------------------------
SLEEP=2
ICONPATH="$HOME/.i3/icons/stlarch_icons"
COLOR_ICON="#BA2020"
CRIT_COLOR="#ff2c4a"
DZEN_FG="#A0A0A0"
DZEN_BG="#252525"
HEIGHT=16
WIDTH=1100
X=760
Y=150
BAR_FG="#BA2020"
BAR_BG="#808080"
BAR_H=7
BAR_W=40
FONT="-*-terminus-medium-r-*-*-12-*-*-*-*-*-iso10646-*"
VUP="amixer -c0 -q set Master 2dB+"
VDOWN="amixer -c0 -q set Master 2dB-"
EVENT="button3=exit;button1=exec:$VUP;button2=exec:$VDOWN;"
DZEN="dzen2 -u -x $X -y $Y -w $WIDTH -h $HEIGHT -fn $FONT -ta right -bg $DZEN_BG -fg $DZEN_FG -e 'onstart=lower'"
NUMCPUS=$(grep ^proc /proc/cpuinfo | wc -l)

# -------------
# Infinite loop
# -------------
while :; do
sleep ${SLEEP}

# ---------
# Functions
# ---------
Vol ()
{
	VOL=$(amixer get Master | egrep -o "[0-9]+%" | tr -d '%')
	echo -n "^fg($COLOR_ICON)^i($ICONPATH/vol1.xbm)^fg()" $(echo $VOL | gdbar -fg $BAR_FG -bg $BAR_BG -h $BAR_H -w 2 -s v -nonl)
	return
}

Mem ()
{
	#MEM=$(free -m | grep '-' | awk '{print $3}')
    MEM=$(free -m | awk '/Mem:/ { print $3 }')
	echo -n "^fg($COLOR_ICON)^i($ICONPATH/mem1.xbm)^fg() ${MEM} MB"
	return
}

Cpu ()
{
    #CPU=$(mpstat | grep -A 5 "%idle" | tail -n 1 | awk -F " " '{print 100 -  $ 12}'a)
    FIRST=`cat /proc/stat | awk '/^cpu / {print $5}'`; 
    sleep 1; 
    SECOND=`cat /proc/stat | awk '/^cpu / {print $5}'`; 
    CPU=$(echo 2 k 100 $SECOND $FIRST - $NUMCPUS / - p | dc)
    echo -n "^fg($COLOR_ICON)^i($ICONPATH/cpu1.xbm)^fg() ${CPU}%"
    return
}

Temp ()
{
	#TEMP=$(acpi -t | awk '{print $4}' | tr -d '.0')
    #TEMP=$(acpi -t | awk '/Thermal 1:/ {print $4}')
    TEMP=$(sensors | awk '/Physical id 0:/ {print $4}' | sed "s/+//g")
		if [[ $(echo $TEMP | sed "s/\..*//") -gt 63 ]]; then
			echo -n "^fg($CRIT_COLOR)^i($ICONPATH/temp1.xbm)^fg($CRIT_COLOR) ${TEMP}" $(echo ${TEMP} | gdbar -fg $CRIT_COLOR -bg $BAR_BG -h $BAR_H -s v -sw 5 -ss 0 -sh 1 -nonl)
		else 
			echo -n "^fg($COLOR_ICON)^i($ICONPATH/temp1.xbm)^fg() ${TEMP}" $(echo ${TEMP} | gdbar -fg $BAR_FG -bg $BAR_BG -h $BAR_H -s v -sw 5 -ss 0 -sh 1 -nonl)
		fi
	return
}

Disk ()
{
	SDA2=$(df -h / | awk '/\/$/ {print $5}' | tr -d '%')
	SDB1=$(df -h /home | awk '/home/ {print $5}' | tr -d '%')
	if [[ ${SDA2} -gt 60 ]] ; then
		echo -n "^fg($COLOR_ICON)^i($ICONPATH/file1.xbm)^fg() $(echo $SDA2 | gdbar -fg $CRIT_COLOR -bg $BAR_BG -h $BAR_H -w $BAR_W -s o -sw 2 -nonl)"
	else
		echo -n "^fg($COLOR_ICON)^i($ICONPATH/file1.xbm)^fg() $(echo $SDA2 | gdbar -fg $BAR_FG -bg $BAR_BG -h $BAR_H -w $BAR_W -s o -sw 2 -nonl)"
	fi
	if [[ ${SDB1} -gt 80 ]] ; then
		echo -n " ^fg($COLOR_ICON)^i($ICONPATH/home1.xbm)^fg() $(echo $SDB1 | gdbar -fg $CRIT_COLOR -bg $BAR_BG -h $BAR_H -w $BAR_W -s o -sw 2 -nonl)"
	else
		echo -n " ^fg($COLOR_ICON)^i($ICONPATH/home1.xbm)^fg() $(echo $SDB1 | gdbar -fg $BAR_FG -bg $BAR_BG -h $BAR_H -w $BAR_W -s o -sw 2 -nonl)"
	fi
	return
}

MPD ()
{
	MPDPLAYING=$(mpc | grep -c "playing")
	MPDPAUSED=$(mpc | grep -c "paused")
	MPDINFO=$(mpc | grep -v 'volume:' | head -n1)
	MPDTIME=$(mpc | awk '/\%/ {print $4}' | tr -d "()%")
	if [ $MPDPLAYING -eq 1 ] ; then
		echo -n "^fg($COLOR_ICON)^i($ICONPATH/note1.xbm)^fg() [playing] $(echo $MPDTIME | gdbar -fg $BAR_FG -bg $BAR_BG -h $BAR_H -w $BAR_W -s o -sw 2 -ss 1 -nonl)"
	else
		if [ $MPDPAUSED -eq 1 ] ; then
			echo -n "^fg($COLOR_ICON)^i($ICONPATH/note1.xbm)^fg() [paused] $(echo $MPDTIME | gdbar -fg $BAR_FG -bg $BAR_BG -h $BAR_H -w $BAR_W -s o -sw 2 -ss 1 -nonl)"
		else
			echo -n "^fg($COLOR_ICON)^i($ICONPATH/note1.xbm)^fg() [stopped] $(echo $MPDTIME | gdbar -fg $BAR_FG -bg $BAR_BG -h $BAR_H -w $BAR_W -s o -sw 2 -ss 1 -nonl)"
		fi
	fi

	return
}

Kernel ()
{
	KERNEL=$(uname -a | awk '{print $3}')
	echo -n "Kernel: $KERNEL"
	return
}

Battery ()
{
    CURRENT=$(acpi | awk {'print $3'} | sed 's/\,//g')
    FULL=$(acpi | awk {'print $4'})
    BATT=$(echo "$CURRENT: $FULL")
    echo -n "^fg($COLOR_ICON)^i($ICONPATH/batt1full.xbm)^fg() ${BATT}"
    return
}

Bitcoin ()
{
    PRICE=$($HOME/.i3/btcprices.py price)
    echo -n "${PRICE}"
    return
}

Date ()
{
	TIME=$(date +%H:%M)
		echo -n "^fg($COLOR_ICON)^i($ICONPATH/clock1.xbm)^fg(#a0a0a0) ${TIME}"
	return
}

Between ()
{
    echo -n " ^fg(#A0A0A0)^r(2x2)^fg() "
	return
}

OSLogo ()
{
	echo -n " ^fg($COLOR_ICON)^i($ICONPATH/arch1.xbm)^fg() "
	return
}
# --------- End Of Functions

# -----
# Print 
# -----
Print () {
	OSLogo
    Bitcoin
    Between
    Battery
	#Kernel
	Between
	MPD
	Between
	Temp
	Between
    Cpu
    Between
    Mem
    Between
    Disk
    #Between
    #Vol
    Between
    Date
    echo
    return
}

echo "$(Print)" 
#done
done | $DZEN &
