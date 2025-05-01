$WorkingDirectory = Get-Location
$length = 48

	cls
	Write-Output " .-------------------------."
	Write-Output " |Building Moon Patrol ROMs|"
	Write-Output " '-------------------------'"

	New-Item -ItemType Directory -Path $WorkingDirectory"\arcade" -Force
	New-Item -ItemType Directory -Path $WorkingDirectory"\arcade\mpatrol" -Force
	
	Write-Output "Copying Moon Patrol ROMs"
	# Define the file paths within the folder
	$files = @("$WorkingDirectory\mpa-1.3m", "$WorkingDirectory\mpa-2.3l","$WorkingDirectory\mpa-3.3k","$WorkingDirectory\mpa-4.3j")
	# Specify the output file within the folder
	$outputFile = "$WorkingDirectory\arcade\mpatrol\rom1.bin"
	# Concatenate the files as binary data
	[Byte[]]$combinedBytes = @()
	foreach ($file in $files) {
		$combinedBytes += [System.IO.File]::ReadAllBytes($file)
	}
	[System.IO.File]::WriteAllBytes($outputFile, $combinedBytes)
	
	Copy-Item -Path $WorkingDirectory\mpe-5.3e -Destination $WorkingDirectory\arcade\mpatrol\mpe-5.3e
	Copy-Item -Path $WorkingDirectory\mpe-4.3f -Destination $WorkingDirectory\arcade\mpatrol\mpe-4.3f
	Copy-Item -Path $WorkingDirectory\mpb-2.3m -Destination $WorkingDirectory\arcade\mpatrol\mpb-2.3m
	Copy-Item -Path $WorkingDirectory\mpb-1.3n -Destination $WorkingDirectory\arcade\mpatrol\mpb-1.3n
	Copy-Item -Path $WorkingDirectory\mpe-3.3h -Destination $WorkingDirectory\arcade\mpatrol\mpe-3.3h
	Copy-Item -Path $WorkingDirectory\mpe-2.3k -Destination $WorkingDirectory\arcade\mpatrol\mpe-2.3k
	Copy-Item -Path $WorkingDirectory\mpe-1.3l -Destination $WorkingDirectory\arcade\mpatrol\mpe-1.3l
	Copy-Item -Path $WorkingDirectory\mp-s1.1a -Destination $WorkingDirectory\arcade\mpatrol\mp-s1.1a
	
	
	Write-Output "Generating blank config file"
	$bytes = New-Object byte[] $length
	for ($i = 0; $i -lt $bytes.Length; $i++) {
	$bytes[$i] = 0xFF
	}
	
	$output_file = Join-Path -Path $WorkingDirectory -ChildPath "arcade\mpatrol\mpcfg"
	$output_directory = [System.IO.Path]::GetDirectoryName($output_file)
	[System.IO.File]::WriteAllBytes($output_file,$bytes)

	Write-Output "All done!"