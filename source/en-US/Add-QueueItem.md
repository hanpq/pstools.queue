---
external help file: pstools.queue-help.xml
Module Name: pstools.queue
online version:
schema: 2.0.0
---

# Add-QueueItem

## SYNOPSIS

## SYNTAX

```
Add-QueueItem [-Queue] <ExtendedQueue> [-Items] <Object[]> [<CommonParameters>]
```

## DESCRIPTION
Adds a new item to the queue

## EXAMPLES

### EXAMPLE 1
```
Add-QueueItem -Queue $Queue -Item 'Foo'
```

This example shows how to add an item to the queue

## PARAMETERS

### -Queue
Queue object to add items to

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

### -Items
{{ Fill Items Description }}

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
