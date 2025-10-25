// -------------------------------------------------------------------------------------------------
// DS3231 RTC Driver for OnStep
// Provides position storage and retrieval using DS3231 SRAM
// -------------------------------------------------------------------------------------------------

#pragma once

#include <stdint.h>

// DS3231 I2C Address
#define DS3231_I2C_ADDRESS 0x68

// DS3231 SRAM addresses for position storage
#define DS3231_POS_START_ADDR 0x08  // Start of user SRAM area
#define DS3231_POS_SIZE 16         // 16 bytes for position data

// Position data structure
typedef struct {
  uint8_t magic[4];        // Magic number to identify valid data
  float axis1Pos;           // Axis1 position (RA/Azm)
  float axis2Pos;           // Axis2 position (Dec/Alt)
  uint8_t parkStatus;       // Park status
  uint8_t resetFlag;        // Reset button flag (0=normal, 1=reset button)
  uint8_t reserved[2];      // Reserved for future use
} PositionData;

// Magic number to identify valid position data
#define POSITION_MAGIC 0x4F535445  // "OSTE" - OnStep Telescope

class RTC_DS3231 {
public:
  RTC_DS3231();
  bool init();
  bool savePosition(float axis1Pos, float axis2Pos, uint8_t parkStatus, bool resetFlag = false);
  bool loadPosition(float* axis1Pos, float* axis2Pos, uint8_t* parkStatus, bool* resetFlag = nullptr);
  bool clearPosition();
  bool isPositionValid();
  
private:
  bool writeByte(uint8_t address, uint8_t data);
  bool readByte(uint8_t address, uint8_t* data);
  bool writeBlock(uint8_t address, uint8_t* data, uint8_t length);
  bool readBlock(uint8_t address, uint8_t* data, uint8_t length);
  bool isConnected();
};

// Global instance
extern RTC_DS3231 rtc;
