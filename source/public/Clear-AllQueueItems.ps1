<#PSScriptInfo
    .VERSION 1.0.0
    .GUID 1e9b3cc1-d3a7-4f04-b9f7-644aed113856
    .FILENAME Clear-AllQueueItems.ps1
    .AUTHOR Hannes Palmquist
    .AUTHOREMAIL hannes.palmquist@outlook.com
    .CREATEDDATE 2021-01-21
    .COMPANYNAME Personal
    .COPYRIGHT (c) 2021, Hannes Palmquist, All Rights Reserved
#>
function Clear-AllQueueItems {
    <#
    .DESCRIPTION
        Discard all queued items.
    .PARAMETER Queue
        Queue object to discard all items in
    .EXAMPLE
        Clear-AllQueueItems -Queue $Queue
        This example shows how to discard all items of the provided queue
    #>

    [CmdletBinding()] # Enabled advanced function support
    param(
        [parameter(Mandatory)][ExtendedQueue]$Queue
    )

    $Queue.ClearAllQueueItems()

}
#endregion


