---
external help file: pstools.queue-help.xml
Module Name: pstools.queue
online version:
schema: 2.0.0
---

# Measure-Queue

## SYNOPSIS

## SYNTAX

```
Measure-Queue [-Queue] <ExtendedQueue> [<CommonParameters>]
```

## DESCRIPTION
Returns an object with performance metrics for the provided queue.

## EXAMPLES

### EXAMPLE 1
```
Measure-Queue -Queue $Queue
```

This example will return a object containing performance metrics for the provided queue.

## PARAMETERS

### -Queue
Queue object to retreive performance metrics for.

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
