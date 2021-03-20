$ModuleName = 'devmodule'
Clear-Host
Write-Host
try
{
    Import-Module $ModuleName -ErrorAction Stop
    Write-Host ('   {0,-25}: {1}' -f '+ Loaded module', $modulename) -Fore green
    Write-Host ('   {0,-25}: {1}' -f '+ Module version', (Get-Module devmodule).Version.ToString()) -Fore green
    Write-Host ('   {0,-25}: {1}' -f '+ Available functions', ((Get-Command -Module $ModuleName).Name -join ' | ')) -Fore green
    Write-Host
} catch
{
    Write-Host ('   {0,-25}: {1}' -f '- Failed to load module', $modulename) -Fore red
    Write-Host
    throw $_.exception.message
}

