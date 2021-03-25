
@{
  RootModule = 'pstools.queue.psm1'
  ModuleVersion = '1.3.1'
  CompatiblePSEditions = @('Desktop','Core')
  GUID = '8b96f3d4-ebf3-4c6a-a99a-1c5392ecc8da'
  Author = 'Hannes Palmquist'
  CompanyName = ''
  Copyright = '(c) 2021 Hannes Palmquist. All rights reserved.'
  Description = 'Provides tools to work with system.collections.queue arrays'
  RequiredModules = @()
  FunctionsToExport = @('Add-QueueItem','Clear-AllQueueItems','Get-AllQueueItems','Get-NextQueueItem','Initialize-Queue','Measure-Queue','Show-NextQueueItem')
  FileList = @('.\data\appicon.ico','.\data\banner.ps1','.\docs\pstools.queue.md','.\en-US\Add-QueueItem.md','.\en-US\Clear-AllQueueItems.md','.\en-US\Get-AllQueueItems.md','.\en-US\Get-NextQueueItem.md','.\en-US\Initialize-Queue.md','.\en-US\Measure-Queue.md','.\en-US\pstools.queue-help.xml','.\en-US\Show-NextQueueItem.md','.\include\module.utility.functions.ps1','.\private\class.extendedqueue.ps1','.\public\Add-QueueItem.ps1','.\public\Clear-AllQueueItems.ps1','.\public\Get-AllQueueItems.ps1','.\public\Get-NextQueueItem.ps1','.\public\Initialize-Queue.ps1','.\public\Measure-Queue.ps1','.\public\Show-NextQueueItem.ps1','.\settings\config.json','.\LICENSE.txt','.\pstools.queue.psd1','.\pstools.queue.psm1')
  PrivateData = @{
    ModuleName = 'pstools.queue'
    DateCreated = '2021-01-21'
    LastBuildDate = '2021-03-25'
    PSData = @{
      Tags = @('PSEdition_Desktop','PSEdition_Core','Windows','Linux','MacOS')
      ProjectUri = 'https://getps.dev/modules/pstools.queue/quickstart'
      LicenseUri = 'https://github.com/hanpq/pstools.queue/blob/main/LICENSE'
      ReleaseNotes = 'https://github.com/hanpq/pstools.queue/blob/main/changelog.json'
      IsPrerelease = 'False'
      IconUri = ''
      PreRelease = ''
      RequireLicenseAcceptance = $True
      ExternalModuleDependencies = @()
    }
  }
  CmdletsToExport = @()
  VariablesToExport = @()
  AliasesToExport = @()
  DscResourcesToExport = @()
  ModuleList = @()
  RequiredAssemblies = @()
  ScriptsToProcess = @()
  TypesToProcess = @()
  FormatsToProcess = @()
  NestedModules = @()
  HelpInfoURI = ''
  DefaultCommandPrefix = ''
  PowerShellVersion = '5.1'
  PowerShellHostName = ''
  PowerShellHostVersion = ''
  DotNetFrameworkVersion = ''
  CLRVersion = ''
  ProcessorArchitecture = ''
}




