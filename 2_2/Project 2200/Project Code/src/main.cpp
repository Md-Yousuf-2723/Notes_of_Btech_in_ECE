#include <Arduino.h>
#include <Wire.h>
#include <Adafruit_INA219.h>

Adafruit_INA219 ina219;

const int mosfetPin = PA8;

void setup() {
  Serial.begin(115200);
  
  delay(2000); 
  Serial.println("STM32 Power Distribution System Starting...");

  pinMode(mosfetPin, OUTPUT);
  digitalWrite(mosfetPin, LOW);

  if (!ina219.begin()) {
    Serial.println("Failed to find INA219 chip. Check wiring!");
    while (1) { delay(10); } 
  }
  
  Serial.println("INA219 Connected. Monitoring Power...");
}

void loop() {
  float loadVoltage = ina219.getBusVoltage_V(); 
  float current_mA = ina219.getCurrent_mA();

  Serial.print("Bus Voltage:   "); 
  Serial.print(loadVoltage); 
  Serial.println(" V");
  
  Serial.print("Current:       "); 
  Serial.print(current_mA); 
  Serial.println(" mA");
  Serial.println("-----------------------");

  if (loadVoltage >= 2.80 && loadVoltage <= 3.20) {
    digitalWrite(mosfetPin, HIGH);
    Serial.println("STATUS: SAFE -> OUTPUT ENABLED");
  } else {
    digitalWrite(mosfetPin, LOW);
    
    if (loadVoltage < 2.80) {
      Serial.println("STATUS: UNDER-VOLTAGE -> OUTPUT DISABLED");
    } else {
      Serial.println("STATUS: OVER-VOLTAGE -> OUTPUT DISABLED");
    }
  }

  Serial.println();
  
  delay(500);
}
