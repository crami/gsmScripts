#!/bin/sh

gsm-ussd -m /dev/ttyUSB2 -t 30 -p 0703 --no-cleartext "*130#"
