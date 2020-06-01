Write-Output "Starting PowerShell module build..."

<#
Because of the differences in PowerShell 6 and higher for `ConvertFrom-Json`, we have to specify two ways to import the project config into a hashtable:

## PowerShell 5.1

`ConvertFrom-Json` only supports converting the JSON input into a PSObject, so we have to import it in normally and then convert each 'NoteProperty' member into a Hashtable.

## PowerShell 6 and higher

`ConvertFrom-Json` natively supports converting the JSON input into a Hashtable, so no further conversion is necessary.
#>

Write-Output "Importing project settings..."
$ConfigContentSplat = @{
    "Path"        = ".\buildConfig.json";
    "Raw"         = $true;
    "ErrorAction" = "Stop";
}
switch ($PSVersionTable.PSVersion.Major -le 5) {
    $true {
        $baseProjectConfig = Get-Content @ConfigContentSplat | ConvertFrom-Json
        
        $projectConfig = [hashtable]::new()
        foreach ($member in ($baseProjectConfig.PSObject.Members | Where-Object { $PSItem.MemberType -eq "NoteProperty" })) {
            $projectConfig.Add($member.Name, $member.Value)
        }
        break
    }

    Default {
        $projectConfig = Get-Content @ConfigContentSplat | ConvertFrom-Json -AsHashtable
        break
    }
}

Write-Output "Creating module manifest..."
Update-ModuleManifest @projectConfig

Write-Output "Done."