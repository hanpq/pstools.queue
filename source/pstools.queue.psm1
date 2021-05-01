# Load module helper functions
."$PSScriptRoot\include\module.utility.functions.ps1"

Initialize-ModuleConfiguration
Import-Module Microsoft.PowerShell.Security -Force -ErrorAction Stop

# Import public and private functions files
Push-Location -Path $PSScriptRoot
Get-ChildItem -Path (Get-ModuleConfiguration).ModuleRootPath -Directory | Where-Object { $_.name -eq 'public' -or $_.name -eq 'private' } | ForEach-Object {
    Get-ChildItem -Path $_.FullName -Include '*.ps1' -Recurse -Exclude '*.Tests.*' | ForEach-Object {
        $CurrentFile = $PSItem
        try
        {
            . $_.FullName
        }
        catch
        {
            if ($PSItem.FullyQualifiedErrorId -eq 'ScriptRequiresUnmatchedPSEdition')
            {
                if ($PSVersionTable.PSEdition -eq 'Desktop')
                {
                    Write-Warning -Message ('Skipped importing Core-only function {0}' -f $CurrentFile.BaseName)
                }
                else
                {
                    Write-Warning -Message ('Skipped importing Desktop-only function {0}' -f $CurrentFile.BaseName)
                }
            }
            elseif ($PSItem.FullyQualifiedErrorId -eq 'ScriptRequiresElevation')
            {
                Write-Warning -Message ('Skipped importing Run-As-Administrator function {0}' -f $CurrentFile.BaseName)
            }
            else
            {
                Write-Error -Message ('Failed to import function {0} with error: {1}' -f $CurrentFile.BaseName, $PSItem)
            }
        }
    }
}
Pop-Location

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
            Write-Host "Hash validation failed to $($PSItem.Name). The script has been modified. To protect the system this module will not load." -ForegroundColor Red
        }
    }
    if ($Passing -eq $false)
    {
        break
    }
}
