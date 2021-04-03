<#PSScriptInfo
{
    "VERSION":  "1.0.0",
    "GUID":  "983899bd-0ad7-4dc5-9da5-c36d73819216",
    "FILENAME":  "Get-NextQueueItem.ps1",
    "AUTHOR":  "Hannes Palmquist",
    "AUTHOREMAIL":  "hannes.palmquist@outlook.com",
    "CREATEDDATE":  "2021-01-21",
    "COMPANYNAME":  "Personal",
    "COPYRIGHT":  "(c) 2021, Hannes Palmquist, All Rights Reserved"
}
PSScriptInfo#>
function Get-NextQueueItem {
    <#
    .DESCRIPTION
        Returns the next object from queue. That object will be removed from the queue.
    .PARAMETER Qeueue
        Queue object to retreive next items from
    .EXAMPLE
        Get-NextQueueItem -Queue $Queue
        This example with return the next item in queue.
    #>

    [CmdletBinding()] # Enabled advanced function support
    param(
        [parameter(Mandatory)][ExtendedQueue]$Queue
    )

    return $Queue.GetNextQueueItem()

}
#endregion


