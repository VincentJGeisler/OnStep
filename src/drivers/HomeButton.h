// -------------------------------------------------------------------------------------------------
// Home Button Handler for OnStep
// Provides reset position functionality using home button
// -------------------------------------------------------------------------------------------------

#pragma once

#include <stdint.h>

// Home button states
#define HOME_BUTTON_NOT_PRESSED 0
#define HOME_BUTTON_PRESSED     1
#define HOME_BUTTON_DEBOUNCE_MS 50

class HomeButton {
public:
  HomeButton();
  bool init();
  void update();
  bool isPressed();
  bool wasPressed();
  void reset();
  
private:
  bool buttonState;
  bool lastButtonState;
  unsigned long lastDebounceTime;
  bool buttonPressed;
};

// Global instance
extern HomeButton homeButton;

// Interrupt handler for home button
void homeButtonISR();
