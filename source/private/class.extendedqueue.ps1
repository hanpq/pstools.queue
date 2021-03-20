class ExtendedQueue {
    [System.Collections.Queue]$Queue
    [system.collections.Generic.Queue[pscustomobject]]$LastOperations
    [int64]$TotalItemsAdded
    [int64]$TotalItemsRemoved
    [double]$AddPerSec
    [double]$RemovePerSec
    [double]$Velocity
    [int]$PerformanceHistory
    
    [void]AddQueueItem (
        $Item
    ) {
        $this.Queue.Enqueue($item)
        $this.LastOperations.Enqueue(([pscustomobject]@{Type = 'Add'; TimeStamp = ([datetime]::Now) }))
        $this.TotalItemsAdded++
        $this.CalculateSpeed()
    }

    [psobject]GetNextQueueItem() {
        try {
            $ReturnObject = $this.Queue.Dequeue()
            $this.LastOperations.Enqueue(([pscustomobject]@{Type = 'Remove'; TimeStamp = ([datetime]::Now) }))
            $this.TotalItemsRemoved++
        } catch {
            $ReturnObject = $null
        }
        $this.CalculateSpeed()
        return $ReturnObject
    }

    [psobject]ShowNextQueueItem() {
        return $this.Queue.Peek()
    }

    [int64]GetQueueCount() {
        return $this.Queue.Count
    }

    [void]ClearAllQueueItems() {
        $this.Queue.Clear()
    }

    [array]GetAllQueueItems() {
        $Result = while ($this.GetQueueCount()) {
            $this.GetNextQueueItem()
            $this.TotalItemsRemoved++
        }
        $this.CalculateSpeed()
        return $Result
    }

    [void]RotateLastOperations ($CurrentTime) {
        while ($this.LastOperations.Count -ge $this.PerformanceHistory) {
            $null = $this.LastOperations.Dequeue()
        }
    }

    [void]CalculateSpeed () {
        $CurrentTime = [datetime]::Now
        $this.RotateLastOperations($CurrentTime)
        $ItemsAdded = $this.LastOperations.Where( { $PSItem.Type -eq 'Add' }).Count
        $ItemsRemoved = $this.LastOperations.Where( { $PSItem.Type -eq 'Remove' }).Count
            
        try {
            $this.AddPerSec = $ItemsAdded / ($CurrentTime - $this.LastOperations.Where( { $PSItem.Type -eq 'Add' })[0].TimeStamp).TotalSeconds
        } catch {
            $this.AddPerSec = 0
        }
            
        try {
            $this.RemovePerSec = $ItemsRemoved / ($CurrentTime - $this.LastOperations.Where( { $PSItem.Type -eq 'Remove' })[0].TimeStamp).TotalSeconds
        } catch {
            $this.RemovePerSec = 0
        }
            
        $this.Velocity = $this.AddPerSec - $this.RemovePerSec
    }

    ExtendedQueue () {
        $this.Queue = [System.Collections.Queue]::New()
        $this.LastOperations = [system.collections.Generic.Queue[pscustomobject]]::New()
        $this.TotalItemsAdded = 0
        $this.TotalItemsRemoved = 0
        $this.AddPerSec = 0
        $this.RemovePerSec = 0
        $this.PerformanceHistory = 50
    }
}
