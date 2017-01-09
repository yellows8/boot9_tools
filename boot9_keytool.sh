#!/bin/bash

# This extracts AES keys from the specified boot9 image.
# Usage: boot9_keytool.sh <binary file> <decimal offset in the file for the very start of the keyarea>

FILEPATH=$1
START_POS=$2

function printkey
{
	echo -n "0x$1 $2="
	xxd -p -l 16 -s $START_POS $FILEPATH
}

function printkeyloop
{
	keyslot=$1
	for i in `seq 0 3`;
	do
		printkey $keyslot $2
		keynum=`echo -e "ibase=16\n$keyslot" | bc | tr -d '\n'`
		keynum=$((keynum+1))
		keyslot=`printf '%X' $keynum`
	done
}

function printkeyloop_groupedincrease
{
	keyslot=$1
	for i in `seq 0 3`;
	do
		printkey $keyslot $2
		keynum=`echo -e "ibase=16\n$keyslot" | bc | tr -d '\n'`
		keynum=$((keynum+1))
		keyslot=`printf '%X' $keynum`
		START_POS=$((START_POS+16))
	done
}

# Skip over the data which is copied as part of the generation for the keyslot 0x3f keydata(which is then used for generating the console-unique AES keys).
START_POS=$((START_POS+36))

# Skip over the AESIV for CONUNIQUE_CODEBLOCK block0.
START_POS=$((START_POS+16))
# Skip over the 0x40-bytes which are encrypted with the AES engine for CONUNIQUE_CODEBLOCK block0.
START_POS=$((START_POS+64))
# Skip over the data which is copied(CONUNIQUE_CODEBLOCK block0).
START_POS=$((START_POS+36))

# Skip over the AESIV for CONUNIQUE_CODEBLOCK block1.
START_POS=$((START_POS+16))
# Skip to the location where the bootrom_dataptr would be, after the 0x40-byte encryption is done(CONUNIQUE_CODEBLOCK block1).
START_POS=$((START_POS+16))
# Skip over the data which is copied(CONUNIQUE_CODEBLOCK block1).
START_POS=$((START_POS+36))

# Skip over the AESIV for CONUNIQUE_CODEBLOCK block2.
START_POS=$((START_POS+16))
# Skip over the 0x40-bytes which are encrypted with the AES engine for CONUNIQUE_CODEBLOCK block2.
START_POS=$((START_POS+64))
# Skip over the data which is copied(CONUNIQUE_CODEBLOCK block2).
START_POS=$((START_POS+36))

# Skip over the AESIV for CONUNIQUE_CODEBLOCK block3.
START_POS=$((START_POS+16))
# Skip to the location where the below keys begin(CONUNIQUE_CODEBLOCK block3).
START_POS=$((START_POS+16))

printkeyloop 2C "keyX"
START_POS=$((START_POS+16))

printkeyloop 30 "keyX"
START_POS=$((START_POS+16))

printkeyloop 34 "keyX"
START_POS=$((START_POS+16))

printkeyloop 38 "keyX"
START_POS=$((START_POS+16))

printkeyloop_groupedincrease 3C "keyX"

printkeyloop_groupedincrease 4 "keyY"
printkeyloop_groupedincrease 8 "keyY"

printkeyloop C "normalkey"
START_POS=$((START_POS+16))

printkeyloop 10 "normalkey"
START_POS=$((START_POS+16))

printkeyloop_groupedincrease 14 "normalkey"

printkeyloop 18 "normalkey"
START_POS=$((START_POS+16))

printkeyloop 1C "normalkey"
START_POS=$((START_POS+16))

printkeyloop 20 "normalkey"
START_POS=$((START_POS+16))

printkeyloop 24 "normalkey"

printkeyloop_groupedincrease 28 "normalkey"

printkeyloop 2C "normalkey"
START_POS=$((START_POS+16))

printkeyloop 30 "normalkey"
START_POS=$((START_POS+16))

printkeyloop 34 "normalkey"
START_POS=$((START_POS+16))

printkeyloop 38 "normalkey"

printkey 3C "normalkey"
START_POS=$((START_POS+16))

printkey 3D "normalkey"
START_POS=$((START_POS+16))

printkey 3E "normalkey"
START_POS=$((START_POS+16))

printkey 3F "normalkey"

