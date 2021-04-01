---
external help file: pstools.queue-help.xml
Module Name: pstools.queue
online version:
schema: 2.0.0
---

# Clear-AllQueueItems

## SYNOPSIS

## SYNTAX

```
Clear-AllQueueItems [-Queue] <ExtendedQueue> [<CommonParameters>]
```

## DESCRIPTION
Discard all queued items.

## EXAMPLES

### EXAMPLE 1
```
Clear-AllQueueItems -Queue $Queue
This example shows how to discard all items of the provided queue
```

## PARAMETERS

### -Queue
Queue object to discard all items in

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
