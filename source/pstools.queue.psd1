
@{
  RootModule = 'pstools.queue.psm1'
  ModuleVersion = '1.1'
  CompatiblePSEditions = @('Desktop','Core')
  GUID = '8b96f3d4-ebf3-4c6a-a99a-1c5392ecc8da'
  Author = 'Hannes Palmquist'
  CompanyName = ''
  Copyright = '(c) 2021 Hannes Palmquist. All rights reserved.'
  Description = 'Provides tools to work with system.collections.queue arrays'
  RequiredModules = @()
  FunctionsToExport = @('Add-QueueItem','Clear-AllQueueItems','Get-AllQueueItems','Get-NextQueueItem','Initialize-Queue','Measure-Queue','Show-NextQueueItem')
  FileList = @('.\data\appicon.ico','.\data\banner.ps1','.\docs\pstools.queue.md','.\include\module.utility.functions.ps1','.\private\class.extendedqueue.ps1','.\public\Add-QueueItem.ps1','.\public\Clear-AllQueueItems.ps1','.\public\Get-AllQueueItems.ps1','.\public\Get-NextQueueItem.ps1','.\public\Initialize-Queue.ps1','.\public\Measure-Queue.ps1','.\public\Show-NextQueueItem.ps1','.\settings\config.json','.\LICENSE.txt','.\pstools.queue.psd1','.\pstools.queue.psm1')
  PrivateData = @{
    ModuleName = 'pstools.queue'
    DateCreated = '2021-01-21'
    LastBuildDate = '2021-03-22'
    PSData = @{
      Tags = @()
      ProjectUri = 'https://getps.dev/modules/PS.Tools.Daikin/quickstart'
      LicenseUri = 'https://github.com/hanpq/PS.Tools.Queue/blob/main/LICENSE'
      ReleaseNotes = ''
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




