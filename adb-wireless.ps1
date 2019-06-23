param(
[Parameter(Position=0)][String[]]$deviceID,
[String[]]$adb
)
Set-PSDebug -Trace 2
$ErrorActionPreference = 'Inquire'
$shell = New-Object -ComObject Wscript.Shell
[regex]$deviceIDRegex='(?<!:)(\w\w\w\w+)(?=\s+device)'
[regex]$deviceIPRegex='(\d+.\d+.\d+.\d+)(?=\/)'

if( !$adb ){
$adb=Get-Command "adb" -ErrorAction SilentlyContinue
if( !$adb ){
$shell.Popup("ADB not found!")
exit 1
}
}

$deviceID=& $adb devices
$deviceID=$deviceIDRegex.Matches($deviceID)
if($deviceID.Count -eq 0){
$shell.Popup("Device not found!")
exit 1
}
foreach ($devid in $deviceID){
$env:ANDROID_SERIAL=$devid
$devmodel=&$adb shell getprop ro.product.model
if($shell.Popup("connect $devmodel $devid wirelessely?",0,'',4) -eq 6) {
$tcpip=&$adb shell getprop service.adb.tcp.port
if ($tcpip.Length -eq 0)
{&$adb tcpip:5555
$tcpip='5555'}
$ip=&$adb shell ip -4 addr show wlan0
$ip=$deviceIPRegex.Match($ip)
if($ip.Length -eq 0)
{$shell.Popup("Device IP not found!")
exit 1}
$result=&adb connect $ip':'$tcpip
$shell.Popup($result)
}
}