<#PSScriptInfo
{
    "VERSION":  "1.0.0",
    "GUID":  "8f0f833f-aa21-43f0-866a-2b7a30dfc655",
    "FILENAME":  "Get-AllQueueItems.ps1",
    "AUTHOR":  "Hannes Palmquist",
    "AUTHOREMAIL":  "hannes.palmquist@outlook.com",
    "CREATEDDATE":  "2021-01-21",
    "COMPANYNAME":  "Personal",
    "COPYRIGHT":  "(c) 2021, Hannes Palmquist, All Rights Reserved"
}
PSScriptInfo#>
function Get-AllQueueItems {
    <#
    .DESCRIPTION
        Collect all remaining queue items
    .PARAMETER Queue
        Queue object to discard all items in
    .EXAMPLE
        Get-AllQueueItems -Queue $Queue
        This example how to retreive all queue items remaining in the queue 
    #>

    [CmdletBinding()] # Enabled advanced function support
    param(
        [parameter(Mandatory)][ExtendedQueue]$Queue
    )

    $Queue.GetAllQueuedItems()

}
#endregion


