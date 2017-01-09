These are scripts for use with the binary for protected_boot9, for Nintendo 3DS. These are originally from 2015.

* boot9_keytool.sh: Extract the non-console-unique AES keys.
* boot9_aeskeytool_conunique.sh: Same as above except for the console-unique AES keys. Requires the plaintext OTP(see here: https://www.3dbrew.org/wiki/OTP_Registers). Requires "ctr-cryptotool" for the last param(other tool(s) could be used as well).
* boot9_crypt_otp.sh: Decrypt/encrypt the OTP.

The stdout from the first two tools can be used with the AES keys config used by [ctr-cryptotool](https://github.com/yellows8/3dscrypto-tools). These two tools also require the the decimal offset in the input boot9 file for the keyarea. Relative to 0xffff8000 this is: retail = 22624(offset 0x5860 / addr 0xffffd860), devunit = 23648 (offset 0x5c60 / addr 0xffffdc60).

