$regKeyName = 'SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}'
$internalLargePageName = 'KMD_EnableInternalLargePage'
$aMDPnPId = 'pci\\ven_1002.*'

$reg = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Default)
if ($reg)
{
	$key = $reg.OpenSubKey($regKeyName, [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadSubTree)
	ForEach ($subKey in $key.GetSubKeyNames())
	{
		if ($subKey -match '\d{4}')
		{
			$gpu = $key.OpenSubKey($subKey, [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadSubTree)
			if ($gpu)
			{
				$pnPId = $gpu.GetValue("MatchingDeviceId")
				if ($pnPId -match $aMDPnPId )
				{
					switch ($gpu.GetValue($internalLargePageName))
					{
						2 { $mode = "Compute" ; break }
						default { $mode = "Graphics" }					
					}
					"GPU $($pnPId): $mode"
					$gpu = $key.OpenSubKey($subKey, $true)
					$gpu.SetValue($internalLargePageName, 2, [Microsoft.Win32.RegistryValueKind]::DWord)
				}
				else
				{
					"GPU $($pnPId): not AMD"
				}
			}
		}
		
	}	
	
	$reg.Close()
	$reg.Dispose()
}