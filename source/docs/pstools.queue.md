
# Module documentation pstools.queue

- Prepared by:      Hannes Palmquist
- Prepared at:      2021-03-20
- Module version:   1.0.0


![](https://img.shields.io/badge/Status-Production-brightgreen.svg)

# Table of Contents

1. Document information
   1. Introduction
   1. Purpose of document
   1. Audience
   1. Acronymns and definitions
1. Module information
   1. Structure
   2. Service accounts
   3. Run schedule
   4. Module cmdlets
   5. Module config


# Document information

## Introduction

This document contains detailed information about the module Crayon.Exchange.AutoMigration. This is not a static document and should accordingly be updated when changes and/or updates are made to the environment and/or script.

## Purpose of document

The purpose of this document is provide an overview design of the solution and dependencies for the module to execute successfully. A description of inner workings of the module is also provided and the available customization options.

## Audience

The target audience for this document is

- Project team members
- System architects
- Administrators and operators responsible for administrating, managing and operating the service

## Acronymns and definitions

The following acronyms could be used throughout the document

| Acronym | Description          |
| ------- | -------------------- |
| AD      | ActiveDirectory      |
| PS      | Powershell           |
| UAC     | User Account Control |

# Module information

## Structure

The script is packaged in the form of a Powershell module. This has several advantages compared to plain scripts. The module format allows better version management, managing of dependencies and allows the script to be completely self-contained. The module consists of several base directories and files. These are described below;

| Item                               | Type      | Description                                                                                                                                                                                                                                            |
| ---------------------------------- | --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| data                               | directory | This folder is used to store dependency files                                                                                                                                                                                                          |
| docs                               | directory | Contains solution documentation in the form of pdf or docx. (This document)                                                                                                                                                                            |
| en-US                              | directory | This folder contains help files for the module                                                                                                                                                                                                         |
| include                            | directory | This folder contains included dependecy modules                                                                                                                                                                                                        |
| logs                               | directory | Contains all logfiles that the script generates.                                                                                                                                                                                                       |
| output                             | directory | If the script generates any kind of output, like reports etc, these will be written to this directory unless the script specifically require writing the output to another directory. In that case see the "Output" chapter in this document.          |
| private                            | directory | Contains all private functions used by the script/public functions                                                                                                                                                                                     |
| public                             | directory | Contains all public functions that are made available for use in the module when imported. This folder contains the main script described in this document.                                                                                            |
| settings                           | directory | Contains config files (if the script requires these). The config files can have three formats. CSV (comma separated values file) (.csv extension); JSON (JavaScript Object Notation) (.config extension); PSD (Powershell data file) (.psd1 extension) |
| temp                               | directory | Temp files, this folder will be emptied upon module import or taskrun                                                                                                                                                                                  |
| tests                              | directory | If the script includes pester tests these will be contained in this directory.                                                                                                                                                                         |
| Crayon.Exchange.AutoMigration.psd1 | file      | The module manifests                                                                                                                                                                                                                                   |
| Crayon.Exchange.AutoMigration.psm1 | file      | The module that also loads nested functions                                                                                                                                                                                                            |
| TaskRun.ps1                        | file      | Contains the run instructions for the script when executed by a scheduled task.                                                                                                                                                                        |

## Service accounts

## Run schedule

## Module cmdlets

This chapter lists all public facing cmdlets provided by the the module.

- [Cmdlet name]
  - [Cmdlet short description and purpose]

## Module config

With the settings folder of the module a config.json file is stored. This configuration file alters the behaviour of the module. The below list describes the possibles settings.
- [Setting]
  - [Setting purpose]

#

Created by Hannes Palmquist

