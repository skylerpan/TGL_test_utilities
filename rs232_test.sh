#!/bin/bash
sudo ./linux-serial-test -s -e -p /dev/ttyS0 -b 115200 -o 50 -i 60 && echo "===== RS232 test Success! =====" || echo "===== RS232 test Fail! ====="
