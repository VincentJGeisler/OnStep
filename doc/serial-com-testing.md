## Serial COM Testing (Windows / PowerShell)

This guide documents exactly how to communicate with OnStep over a serial COM port for automated testing. It assumes Windows with PowerShell 7 and `plink.exe` available.

### Requirements

- **Disconnect ASCOM clients**: Close Device Hub, planetarium apps, etc., so the COM port is free.
- **Port**: `COM35` (adjust as needed).
- **Baud**: `9600`; `8-N-1`.
- **Tool**: `plink` from PuTTY.
- **Protocol**: LX200-style commands; every command must end with `#`.
- **Responses**: Usually end with `#`. Movement commands are async; poll status/position.
- **Reset**: Use `:hR#` for software reset (used to verify RTC persistence).
- **Tracking**: Start tracking with `:ST1#` if needed.
- **Safety**: Ensure physical clearance before motion.
- **Kill stale sessions**: End lingering `plink` processes before reusing the port.
- **Line endings**: `plink` sends CRLF by default when piping; OnStep tolerates this.
- **Baud mismatch symptom**: No response or gibberish → verify `9600`.

### Quick connect (interactive)

```bash
plink -serial COM35 -sercfg 9600,8,n,1,N
```

Type commands like `:GR#`, `:GD#`, `:GU#`, `:ST1#`, `:hR#`. Press Enter after each; ensure the trailing `#`.

### One-shot commands (pipeline)

```bash
echo :GR# | plink -batch -serial COM35 -sercfg 9600,8,n,1,N
echo :GD# | plink -batch -serial COM35 -sercfg 9600,8,n,1,N
echo :GU# | plink -batch -serial COM35 -sercfg 9600,8,n,1,N
```

### PowerShell scripted session

```powershell
$commands = @(
  ":GU#",            # Get status
  ":GR#",            # Get RA
  ":GD#"             # Get Dec
)
$commands -join "`r`n" | & plink -batch -serial COM35 -sercfg 9600,8,n,1,N
```

### Slew example (set RA/Dec and move)

```powershell
$cmds = @(
  ":ST1#",                   # Ensure tracking on (optional)
  ":Sr12:30:00#",            # Set target RA 12h 30m 00s
  ":Sd-60:00:00#",           # Set target Dec -60° 00' 00"
  ":MS#",                    # Slew to target
  ":GD#"                     # Query Dec to verify
)
$cmds -join "`r`n" | & plink -batch -serial COM35 -sercfg 9600,8,n,1,N
```

### RTC persistence test (soft reset)

1. Connect:

```bash
plink -serial COM35 -sercfg 9600,8,n,1,N
```

2. Slew to a known Dec (example `-60`):

```text
:Sd-60:00:00#
:MS#
```

3. Verify:

```text
:GD#
```

4. Soft reset (saves position to RTC and reboots):

```text
:hR#
```

5. After reconnecting (few seconds), verify it restored the same position:

```text
:GD#
```

Note: A cold power cycle will intentionally return to parked/home per safety policy.

### Automated test script (exact command used)

To run the automated verification used in our testing session:

```powershell
powershell -ExecutionPolicy Bypass -File .\verify_dec_minus_60.ps1 -Port COM35 -Baud 9600 -TargetDec -60 -Tolerance 0.5
```

What it does:

- Ensures no stale `plink` is running
- Connects and verifies communication with `:GU#`
- Slews to Dec -60° (`:Sd-60:00:00#`, `:MS#`), waits, verifies `:GD#`
- Issues soft reset `:hR#`
- Reconnects, verifies Dec remains within ±0.5° of -60°

Script location: `verify_dec_minus_60.ps1` (at repo root)

### Kill stale plink sessions

```powershell
Get-Process plink -ErrorAction SilentlyContinue | Stop-Process -Force
```

### Troubleshooting

- **No response**: Confirm no other app holds the port; verify `9600` baud; kill stale `plink`.
- **Immediate disconnect**: Remove `-batch` for interactive diagnosis; check cable/port.
- **Command rejected**: Ensure every command ends with `#`; validate syntax (e.g., `:Sd±DD:MM:SS#`).
- **Movement doesn’t start**: Some configs require tracking (`:ST1#`); also verify limits configuration.
- **ASCOM conflict**: Disconnect Device Hub/clients before serial tests.


