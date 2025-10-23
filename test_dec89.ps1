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
    Write-Host "Testing Dec +89°"
    
    # Set target to Dec 89°
    $port.WriteLine(":Sr00:00#")
    Start-Sleep -Milliseconds 100
    $port.WriteLine(":Sd+89:00#")
    Start-Sleep -Milliseconds 100
    
    # Try goto
    $port.WriteLine(":MS#")
    Start-Sleep -Milliseconds 500
    $response = $port.ReadExisting()
    Write-Host "Goto response for Dec 89°: $response"
    
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
