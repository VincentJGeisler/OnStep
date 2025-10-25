// -------------------------------------------------------------------------------------------------
// DS3231 RTC Driver Implementation
// -------------------------------------------------------------------------------------------------

#include "RTC_DS3231.h"

// Platform-specific includes
#include <Wire.h>
#include "../pinmaps/Pins.Ramps14.h" // Include pin definitions

// Global instance declared in OnStep.ino

RTC_DS3231::RTC_DS3231() {
  // Constructor
}

bool RTC_DS3231::init() {
  Wire.begin();
  Wire.setClock(100000); // 100kHz I2C clock
  
  // Check if DS3231 is connected
  if (!isConnected()) {
    return false;
  }
  
  return true;
}

bool RTC_DS3231::savePosition(float axis1Pos, float axis2Pos, uint8_t parkStatus, bool resetFlag) {
  PositionData posData;
  
  // Set magic number
  posData.magic[0] = (POSITION_MAGIC >> 24) & 0xFF;
  posData.magic[1] = (POSITION_MAGIC >> 16) & 0xFF;
  posData.magic[2] = (POSITION_MAGIC >> 8) & 0xFF;
  posData.magic[3] = POSITION_MAGIC & 0xFF;
  
  // Store position data
  posData.axis1Pos = axis1Pos;
  posData.axis2Pos = axis2Pos;
  posData.parkStatus = parkStatus;
  posData.resetFlag = resetFlag ? 1 : 0;
  
  // Clear reserved bytes
  posData.reserved[0] = 0;
  posData.reserved[1] = 0;
  
  // Write to DS3231 SRAM
  return writeBlock(DS3231_POS_START_ADDR, (uint8_t*)&posData, sizeof(PositionData));
}

bool RTC_DS3231::loadPosition(float* axis1Pos, float* axis2Pos, uint8_t* parkStatus, bool* resetFlag) {
  PositionData posData;
  
  // Read from DS3231 SRAM
  if (!readBlock(DS3231_POS_START_ADDR, (uint8_t*)&posData, sizeof(PositionData))) {
    return false;
  }
  
  // Check magic number
  uint32_t magic = ((uint32_t)posData.magic[0] << 24) |
                   ((uint32_t)posData.magic[1] << 16) |
                   ((uint32_t)posData.magic[2] << 8) |
                   posData.magic[3];
  
  if (magic != POSITION_MAGIC) {
    return false; // Invalid data
  }
  
  // Return position data
  *axis1Pos = posData.axis1Pos;
  *axis2Pos = posData.axis2Pos;
  *parkStatus = posData.parkStatus;
  
  // Return reset flag if requested
  if (resetFlag != nullptr) {
    *resetFlag = (posData.resetFlag == 1);
  }
  
  return true;
}

bool RTC_DS3231::clearPosition() {
  uint8_t clearData[DS3231_POS_SIZE];
  
  // Fill with zeros
  for (int i = 0; i < DS3231_POS_SIZE; i++) {
    clearData[i] = 0;
  }
  
  return writeBlock(DS3231_POS_START_ADDR, clearData, DS3231_POS_SIZE);
}

bool RTC_DS3231::isPositionValid() {
  PositionData posData;
  
  // Read from DS3231 SRAM
  if (!readBlock(DS3231_POS_START_ADDR, (uint8_t*)&posData, sizeof(PositionData))) {
    return false;
  }
  
  // Check magic number
  uint32_t magic = ((uint32_t)posData.magic[0] << 24) |
                   ((uint32_t)posData.magic[1] << 16) |
                   ((uint32_t)posData.magic[2] << 8) |
                   posData.magic[3];
  
  return (magic == POSITION_MAGIC);
}

bool RTC_DS3231::writeByte(uint8_t address, uint8_t data) {
  Wire.beginTransmission(DS3231_I2C_ADDRESS);
  Wire.write(address);
  Wire.write(data);
  return (Wire.endTransmission() == 0);
}

bool RTC_DS3231::readByte(uint8_t address, uint8_t* data) {
  Wire.beginTransmission(DS3231_I2C_ADDRESS);
  Wire.write(address);
  if (Wire.endTransmission() != 0) {
    return false;
  }
  
  Wire.requestFrom((uint8_t)DS3231_I2C_ADDRESS, (uint8_t)1);
  if (Wire.available()) {
    *data = Wire.read();
    return true;
  }
  return false;
}

bool RTC_DS3231::writeBlock(uint8_t address, uint8_t* data, uint8_t length) {
  Wire.beginTransmission(DS3231_I2C_ADDRESS);
  Wire.write(address);
  for (uint8_t i = 0; i < length; i++) {
    Wire.write(data[i]);
  }
  return (Wire.endTransmission() == 0);
}

bool RTC_DS3231::readBlock(uint8_t address, uint8_t* data, uint8_t length) {
  Wire.beginTransmission(DS3231_I2C_ADDRESS);
  Wire.write(address);
  if (Wire.endTransmission() != 0) {
    return false;
  }
  
  Wire.requestFrom((uint8_t)DS3231_I2C_ADDRESS, (uint8_t)length);
  for (uint8_t i = 0; i < length; i++) {
    if (Wire.available()) {
      data[i] = Wire.read();
    } else {
      return false;
    }
  }
  return true;
}

bool RTC_DS3231::isConnected() {
  Wire.beginTransmission(DS3231_I2C_ADDRESS);
  return (Wire.endTransmission() == 0);
}
