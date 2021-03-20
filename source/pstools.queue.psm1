# Load module helper functions
."$PSScriptRoot\include\module.utility.functions.ps1"

Initialize-ModuleConfiguration
Import-Module Microsoft.PowerShell.Security -Force -ErrorAction Stop

# Import public and private functions files
Get-ChildItem -Path (Get-ModuleConfiguration).ModuleRootPath -Directory | Where-Object { $_.name -eq 'public' -or $_.name -eq 'private' } | ForEach-Object {
    Get-ChildItem -Path $_.FullName -Include '*.ps1' -Recurse -Exclude '*.Tests.*' | ForEach-Object {
        . $_.FullName
    }
}

# Evaluate compatible powershell editions
$Continue = $true
$ManifestContent = (Get-ModuleConfiguration).ModuleManifest
if ($ManifestContent.ContainsKey('CompatiblePSEditions'))
{
    if (-not ($ManifestContent.CompatiblePSEditions.Contains($PSVersionTable.PSEdition)))
    {
        throw ('This module does not support the current PSEdition: [{0}]' -f $PSVersionTable.PSEdition)
        $Continue = $false
    }
}

if ($Continue)
{
    # Test script hash
    $ModuleRootPath = (Get-ModuleConfiguration).ModuleRootPath
    $IncludeDirectory = (Get-ModuleConfiguration).ModuleFolders.Include
    $AllScriptFilesCases = Get-ChildItem -Path $ModuleRootPath -Include '*.ps1', '*.psm1', '*.psd1' -Recurse | Where-Object { $_.fullname -notlike ('{0}\*' -f $IncludeDirectory) }
    $Passing = $true
    $AllScriptFilesCases | ForEach-Object {
        $AuthResult = Get-AuthenticodeSignature -FilePath $PSItem.FullName | Select-Object -ExpandProperty Status
        if ($AuthResult -eq 'HashMismatch')
        {
            $Passing = $false
            Write-CheckListItem -Message ('Hash validation failed: {0}' -f $PSItem.Name)
        }
    }
    if ($Passing -eq $false)
    {
        break
    }
}
