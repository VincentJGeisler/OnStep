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
    Write-Host "Connected to OnStep"
    
    # Test status
    $port.WriteLine(":GU#")
    Start-Sleep -Milliseconds 500
    $status = $port.ReadExisting()
    Write-Host "Status: $status"
    
    # Test simple goto
    $port.WriteLine(":Sr00:00#")
    Start-Sleep -Milliseconds 100
    $port.WriteLine(":Sd+00:00#")
    Start-Sleep -Milliseconds 100
    $port.WriteLine(":MS#")
    Start-Sleep -Milliseconds 500
    $response = $port.ReadExisting()
    Write-Host "Goto response: $response"
    
} catch {
    Write-Host "Error: $_"
} finally {
    $port.Close()
}
