#!/bin/bash

# This generates the console-unique keys done by boot9.
# Usage: boot9_aeskeytool_conunique.sh <boot9 binary file> <decimal offset in the file for the very start of the keyarea> <binary file containing the console-unique data used during Boot9 keyinit> <crypto command, tool path + params if any>

set -e

if [ $# -lt 4 ]
then
	echo "4 params are required, see usage in the script source."
	exit 1
fi

FILEPATH=$1
BOOT9_POS=$2
OTP_FILEPATH=$3
CRYPTOCMD=$4
OTP_POS=0

CRYPT_OUTFILE=aeskeytool_conunique_tmp_output
CRYPT_OUTPOS=0

function printkey
{
	echo -n "0x$1 $2="
	xxd -p -l 16 -s $CRYPT_OUTPOS $CRYPT_OUTFILE
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
		CRYPT_OUTPOS=$((CRYPT_OUTPOS+16))
	done
}

function generate_keys
{
	# Set the pos to the data following the data used for calculating the previous hash(keyslot 0x3f generation / CONUNIQUE_CODEBLOCK blockX), with boot9 data + OTP. The output hash for CONUNIQUE_CODEBLOCK blockX isn't used by boot9 at all, so no need to calculate it.
	BOOT9_POS=$((BOOT9_POS+36))

	# Get the AESIV for CONUNIQUE_CODEBLOCK blockX.
	AESIV=`xxd -p -l 16 -s $BOOT9_POS $FILEPATH`
	BOOT9_POS=$((BOOT9_POS+16))
	# Get the 0x40-bytes which are encrypted with the AES engine for CONUNIQUE_CODEBLOCK blockX.
	xxd -p -l 64 -s $BOOT9_POS $FILEPATH | xxd -r -p > aeskeytool_conunique_tmp_input

	# In some cases the pos is increased by 0x10 instead of the above crypt size.
	BOOT9_POS=$((BOOT9_POS+$1))

	$CRYPTOCMD --aescbcencrypt --keyX=$keyX --keyY=$keyY --iv=$AESIV --indata=@aeskeytool_conunique_tmp_input --outpath=$CRYPT_OUTFILE > aeskeytool_conunique_tmp
	CRYPT_OUTPOS=0
}

xxd -p -s $OTP_POS -l 28 $OTP_FILEPATH | xxd -r -p > aeskeytool_conunique_tmp
xxd -p -s $BOOT9_POS -l 36 $FILEPATH | xxd -r -p >> aeskeytool_conunique_tmp

HASH=`openssl sha -sha256 aeskeytool_conunique_tmp | cut -f 2 -d " "`
rm aeskeytool_conunique_tmp
keyX=`echo -n $HASH | cut -b -32`
keyY=`echo -n $HASH | cut -b 33-`
echo "# Console-unique keyslot 0x3f(for console-unique key-generation) keyX: $keyX"
echo "# Console-unique keyslot 0x3f(for console-unique key-generation) keyY: $keyY"

generate_keys 64

printkeyloop 4 "keyX"
CRYPT_OUTPOS=$((CRYPT_OUTPOS+16))
printkeyloop 8 "keyX"
CRYPT_OUTPOS=$((CRYPT_OUTPOS+16))
printkeyloop C "keyX"
CRYPT_OUTPOS=$((CRYPT_OUTPOS+16))
printkey 10 "keyX"

generate_keys 16

printkeyloop_groupedincrease 14 "keyX"

generate_keys 64

printkeyloop 18 "keyX"
CRYPT_OUTPOS=$((CRYPT_OUTPOS+16))
printkeyloop 1C "keyX"
CRYPT_OUTPOS=$((CRYPT_OUTPOS+16))
printkeyloop 20 "keyX"
CRYPT_OUTPOS=$((CRYPT_OUTPOS+16))
printkey 24 "keyX"

generate_keys 16

printkeyloop_groupedincrease 28 "keyX"

rm aeskeytool_conunique_tmp
rm aeskeytool_conunique_tmp_input
rm $CRYPT_OUTFILE

