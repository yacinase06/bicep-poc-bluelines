#!/bin/sh
len=$1
secretVal=$(</dev/urandom tr -dc 'a-zA-Z0-9/#@!~$%^&*' | fold -w $len | awk '{c=0} /[a-z]/{c++} /[A-Z]/{c++} /[0-9]/{c++} /[#@!~$%^&*]/{c++} {if (c >= 4){print;exit}}')
json="{\"SecretVal\":\"$secretName$secretVal\"}"
echo "$json" > $AZ_SCRIPTS_OUTPUT_PATH
