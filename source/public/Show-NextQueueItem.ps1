<#PSScriptInfo
    .VERSION 1.0.0
    .GUID eb246a94-378c-4ef6-a021-cb70b16aedf3
    .FILENAME Show-NextQueueItem.ps1
    .AUTHOR Hannes Palmquist
    .AUTHOREMAIL hannes.palmquist@outlook.com
    .CREATEDDATE 2021-01-21
    .COMPANYNAME Personal
    .COPYRIGHT (c) 2021, Hannes Palmquist, All Rights Reserved
#>
function Show-NextQueueItem {
    <#
    .DESCRIPTION
        Shows the next item in queue without removing it from queue.
    .PARAMETER Name
        Description
    .EXAMPLE
        Show-NextQueueItem
        Description of example
    #>

    [CmdletBinding()] # Enabled advanced function support
    param(
        [parameter(Mandatory)][ExtendedQueue]$Queue
    )

    return $Queue.ShowNextQueueItem()

}
#endregion


