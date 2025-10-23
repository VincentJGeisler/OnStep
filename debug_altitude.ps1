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
    Write-Host "Debugging altitude calculation"
    
    # Get current altitude
    $port.WriteLine(":GA#")
    Start-Sleep -Milliseconds 500
    $alt = $port.ReadExisting()
    Write-Host "Current altitude: $alt"
    
    # Get current azimuth
    $port.WriteLine(":GZ#")
    Start-Sleep -Milliseconds 500
    $azm = $port.ReadExisting()
    Write-Host "Current azimuth: $azm"
    
    # Get current RA
    $port.WriteLine(":GR#")
    Start-Sleep -Milliseconds 500
    $ra = $port.ReadExisting()
    Write-Host "Current RA: $ra"
    
    # Get current Dec
    $port.WriteLine(":GD#")
    Start-Sleep -Milliseconds 500
    $dec = $port.ReadExisting()
    Write-Host "Current Dec: $dec"
    
} catch {
    Write-Host "Error: $_"
} finally {
    $port.Close()
}
