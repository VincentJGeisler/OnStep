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
    Write-Host "Checking latitude and time settings"
    
    # Get latitude
    $port.WriteLine(":Gt#")
    Start-Sleep -Milliseconds 500
    $lat = $port.ReadExisting()
    Write-Host "Latitude: $lat"
    
    # Get longitude  
    $port.WriteLine(":Gg#")
    Start-Sleep -Milliseconds 500
    $lon = $port.ReadExisting()
    Write-Host "Longitude: $lon"
    
    # Get time
    $port.WriteLine(":GL#")
    Start-Sleep -Milliseconds 500
    $time = $port.ReadExisting()
    Write-Host "Local time: $time"
    
} catch {
    Write-Host "Error: $_"
} finally {
    $port.Close()
}
