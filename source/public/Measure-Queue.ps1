<#PSScriptInfo
{
    "VERSION":  "1.0.0",
    "GUID":  "2e3f6483-081d-4277-823a-18bc34043a93",
    "FILENAME":  "Measure-Queue.ps1",
    "AUTHOR":  "Hannes Palmquist",
    "AUTHOREMAIL":  "hannes.palmquist@outlook.com",
    "CREATEDDATE":  "2021-01-21",
    "COMPANYNAME":  "Personal",
    "COPYRIGHT":  "(c) 2021, Hannes Palmquist, All Rights Reserved"
}
PSScriptInfo#>
function Measure-Queue {
    <#
    .DESCRIPTION
        Returns an object with performance metrics for the provided queue.
    .PARAMETER Queue
        Queue object to retreive performance metrics for.
    .EXAMPLE
        Measure-Queue -Queue $Queue
        This example will return a object containing performance metrics for the provided queue.
    #>

    [CmdletBinding()] # Enabled advanced function support
    param(
        [parameter(Mandatory)][ExtendedQueue]$Queue
    )

    return [pscustomobject]@{
        QueueCount = $Queue.GetQueueCount()
        AddsPerSec = [Math]::Round($Queue.AddPerSec,2)
        RemovesPerSec = [Math]::Round($Queue.RemovePerSec,2)
        Velocity = [Math]::Round($Queue.Velocity,2)
    }

}
#endregion


