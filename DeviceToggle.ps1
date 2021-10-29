if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs;
    exit;
}

# You can find this in device manager: select the device, right click properties, go to details, then choose "Device instance path"
$deviceId = 'HID\ELAN2514&COL01\5&330385BB&0&0000';
$device = Get-PnpDevice -InstanceId $deviceId -ErrorAction SilentlyContinue;
if ($device) {
    switch ($device.Status) {
        'OK' { 
            Write-Host "Disabling device";
            pnputil /disable-device $deviceId;
            break;
        }
        default {
            Write-Host "Enabling device";
            pnputil /enable-device $deviceId;
        }
    }

    <#
    # Comment the switch and uncomment the following to make this a restarter instead of a switch

    Write-Host "Restarting device";
    pnputil /disable-device $deviceId;
    Start-Sleep -Seconds 1;
    pnputil /enable-device $deviceId;
    #>
}
else {
    Write-Warning "Device with ID '$deviceId' not found";
    Start-Sleep -Seconds 10;
}
