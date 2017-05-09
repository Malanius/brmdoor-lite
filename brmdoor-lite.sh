#!/bin/bash
WD=$(dirname $(readlink -f $0))
if [ -e $WD/brmdoor.conf ]; then
	echo "Loading config file $WD/brmdoor.conf..."
	. $WD/brmdoor.conf
else
	echo "ERROR: Config file not found. Please create brmdoor.conf in the same directory as brmdoor-lite.sh."
	exit 1
fi

# Exports GPIO pins according to config
prepare_gpio() {
	log_message "Preparing GPIO pins..."
	for i in $GPIO_LOCK $GPIO_LED_OK $GPIO_LED_KO; do
		log_message "Exporting pin: ${i}"
		echo $i > /sys/class/gpio/export
		log_message "Setting 'out' for pin: ${i}"
		echo "out" > /sys/class/gpio/gpio${i}/direction
	done
	echo 1 > /sys/class/gpio/gpio${GPIO_LOCK}/value
	log_message "GPIO prepared."
}

# Unexporst the GPIO pins
clean_gpio() {
	log_message "End of script trapped. Unexporting pins..."
	for i in $GPIO_LOCK $GPIO_LED_OK $GPIO_LED_KO; do
		log_message "Setting 'in' for pin: ${i}"
		echo in > /sys/class/gpio/gpio${i}/direction
		log_message "Unexporting pin: ${i}"
		echo $i > /sys/class/gpio/unexport
	done
	log_message "Door script ended."
}

log_message() {
	echo "`date "+%Y-%m-%d %T"` $1" | tee -a $LOG_PATH
}

 trap clean_gpio EXIT

log_message "Door script started..."

prepare_gpio

sleep 1 # do not remove unless running as root... few ms after exporting the GPIO the file is owned by root:root

LOOP=0

while true; do
	log_message "Awaiting card..."
	read CARD
	if [ -n "$CARD" ]; then # we have a card
		NAME=`grep -i "^${CARD};[0-9a-zA-Z_-]*" "$ALLOWED_LIST"| cut -d ';' -f 2`
		if [ -z "$NAME" ]; then
			log_message "UNKNOWN_CARD $CARD"
			echo 1 > /sys/class/gpio/gpio${GPIO_LED_KO}/value
			sleep $LOCK_TIMEOUT
			echo 0 > /sys/class/gpio/gpio${GPIO_LED_KO}/value
		else
			log_message "DOOR_UNLOCKED $NAME $CARD"
			echo UNLOCKED > /sys/class/gpio/gpio${GPIO_LOCK}/value
			echo 1 > /sys/class/gpio/gpio${GPIO_LED_OK}/value
			sleep $LOCK_TIMEOUT
			echo LOCKED > /sys/class/gpio/gpio${GPIO_LOCK}/value
			echo 0 > /sys/class/gpio/gpio${GPIO_LED_OK}/value
			log_message "DOOR_LOCKED"
		fi
	fi

	let LOOP=$LOOP+1
	sleep 1
done
