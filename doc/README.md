# OnStep Documentation

This directory contains comprehensive documentation for the OnStep telescope mount control system.

## Documentation Files

### Core Architecture
- **[architecture.md](architecture.md)** - Complete system architecture overview with Mermaid diagrams
- **[coordinate-systems.md](coordinate-systems.md)** - Detailed guide to coordinate transformations
- **[development-guide.md](development-guide.md)** - Practical development guide for contributors

## Quick Start for Developers

### 1. Understanding the System
Start with `architecture.md` to understand:
- Overall system design
- Main program flow
- Key components and their interactions
- Data flow diagrams

### 2. Coordinate Systems
Read `coordinate-systems.md` to understand:
- Different coordinate systems used
- How transformations work
- Mount type differences
- Common coordinate issues

### 3. Making Changes
Use `development-guide.md` for:
- Development workflow
- Testing strategies
- Common development tasks
- Code quality guidelines

## Key Concepts

### Mount Types
OnStep supports three mount types with different coordinate handling:

- **GEM (German Equatorial)**: Complex pier side logic, meridian flips
- **FORK**: Simplified coordinates, no pier side concept
- **ALTAZM (Altitude-Azimuth)**: Alt/Az coordinate system

### Coordinate Flow
```
User Input (RA/Dec) → Coordinate Conversion → Motor Control → Position Feedback → User Output
```

### Main Components
- **Configuration System**: `Config.h` - All user settings
- **Motion Control**: `MoveTo.ino`, `Goto.ino`, `Park.ino`
- **Communication**: `Command.ino`, web interfaces, hand controller
- **Hardware Abstraction**: `src/HAL/`, `src/pinmaps/`

## Common Development Tasks

### Adding New Commands
1. Choose command format (LX200 protocol)
2. Add handler in `Command.ino`
3. Test with serial interface

### Modifying Coordinates
1. Understand current system in `src/lib/Coord.h`
2. Plan changes considering mount types
3. Implement with conditional compilation
4. Test with different mount types

### Adding Mount Types
1. Define new mount type in `Config.h`
2. Add conditional logic throughout codebase
3. Test all functions with new mount type

### Modifying Safety Limits
1. Find limit checks in `OnStep.ino`
2. Add custom safety conditions
3. Test safety system thoroughly

## Testing Strategies

### Compile Testing
- Check for errors and warnings
- Verify all mount types compile
- Test different configurations

### Hardware Testing
- Start with small movements
- Test safety limits
- Verify coordinate accuracy
- Check all mount types

### Integration Testing
- Test with ASCOM drivers
- Verify web interface
- Check hand controller
- Test serial commands

## Debugging Tips

### Enable Debug Output
```c
#define DEBUG_ONSTEP 1
DF("Debug message: %d\n", value);
```

### Common Debug Patterns
```c
// Trace coordinate flow
DF("Input: RA=%.2f, Dec=%.2f\n", inputRA, inputDec);
DF("After conversion: Axis1=%.2f, Axis2=%.2f\n", axis1, axis2);

// Monitor motion
DF("Target: %ld, Current: %ld, Error: %ld\n", target, current, error);
```

### Serial Monitoring
- Connect serial monitor
- Watch debug output
- Monitor command processing
- Check error messages

## Code Quality Guidelines

### Use Conditional Compilation
```c
#if MOUNT_TYPE == FORK
    // Fork mount specific code
#elif MOUNT_TYPE == GEM
    // GEM mount specific code
#endif
```

### Add Error Handling
```c
if (parameter < minValue || parameter > maxValue) {
    commandError = CE_PARAM_RANGE;
    return;
}
```

### Use Consistent Naming
```c
double targetRightAscension;
double targetDeclination;
void setTargetAxis1(double axis1, int pierSide);
```

### Document Complex Functions
```c
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

## Common Pitfalls

### Mount Type Assumptions
- Always use conditional compilation
- Don't assume GEM mount logic
- Consider all mount types

### Coordinate Range Issues
- Use proper range functions
- Handle coordinate wrapping
- Check for valid ranges

### Safety Limit Bypassing
- Use proper error handling
- Don't silently limit values
- Respect safety constraints

### Memory Issues
- Check buffer sizes
- Use safe string functions
- Avoid memory leaks

## Performance Considerations

### Real-time Constraints
- Main loop runs at high frequency
- Keep operations fast
- Avoid blocking operations
- Use efficient algorithms

### Memory Usage
- Use stack variables when possible
- Avoid large arrays
- Use const for read-only data
- Consider memory fragmentation

### Interrupt Safety
- Use cli()/sei() for critical sections
- Avoid long operations in interrupts
- Use volatile for shared variables
- Consider interrupt priorities

## Getting Help

### Documentation
- Read the relevant documentation files
- Check existing similar functionality
- Look at code comments and examples

### Testing
- Start with small changes
- Test incrementally
- Use debug output
- Verify with real hardware

### Community
- Check OnStep Groups.io
- Look at existing issues and solutions
- Ask questions with specific details
- Share your solutions

## Conclusion

OnStep is a complex system that requires understanding of coordinate systems, mount types, and real-time constraints. Use this documentation to understand the system and make informed changes. Always test thoroughly and consider the impact on different mount types.
