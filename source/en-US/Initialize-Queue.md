---
external help file: pstools.queue-help.xml
Module Name: pstools.queue
online version:
schema: 2.0.0
---

# Initialize-Queue

## SYNOPSIS

## SYNTAX

```
Initialize-Queue [<CommonParameters>]
```

## DESCRIPTION
This cmdlet initializes a new queue object.

The returned object is a wrapper class for the System.Collection.Queue class.
This class (ExtendedQueue) 
provides additional functionality compared to the standard Queue class.
The Queue object is
stored as a property of the returned object called "Queue".
The object returned also contains properties
containing counts of added items, removed items, additions per sec, removes per sec and 
velocity (delta between add & remove per sec.).
The module cmdlet Measure-Queue returns these metrics.

## EXAMPLES

### EXAMPLE 1
```
$Queue = Initialize-Queue
```

This example will create a new instance of the queue object

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
