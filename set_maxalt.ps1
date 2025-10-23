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
    Write-Host "Setting maxAlt to 90°"
    
    # Set maxAlt to 90°
    $port.WriteLine(":Sg90#")
    Start-Sleep -Milliseconds 500
    $response = $port.ReadExisting()
    Write-Host "Set maxAlt response: $response"
    
    # Verify it was set
    $port.WriteLine(":Go#")
    Start-Sleep -Milliseconds 500
    $maxAlt = $port.ReadExisting()
    Write-Host "New maxAlt setting: $maxAlt"
    
} catch {
    Write-Host "Error: $_"
} finally {
    $port.Close()
}
