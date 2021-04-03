<#PSScriptInfo
{
    "VERSION":  "1.0.0",
    "GUID":  "c0bc3220-82f6-4ece-93a8-44118ee98d64",
    "FILENAME":  "Add-QueueItem.ps1",
    "AUTHOR":  "Hannes Palmquist",
    "AUTHOREMAIL":  "hannes.palmquist@outlook.com",
    "CREATEDDATE":  "2021-01-21",
    "COMPANYNAME":  "Personal",
    "COPYRIGHT":  "(c) 2021, Hannes Palmquist, All Rights Reserved"
}
PSScriptInfo#>
function Add-QueueItem {
    <#
    .DESCRIPTION
        Adds a new item to the queue
    .PARAMETER Queue
        Queue object to add items to
    .EXAMPLE
        Add-QueueItem -Queue $Queue -Item 'Foo'
        This example shows how to add an item to the queue
    #>

    [CmdletBinding()] # Enabled advanced function support
    param(
        [parameter(Mandatory)][ExtendedQueue]$Queue,
        [parameter(Mandatory,ValueFromPipeline)][object[]]$Items
    )

    process {
        $Items | ForEach-Object {
            $Queue.AddQueueItem($PSItem)
        }
    }
}
#endregion


