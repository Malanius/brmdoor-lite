# brmdoor lite

## Description
Forked from [brmdoor/brmlab](https://github.com/brmlab/brmdoor)

This implementation of brmdoor is aimed for ofline use on RaspberryPi 1 (newer can be used too). All online features (IRC and hackerspace status reporting removed).

## Features
- Acces cards managed by master cards
- Configurable GPIO pins
- Event logging

## Requirements
- RaspberryPi
- Keyboard card reader
- Electric door lock
- Circuit to control the lock (use galvanicly separated circuit to protect the RPi), we used this [2 relay modude](https://www.amazon.com/SainSmart-101-70-100-2-Channel-Relay-Module/dp/B0057OC6D8)
- Cards for access

## Configuration
Configuration is located in **brmdoor.conf** file. You can set:
- GPIO pins - locks, aditional LEDs pins
- Lock timeout - how long the lock should stay open on authorised card
- path to list of allowed cards
- path to list of master cards
- path to the log file (use /dev/null to disable logging)

## Cards list
Both cards list are in this format:
{CARD_ID};{SOME_NAME}
*Do not use spaces, so names are not truncated from the log.*

### masters.list
Contains cards that are allowed to add or remove cards from allowed.list.
**Master cards can't unlock the door!**

### allowed.list
Contains cards that are allowed to open the door.
