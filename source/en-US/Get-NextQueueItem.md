---
external help file: pstools.queue-help.xml
Module Name: pstools.queue
online version:
schema: 2.0.0
---

# Get-NextQueueItem

## SYNOPSIS

## SYNTAX

```
Get-NextQueueItem [-Queue] <ExtendedQueue> [<CommonParameters>]
```

## DESCRIPTION
Returns the next object from queue.
That object will be removed from the queue.

## EXAMPLES

### EXAMPLE 1
```
Get-NextQueueItem -Queue $Queue
This example with return the next item in queue.
```

## PARAMETERS

### -Queue
{{ Fill Queue Description }}

```yaml
Type: ExtendedQueue
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
