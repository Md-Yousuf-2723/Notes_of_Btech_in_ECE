#include <Arduino.h>
#include <Wire.h>
#include <Adafruit_INA219.h>

Adafruit_INA219 ina219_LED(0x40);  
Adafruit_INA219 ina219_Motor(0x41); 

// MOSFET Gate Pins
const int ledMosfetPin = PA8;
const int motorMosfetPin = PA9;

// Trip limits
const float MAX_LED_CURRENT = 30.0;     
const float MAX_MOTOR_CURRENT = 600.0;  

// Fault Latches
bool ledFaultTriggered = false;
bool motorFaultTriggered = false;

// Debounce Counters (Prevents false trips from startup inrush current)
int ledOvercurrentCounter = 0;
int motorOvercurrentCounter = 0;
const int FAULT_THRESHOLD = 10; // Must be overcurrent for 10 consecutive loops (~50ms) to trip

void setup() {
  Serial.begin(115200);
  delay(1000); 
  Serial.println("STM32 Power Distribution System Initializing...");

  // 1. Set pins as output
  pinMode(ledMosfetPin, OUTPUT);
  pinMode(motorMosfetPin, OUTPUT);

  // 2. Default to OFF for safety while sensors initialize
  digitalWrite(ledMosfetPin, LOW);
  digitalWrite(motorMosfetPin, LOW);

  // 3. Initialize Sensors
  if (!ina219_LED.begin()) {
    Serial.println("CRITICAL ERROR: Failed to find INA219 #1 (LED) at 0x40.");
    while (1) { delay(10); } 
  }
  
  if (!ina219_Motor.begin()) {
    Serial.println("CRITICAL ERROR: Failed to find INA219 #2 (Motor) at 0x41.");
    while (1) { delay(10); } 
  }

  Serial.println("Sensors Online. Engaging Power Channels...");

  // 4. Turn on the loads
  digitalWrite(ledMosfetPin, HIGH);
  digitalWrite(motorMosfetPin, HIGH);
}

void loop() {
  float ledCurrent = 0.0;
  float motorCurrent = 0.0;

  // ==========================================
  // CHANNEL 1: LED LOGIC
  // ==========================================
  if (!ledFaultTriggered) {
    ledCurrent = ina219_LED.getCurrent_mA();
    
    if (ledCurrent > MAX_LED_CURRENT) {
      ledOvercurrentCounter++; // Increment fault counter
      
      if (ledOvercurrentCounter >= FAULT_THRESHOLD) {
        digitalWrite(ledMosfetPin, LOW); 
        ledFaultTriggered = true;        
        Serial.print("FAULT ISOLATED: LED Overcurrent! Measured: ");
        Serial.print(ledCurrent);
        Serial.println(" mA. Channel Locked OUT.");
      }
    } else {
      ledOvercurrentCounter = 0; // Reset counter if current drops back to normal
    }
  }

  // ==========================================
  // CHANNEL 2: MOTOR LOGIC
  // ==========================================
  if (!motorFaultTriggered) {
    motorCurrent = ina219_Motor.getCurrent_mA();
    
    if (motorCurrent > MAX_MOTOR_CURRENT) {
      motorOvercurrentCounter++; // Increment fault counter
      
      if (motorOvercurrentCounter >= FAULT_THRESHOLD) {
        digitalWrite(motorMosfetPin, LOW); 
        motorFaultTriggered = true;        
        Serial.print("FAULT ISOLATED: Motor Overcurrent! Measured: ");
        Serial.print(motorCurrent);
        Serial.println(" mA. Channel Locked OUT.");
      }
    } else {
      motorOvercurrentCounter = 0; // Reset counter if current drops back to normal
    }
  }

  // ==========================================
  // SERIAL MONITOR TELEMETRY
  // ==========================================
  static unsigned long lastPrintTime = 0;
  
  // Update serial monitor every 500ms without blocking the main loop
  if (millis() - lastPrintTime > 500) {
    Serial.print("LED: ");
    if (ledFaultTriggered) {
      Serial.print("FAULT");
    } else {
      Serial.print(ledCurrent, 1);
      Serial.print("mA");
    }
    
    Serial.print(" | MOTOR: ");
    if (motorFaultTriggered) {
      Serial.println("FAULT");
    } else {
      Serial.print(motorCurrent, 1);
      Serial.println("mA");
    }
    
    lastPrintTime = millis();
  }

  // Main loop delay (determines how fast the fault counter climbs)
  delay(5); 
}