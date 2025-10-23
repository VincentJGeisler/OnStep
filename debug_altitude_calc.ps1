$port = New-Object System.IO.Ports.SerialPort
$port.PortName = "COM35"
$port.BaudRate = 9600
$port.DataBits = 8
$port.Parity = "None"
$port.StopBits = "One"
$port.ReadTimeout = 1000
$port.WriteTimeout = 1000

try {
    $port.Open()
    Write-Host "Debugging altitude calculation for Dec 29°"
    
    # Set target to Dec 29°
    $port.WriteLine(":Sr00:00#")
    Start-Sleep -Milliseconds 100
    $port.WriteLine(":Sd+29:00#")
    Start-Sleep -Milliseconds 100
    
    # Try goto to see the error
    $port.WriteLine(":MS#")
    Start-Sleep -Milliseconds 500
    $response = $port.ReadExisting()
    Write-Host "Goto response for Dec 29°: $response"
    
    # Check what altitude the mount thinks it would be
    $port.WriteLine(":GA#")
    Start-Sleep -Milliseconds 500
    $alt = $port.ReadExisting()
    Write-Host "Calculated altitude: $alt"
    
} catch {
    Write-Host "Error: $_"
} finally {
    $port.Close()
}
