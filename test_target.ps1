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
    Write-Host "Testing target RA 18:36, Dec +38:47"
    
    # Test your original target
    $port.WriteLine(":Sr18:36#")
    Start-Sleep -Milliseconds 100
    $port.WriteLine(":Sd+38:47#")
    Start-Sleep -Milliseconds 100
    $port.WriteLine(":MS#")
    Start-Sleep -Milliseconds 500
    $response = $port.ReadExisting()
    Write-Host "Target goto response: $response"
    
} catch {
    Write-Host "Error: $_"
} finally {
    $port.Close()
}
