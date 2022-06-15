w32tm /config /manualpeerlist:"toc.bollers.dk,0x8 jason.bollers.dk,0x8, square.bollers.dk,0x8" /syncfromflags:MANUAL /reliable:yes
w32tm /config /update
w32tm /query /peers