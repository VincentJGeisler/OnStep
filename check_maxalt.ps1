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
    Write-Host "Checking maxAlt setting"
    
    # Get maxAlt setting
    $port.WriteLine(":Go#")
    Start-Sleep -Milliseconds 500
    $maxAlt = $port.ReadExisting()
    Write-Host "maxAlt setting: $maxAlt"
    
    # Get minAlt setting
    $port.WriteLine(":Gh#")
    Start-Sleep -Milliseconds 500
    $minAlt = $port.ReadExisting()
    Write-Host "minAlt setting: $minAlt"
    
} catch {
    Write-Host "Error: $_"
} finally {
    $port.Close()
}
