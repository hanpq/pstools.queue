BeforeAll {
    . (Resolve-Path -Path "$PSScriptRoot\..\..\source\private\class.extendedqueue.ps1")
    . (Resolve-Path -Path "$PSScriptRoot\..\..\source\public\Initialize-Queue.ps1")
}

Describe -Name 'Initialize-Queue.ps1' -Fixture {
    Context -Name 'When calling Initialize-Queue' {
        BeforeAll {
            $Queue = Initialize-Queue
        }
        It -Name 'Should return a object of type [ExtendedQueue]' {
            $Queue.GetType().Name | Should -Be 'ExtendedQueue'
        }
        It -Name 'Should contain a [System.Collections.Queue] object in property queue' {
            , ($Queue.Queue) | Should -BeOfType [System.Collections.Queue]
        }
        It -Name 'Should contain a [system.collections.Generic.Queue[pscustomobject]]' {
            , ($Queue.LastOperations) | Should -BeOfType [system.collections.Generic.Queue[pscustomobject]]
        }
        It -Name 'Should have default values for properties' {
            $Queue.TotalItemsAdded | Should -Be 0
            $Queue.TotalItemsRemoved | Should -Be 0
            $Queue.AddPerSec | Should -Be 0
            $Queue.RemovePerSec | Should -Be 0
            $Queue.Velocity | Should -Be 0
            $Queue.PerformanceHistory | Should -Be 50
        }
        It -Name 'Should have correct type of properties' {
            $Queue.TotalItemsAdded | Should -BeOfType [int64]
            $Queue.TotalItemsRemoved | Should -BeOfType [int64]
            $Queue.AddPerSec | Should -BeOfType [double]
            $Queue.RemovePerSec | Should -BeOfType [double]
            $Queue.Velocity | Should -BeOfType [double]
            $Queue.PerformanceHistory | Should -BeOfType [int]
        }
        It -Name 'Should have methods' {
            $Methods = @('AddQueueItem', 'GetNextQueueItem', 'ShowNextQueueItem', 'GetQueueCount', 'ClearAllQueueItems', 'GetAllQueueItems', 'RotateLastOperations', 'CalculateSpeed')
            foreach ($Method in $Methods)
            {
                $Queue.PSObject.Members.Name | Should -Contain $Method
            }
        }
    }
}
