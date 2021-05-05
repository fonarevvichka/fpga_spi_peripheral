#include <SPI.h>

SPISettings settings(1000000, MSBFIRST, SPI_MODE0);
SPIClass vspi(VSPI);
#define dataReadyPin 21

void setup() { 
  pinMode(5, OUTPUT); // set the CS pin as an output
  pinMode(22, OUTPUT);
  pinMode(dataReadyPin, INPUT);
  digitalWrite(22, HIGH);
  digitalWrite(5, LOW);
  SPI.end();
  vspi.begin();         // initialize the SPI library

  Serial.begin(115200);}

void loop() {
  Serial.println("Write cycle");
  digitalWrite(22, LOW);
  
  for (byte i = 0; i < 16; i++) {
    vspi.beginTransaction(settings);
    digitalWrite(5, LOW);
    Serial.print("Sending Byte: ");Serial.print(i); Serial.print(" Response Byte: "); Serial.println(vspi.transfer(i));
    delay(250);
    digitalWrite(5, HIGH);  
    vspi.endTransaction();
  }
  

  while(digitalRead(dataReadyPin) == LOW) {
    delay(10);
  }
  
  Serial.println("recieved data ready signal");

  Serial.println("Read cycle");
  for (byte i = 0; i < 16; i++) {
    vspi.beginTransaction(settings);
    digitalWrite(5, LOW);
    Serial.print("Sending Byte: ");Serial.print(0); Serial.print(" Response Byte: "); Serial.println(vspi.transfer(0));
    delay(250);
    digitalWrite(5, HIGH);  
    vspi.endTransaction();
  }
  digitalWrite(22, HIGH);
}
