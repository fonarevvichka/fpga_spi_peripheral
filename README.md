# fpga_spi_peripheral

Basic SPI setup for communication between an arduino and a FPGA on a breakout board.
This particular demo was set up using an ESP32 and Upduino V3 FPGA.
In this demo the ESP32 acts as the contorller and the FPGA is the peripheral.
The controller sends 16 bytes to the FGPA which stores everything in a 128 bit shift
register. Once all 16 bytes have been sent the ESP32 loops and waits for a signal that indicates
that data is ready to be sent. The FPGA has a state machine that keeps track of how much
data has been recieved. Once it reieves all the data, and proccess it in any way neccessary (nothing
for now) it sends the singal and the controller triggers another 16 SPI cycles and the FPGA sends
back 16 bytes (in this demo the bytes are the same as the ones that were sent).

### Clock Speeds:
    This should work at many clock speeds as there are no complex timing issues
    and crossing the clock domain is handled by a synchronoizer. However, this
    example was most tested with the FPGA running @ 48Mhz using the internal
    oscilator and the SPI clock was set to 10MHz.
### Sample Communication Cycle
(Taken from serial monitor)

Sending Byte: 1 Response Byte: 255
Sending Byte: 2 Response Byte: 255
Sending Byte: 3 Response Byte: 255
Sending Byte: 4 Response Byte: 255
Sending Byte: 5 Response Byte: 255
Sending Byte: 6 Response Byte: 255
Sending Byte: 7 Response Byte: 255
Sending Byte: 8 Response Byte: 255
Sending Byte: 9 Response Byte: 255
Sending Byte: 10 Response Byte: 255
Sending Byte: 11 Response Byte: 255
Sending Byte: 12 Response Byte: 255
Sending Byte: 13 Response Byte: 255
Sending Byte: 14 Response Byte: 255
Sending Byte: 15 Response Byte: 255
waiting for data ready signal
recieved data ready signal
Read cycle
Sending Byte: 0 Response Byte: 0
Sending Byte: 0 Response Byte: 1
Sending Byte: 0 Response Byte: 2
Sending Byte: 0 Response Byte: 3
Sending Byte: 0 Response Byte: 4
Sending Byte: 0 Response Byte: 5
Sending Byte: 0 Response Byte: 6
Sending Byte: 0 Response Byte: 7
Sending Byte: 0 Response Byte: 8
Sending Byte: 0 Response Byte: 9
Sending Byte: 0 Response Byte: 10
Sending Byte: 0 Response Byte: 11
Sending Byte: 0 Response Byte: 12
Sending Byte: 0 Response Byte: 13
Sending Byte: 0 Response Byte: 14
Sending Byte: 0 Response Byte: 15
