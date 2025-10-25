// -------------------------------------------------------------------------------------------------
// Home Button Handler Implementation
// -------------------------------------------------------------------------------------------------

#include "HomeButton.h"

// Platform-specific includes
#include <Arduino.h>
#include "../pinmaps/Pins.Ramps14.h" // Include pin definitions

// Global instance declared in OnStep.ino

// Interrupt flag
volatile bool homeButtonInterrupt = false;

HomeButton::HomeButton() {
  buttonState = HOME_BUTTON_NOT_PRESSED;
  lastButtonState = HOME_BUTTON_NOT_PRESSED;
  lastDebounceTime = 0;
  buttonPressed = false;
}

bool HomeButton::init() {
  // Configure home button pin as input with pull-up
  pinMode(HOME_BUTTON_PIN, INPUT_PULLUP);
  
  // Attach interrupt for home button
  attachInterrupt(digitalPinToInterrupt(HOME_BUTTON_PIN), homeButtonISR, CHANGE);
  
  return true;
}

void HomeButton::update() {
  // Check for interrupt
  if (homeButtonInterrupt) {
    homeButtonInterrupt = false;
    
    // Read current button state
    bool currentState = (digitalRead(HOME_BUTTON_PIN) == LOW);
    
    // Check for state change
    if (currentState != lastButtonState) {
      lastDebounceTime = millis();
    }
    
    // Debounce the button press
    if ((millis() - lastDebounceTime) > HOME_BUTTON_DEBOUNCE_MS) {
      if (currentState != buttonState) {
        buttonState = currentState;
        if (buttonState == HOME_BUTTON_PRESSED) {
          buttonPressed = true;
        }
      }
    }
    
    lastButtonState = currentState;
  }
}

bool HomeButton::isPressed() {
  return (buttonState == HOME_BUTTON_PRESSED);
}

bool HomeButton::wasPressed() {
  if (buttonPressed) {
    buttonPressed = false;
    return true;
  }
  return false;
}

void HomeButton::reset() {
  buttonPressed = false;
  buttonState = HOME_BUTTON_NOT_PRESSED;
  lastButtonState = HOME_BUTTON_NOT_PRESSED;
}

// Interrupt service routine for home button
void homeButtonISR() {
  homeButtonInterrupt = true;
}
