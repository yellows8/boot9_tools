#!/bin/bash

# This crypts the OTP, and calculates the hash when decrypting.
# Usage: boot9_crypt_otp.sh <boot9 binary file, based at 0xffff8000> <input data filepath> <output data filepath> [decrypt|encrypt] [retail|dev] {optional path to write the output data offset 0x90 size 0x70 to(used for console-unique keys-generation)}

if [ $# -lt 5 ]
then
	echo "5 params are required, see usage in the script source."
	exit 1
fi

BOOT9_FILEPATH=$1
INDATA_FILEPATH=$2
OUTDATA_FILEPATH=$3
CRYPT_TYPE=$4
UNIT_TYPE=$5

KEYDATA_POS=0
CRYPT_PARAM=

if [ $CRYPT_TYPE == "decrypt" ]
then
	CRYPT_PARAM=-d
elif [ $CRYPT_TYPE == "encrypt" ]
then
	CRYPT_PARAM=-e
else
	echo "Invalid crypt-type."
	exit 2
fi

if [ $UNIT_TYPE == "retail" ]
then
	KEYDATA_POS=22240
elif [ $UNIT_TYPE == "dev" ]
then
	KEYDATA_POS=22272
else
	echo "Invalid unit-type."
	exit 3
fi

AESIV_POS=$((KEYDATA_POS+16))

openssl enc -aes-128-cbc $CRYPT_PARAM -in $INDATA_FILEPATH -out $OUTDATA_FILEPATH -K `xxd -p -l 16 -s $KEYDATA_POS $BOOT9_FILEPATH` -iv `xxd -p -l 16 -s $AESIV_POS $BOOT9_FILEPATH` -nopad
echo "Output data:"
xxd $OUTDATA_FILEPATH

if [ $CRYPT_TYPE == "decrypt" ]
then
	echo "Calculated hash:"
	xxd -l 224 -p $OUTDATA_FILEPATH | xxd -r -p | openssl sha -sha256
fi

if [ $# -ge 6 ]
then
	xxd -s 144 -l 112 -p $OUTDATA_FILEPATH | xxd -r -p > $6
	echo "Wrote the console-unique key-generation area to the specified path."
fi

