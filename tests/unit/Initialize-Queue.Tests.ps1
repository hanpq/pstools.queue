BeforeAll {
    . (Resolve-Path -Path "$PSScriptRoot\..\..\Source\private\class.extendedqueue.ps1")
    . (Resolve-Path -Path "$PSScriptRoot\..\..\Source\public\Initialize-Queue.ps1")
}

Describe -Name "Initialize-Queue.ps1" -Fixture {
    Context -Name 'When calling Initialize-Queue' {
        BeforeAll {
            $Queue = Initialize-Queue
        }
        It -Name 'Should return a object of type [ExtendedQueue]' {
            $Queue.GetType().Name | should -Be "ExtendedQueue"
        }
        It -Name 'Should contain a [System.Collections.Queue] object in property queue' {
            ,($Queue.Queue) | should -beoftype [System.Collections.Queue]
        }
        It -Name 'Should contain a [system.collections.Generic.Queue[pscustomobject]]' {
            , ($Queue.LastOperations) | should -beoftype [system.collections.Generic.Queue[pscustomobject]]
        }
        It -Name 'Should have default values for properties' {
            $Queue.TotalItemsAdded | should -be 0
            $Queue.TotalItemsRemoved | should -be 0
            $Queue.AddPerSec | should -be 0
            $Queue.RemovePerSec | should -be 0
            $Queue.Velocity | should -be 0
            $Queue.PerformanceHistory | should -be 50
        }
        It -Name 'Should have correct type of properties' {
            $Queue.TotalItemsAdded | should -beoftype [int64]
            $Queue.TotalItemsRemoved | should -beoftype [int64]
            $Queue.AddPerSec | should -beoftype [double]
            $Queue.RemovePerSec | should -beoftype [double]
            $Queue.Velocity | should -beoftype [double]
            $Queue.PerformanceHistory | should -beoftype [int]
        }
        It -Name 'Should have methods' {
            $Methods = @('AddQueueItem','GetNextQueueItem','ShowNextQueueItem','GetQueueCount','ClearAllQueueItems','GetAllQueueItems','RotateLastOperations','CalculateSpeed')
            foreach ($Method in $Methods) {
                $Queue.PSObject.Members.Name | should -contain $Method
            }
        }
    }
}
