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
  digitalWrite(22, LOW);
  for (byte i = 0; i < 16; i++) {
    vspi.beginTransaction(settings);
    digitalWrite(5, LOW);
    Serial.println(i);
    Serial.print("response: "); Serial.println(vspi.transfer(i));
    delay(500);
    digitalWrite(5, HIGH);  
    vspi.endTransaction();
  }
  delay(500);
  digitalWrite(22, HIGH);

//  while(digitalRead(dataReadyPin) == LOW) {
//    delay(10);
//  }
//  
//  Serial.println("recieved signal");
}
