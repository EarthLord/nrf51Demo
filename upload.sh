#!/bin/bash

rm -rf build/upload.jlink
echo -e "device nrf51822\nspeed 1000\nw4 4001e504 1\nloadbin $(pwd)/build/main.bin 0\nr\ng\nqc\n" > build/upload.jlink
/opt/SEGGER/JLink/JLinkExe build/upload.jlink
