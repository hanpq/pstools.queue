## Instruction for module usage

### Function loading

All function files within private and public are loaded on module import.
All function files within public are added as exported functions.

The module honors some of the #requires statements in the function files. Currently PSEdition and RunAsAdministrator is supported. If the functions files fail to be imported to failing the requires validation the function will not be loaded with a warning. 

### Module configuration

When the module is imported a global module configuration variable will be created. The variable is called: $global:ModuleConfiguration_\<modulename\>. Use the command <code>Get-ModuleConfiguration</code> to retreive the contents of the variable for the current module without having to hardcode the module name in the code.

The content of the variable will be structured according to the list below

- ModuleName: testmodule
- ModuleRootPath: C:\Users\User01\Documents\Powershell\Modules\testmodule
- ModuleManifestPath: C:\Users\User01\Documents\Powershell\Modules\testmodule\testmodule.psd1
- ModuleFolders: Hashtable of System.IO.DirectoryInfo objects for all root folders of the module where the key is the name of the folder and the value is the DirectoryInfo object.
- ModuleFiles: HashTable containing imported files of json,csv,cred,psd1 from the settings root folder. The key is the "name" attribute and the value is the parsed content.
- ModuleFilePaths: HashTable containing all module files. Key is the "name" attribute and the value is the "fullname"
- ModuleManifest: Is the parsed file from ModuleManifestPath

### Logging

Module ships with a built in log function. The log function first prints logs to a log file and then invokes either write-host, write-verbose, write-error or write-debug. The following log types are supported.
- pslog Success "Test"
- pslog Info "Test"
- pslog Error "Test"
- pslog Verbose "Test"
- pslog Debug "Test"

Log files are written to the local app data folder ie C:\Users\User01\AppData\Local\<modulename>\Logs

Log files are named with the current date. Which means log rollover is 24 hours.

Each log entry is stamped with a timestamp in the following format: yyyy-MM-ddThh:mm:ss.ffffzzz which includes timezone information.

The log files are tab-delimitered. Tab was selected as a compromize between parsability and readability. CSV can be quite hard to read as it is very compact without a CSV reader but is good to parse. Tab is much easier to read and is still parsable.

Specify the following snippet to tag each pslog file entry with a source
$PSDefaultParameterValues = @{'pslog:source' = <functionname>}

### Progress

Module comes with a extened progress function Write-PSProgress that includes some automation that the default Write-Progress lacks.

- Write-PSProgress allows you to pass -Counter and -Total directly as parameters and Write-PSProgress will automatically calculate percentcomplete.
- Write-PSProgress also includes some intelligence to perform smoothly when iterating very large datasets fast. If progress would be updated each iteration it could be the limiting factor for speed. Write-PSProgress makes a descision based on the Total count at what interval the progress bar sohuld be updated. For example if you need to iterate through 1 000 000 items with base speed of 1000 items per second it might to be needed to update the progressbar 1 000 000 times. In this example Write-PSProgress would instead update the progressbar approximatly each 1 000 items.
- Write-PSProgress also keeps track of start time and calculates ETA, ItemsPerSec.

### Other

Module also comes with a few short helper functions

- Assert-FolderExists
  - Creates specified folder if it does not exists
- Invoke-GarbageCollect
  - Invokes [system.gc]::Collect() to free up memory after disposed objects.

