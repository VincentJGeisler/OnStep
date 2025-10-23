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
    Write-Host "Checking pier side status"
    
    # Get telescope status (includes pier side info)
    $port.WriteLine(":GU#")
    Start-Sleep -Milliseconds 500
    $status = $port.ReadExisting()
    Write-Host "Telescope status: $status"
    
    # Get pier side specifically
    $port.WriteLine(":Gm#")
    Start-Sleep -Milliseconds 500
    $pierSide = $port.ReadExisting()
    Write-Host "Pier side response: $pierSide"
    
} catch {
    Write-Host "Error: $_"
} finally {
    $port.Close()
}
