# OnStep Development Guide

## Getting Started

### Prerequisites
- Arduino IDE or PlatformIO
- Basic understanding of C/C++
- Knowledge of stepper motors and telescope mounts
- Serial communication understanding

### Development Environment Setup

1. **Clone the Repository**
   ```bash
   git clone https://github.com/hjd1964/OnStep.git
   cd OnStep
   ```

2. **Install Dependencies**
   - Arduino IDE: Install required libraries
   - PlatformIO: Dependencies auto-installed

3. **Configure for Your Hardware**
   - Edit `Config.h` for your mount type
   - Select appropriate pinmap in `src/pinmaps/Models.h`
   - Set stepper driver parameters

## Code Structure Overview

### Main Entry Point
**File**: `OnStep.ino`
- Contains `setup()` and `loop()` functions
- Initializes hardware and starts main loop
- Handles real-time operations

### Configuration System
**File**: `Config.h`
- All user-configurable settings
- Mount type definitions
- Hardware parameters
- Feature toggles

### Core Modules

#### Motion Control
- **`MoveTo.ino`**: Main motion control logic
- **`Goto.ino`**: Goto functionality
- **`Park.ino`**: Parking control
- **`Guide.ino`**: Guiding functionality

#### Communication
- **`Command.ino`**: Serial command processing
- **`addons/Ethernet/`**: Web interface
- **`addons/WiFi/`**: WiFi interface
- **`addons/SmartHandController/`**: Hand controller

#### Hardware Abstraction
- **`src/HAL/`**: Hardware abstraction layer
- **`src/pinmaps/`**: Pin definitions for different boards
- **`src/lib/`**: Utility functions and coordinate handling

## Development Workflow

### 1. Making Changes

#### Step 1: Understand the Code
```c
// Read the relevant files
// Understand the data flow
// Check existing similar functionality
```

#### Step 2: Plan Your Changes
```c
// Identify files to modify
// Plan the implementation
// Consider impact on other systems
```

#### Step 3: Implement Changes
```c
// Make small, focused changes
// Add debug output
// Test incrementally
```

#### Step 4: Test Thoroughly
```c
// Test with different mount types
// Verify safety limits
// Check coordinate accuracy
```

### 2. Testing Your Changes

#### Compile Test
```bash
# Check for compilation errors
# Fix any warnings
# Verify all mount types compile
```

#### Hardware Test
```c
// Start with small movements
// Test safety limits
// Verify coordinate accuracy
// Check all mount types
```

#### Integration Test
```c
// Test with ASCOM drivers
// Verify web interface
// Check hand controller
// Test serial commands
```

### 3. Debugging Techniques

#### Enable Debug Output
```c
// In Config.h or relevant files
#define DEBUG_ONSTEP 1

// Use debug macros
DF("Debug message: %d\n", value);
DLF("Debug line\n");
```

#### Serial Monitor
```c
// Connect serial monitor
// Watch debug output
// Monitor command processing
// Check error messages
```

#### Common Debug Patterns
```c
// Trace coordinate flow
DF("Input: RA=%.2f, Dec=%.2f\n", inputRA, inputDec);
DF("After conversion: Axis1=%.2f, Axis2=%.2f\n", axis1, axis2);

// Monitor motion
DF("Target: %ld, Current: %ld, Error: %ld\n", target, current, error);

// Check safety limits
if (safetyLimitsOn) {
    DF("Safety check: Alt=%.2f, Limit=%.2f\n", currentAlt, maxAlt);
}
```

## Common Development Tasks

### 1. Adding New Commands

#### Step 1: Choose Command Format
```c
// Follow LX200 protocol
// Use existing command patterns
// Consider command conflicts
```

#### Step 2: Add Command Handler
```c
// In Command.ino
if (command[0] == 'G' && command[1] == 'X') {
    // Your command logic here
    sprintf(reply, "Response");
    boolReply = false;
}
```

#### Step 3: Test Command
```c
// Send command via serial
// Verify response
// Check error handling
```

### 2. Modifying Coordinate Handling

#### Step 1: Understand Current System
```c
// Read Coord.h functions
// Understand coordinate flow
// Check mount type handling
```

#### Step 2: Plan Changes
```c
// Identify functions to modify
// Consider mount type differences
// Plan coordinate transformations
```

#### Step 3: Implement Changes
```c
// Modify coordinate functions
// Add conditional compilation
// Test with different mount types
```

### 3. Adding New Mount Types

#### Step 1: Define Mount Type
```c
// In Config.h
#define MOUNT_TYPE YOUR_NEW_TYPE

// In Constants.h
#define YOUR_NEW_TYPE 3
```

#### Step 2: Add Conditional Logic
```c
// Throughout codebase
#if MOUNT_TYPE == YOUR_NEW_TYPE
    // Your mount-specific logic
#endif
```

#### Step 3: Test All Functions
```c
// Test coordinate handling
// Verify motion control
// Check safety limits
// Test parking/unparking
```

### 4. Modifying Safety Limits

#### Step 1: Identify Limit Checks
```c
// In OnStep.ino main loop
// Look for safetyLimitsOn checks
// Find limit validation functions
```

#### Step 2: Add Custom Limits
```c
if (safetyLimitsOn) {
    // Add your custom safety checks
    if (yourCustomCondition) {
        stopSlewingAndTracking(SS_LIMIT);
    }
}
```

#### Step 3: Test Safety System
```c
// Test limit detection
// Verify safety responses
// Check error handling
```

## Code Quality Guidelines

### 1. Use Conditional Compilation
```c
// Always use mount type conditions
#if MOUNT_TYPE == FORK
    // Fork mount specific code
#elif MOUNT_TYPE == GEM
    // GEM mount specific code
#endif
```

### 2. Add Error Handling
```c
// Validate inputs
if (parameter < minValue || parameter > maxValue) {
    commandError = CE_PARAM_RANGE;
    return;
}

// Check for errors
if (errorCondition) {
    generalError = ERR_YOUR_ERROR;
    return;
}
```

### 3. Use Consistent Naming
```c
// Use descriptive variable names
double targetRightAscension;
double targetDeclination;

// Use consistent function naming
void setTargetAxis1(double axis1, int pierSide);
void setTargetAxis2(double axis2, int pierSide);
```

### 4. Add Documentation
```c
// Document complex functions
/**
 * Converts sky coordinates to instrument coordinates
 * @param ra Right ascension in hours
 * @param dec Declination in degrees
 * @param axis1 Output axis1 position
 * @param axis2 Output axis2 position
 * @param pierSide Pier side for GEM mounts
 */
void equToInstr(double ra, double dec, double *axis1, double *axis2, int pierSide);
```

## Testing Strategies

### 1. Unit Testing
```c
// Test individual functions
void testCoordinateConversion() {
    double ra = 12.0, dec = 45.0;
    double axis1, axis2;
    
    equToInstr(ra, dec, &axis1, &axis2, PierSideEast);
    
    // Verify results
    assert(axis1 > 0 && axis1 < 360);
    assert(axis2 > -90 && axis2 < 90);
}
```

### 2. Integration Testing
```c
// Test complete workflows
void testGotoWorkflow() {
    // Set target
    setTargetRA(12.0);
    setTargetDec(45.0);
    
    // Start goto
    startGoto();
    
    // Monitor progress
    while (isGotoInProgress()) {
        // Check for errors
        // Verify movement
    }
    
    // Verify final position
    assert(getCurrentRA() == 12.0);
    assert(getCurrentDec() == 45.0);
}
```

### 3. Hardware Testing
```c
// Test with real hardware
// Start with small movements
// Test safety limits
// Verify coordinate accuracy
```

## Common Pitfalls

### 1. Mount Type Assumptions
```c
// WRONG: Assuming GEM mount logic
if (newPierSide == PierSideWest) axis1 = axis1 + 180.0;

// RIGHT: Use conditional compilation
#if MOUNT_TYPE == GEM
    if (newPierSide == PierSideWest) axis1 = axis1 + 180.0;
#endif
```

### 2. Coordinate Range Issues
```c
// WRONG: Not handling coordinate wrapping
double ra = getCurrentRA() + 12.0;  // Could exceed 24 hours

// RIGHT: Use proper range functions
double ra = haRange(getCurrentRA() + 12.0);
```

### 3. Safety Limit Bypassing
```c
// WRONG: Bypassing safety checks
if (targetDec > 90) targetDec = 90;  // Silent limit

// RIGHT: Use proper error handling
if (targetDec > 90) {
    commandError = CE_PARAM_RANGE;
    return;
}
```

### 4. Memory Issues
```c
// WRONG: Not checking buffer sizes
sprintf(reply, "Very long message that might overflow buffer");

// RIGHT: Use safe string functions
snprintf(reply, sizeof(reply), "Safe message");
```

## Performance Considerations

### 1. Real-time Constraints
```c
// Main loop runs at high frequency
// Keep operations fast
// Avoid blocking operations
// Use efficient algorithms
```

### 2. Memory Usage
```c
// Use stack variables when possible
// Avoid large arrays
// Use const for read-only data
// Consider memory fragmentation
```

### 3. Interrupt Safety
```c
// Use cli()/sei() for critical sections
// Avoid long operations in interrupts
// Use volatile for shared variables
// Consider interrupt priorities
```

## Deployment

### 1. Compile for Target
```c
// Select correct board
// Set appropriate options
// Optimize for size/speed
// Check memory usage
```

### 2. Upload and Test
```c
// Upload to hardware
// Test basic functionality
// Verify configuration
// Check for errors
```

### 3. Calibration
```c
// Calibrate steps per degree
// Test coordinate accuracy
// Verify safety limits
// Check all mount types
```

## Conclusion

Developing for OnStep requires understanding the coordinate systems, mount type differences, and real-time constraints. Always test thoroughly and consider the impact on different mount types. Use the debugging techniques and follow the code quality guidelines to ensure reliable operation.
