
# Helper functions

function Write-CheckListItem
{
    param (
        $InfoChar = 'O',
        $InfoColor = 'White',
        $PositiveChar = '+',
        $PositiveColor = 'Green',
        $IntermediateChar = '/',
        $IntermediateColor = 'Yellow',
        $NegativeChar = '-',
        $NegativeColor = 'Red',
        [ValidateSet('Positive', 'Intermediate', 'Negative', 'Info')]
        $Severity = 'Info',
        $Message = '',
        $Milliseconds
    )

    switch ($Severity)
    {
        'Positive'
        {
            $SelectedColor = $PositiveColor
            $SelectedChar = $PositiveChar
        }
        'Intermediate'
        {
            $SelectedColor = $IntermediateColor
            $SelectedChar = $IntermediateChar
        }
        'Negative'
        {
            $SelectedColor = $NegativeColor
            $SelectedChar = $NegativeChar
        }
        'Info'
        {
            $SelectedColor = $InfoColor
            $SelectedChar = $InfoChar
        }
    }
    if ($Milliseconds)
    {
        Write-Host ('      [{0}] {1}  ' -f $SelectedChar, $Message) -ForegroundColor $SelectedColor -NoNewline; Write-Host (' {0}ms' -f ([Math]::Round($Milliseconds))) -ForegroundColor DarkGray
    }
    else
    {
        Write-Host ('      [{0}] {1}  ' -f $SelectedChar, $Message) -ForegroundColor $SelectedColor
    }
}

function Show-MultiChoise
{
    <#
    .DESCRIPTION
        Shows an interactive choise selection ui. One selection can be made with a key input.
        Possible answers are passed to the function either as a hashtable or a string array. With a
        hashtable the response characters can be selected, unlike a string array where the function
        will add a character to each answer in the order of which they are defined.
    .PARAMETER MultiChoise
        Defines the possible answers that can be selected. Can either a be a hashtable or a string array.
        With a hashtable the key are the single character to be used for the answer and the value is the name of
        the answer. If a string array is passed instead the function will assign a answer character to each string element in the
        order of which the strings are passed. The assigned characters are utilized in the following order: 1-9-A-Z.
    .PARAMETER ReturnKey
        Specifies if the function should return the character of the selected answer. Default the name of the answer is returned.
    .EXAMPLE
        Show-MultiChoise -MultiChoise 'Answer1','Answer2'

        This command will provide the following question. The returned object is the name of the selection the user made.

        [1] Answer1
        [2] Answer2

        PS> 2

        Answer2

    .EXAMPLE
        Show-MultiChoise -MultiChoise @{'s'='Sun','r'='Rain'} -ReturnKey

        This command will provide the following question, and since the return
        key parameter is selected the returned object is the character that the
        user selected rather than the string 'Sun'

        [R] Rain
        [S] Sun

        PS> S

        S

    .NOTES
        This command relies on the Get-KeyCode advanced function.
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][ValidateScript( { $_.GetType().name -eq 'HashTable' -or $_.GetType().Name -eq 'String' })]
        $MultiChoise,
        [switch]$ReturnKey
    )

    switch ($MultiChoise.GetType().Name)
    {
        'HashTable'
        {
            # Print all choises to screen
            Write-Host ''
            $MultiChoise.Keys | Sort-Object | ForEach-Object {
                Write-Host ('   [{0}] ' -f ($_)) -ForegroundColor Yellow -NoNewline
                Write-Host ('{0}' -f ($MultiChoise[$_])) -ForegroundColor White
            }

            # Retreive user input
            $Key = (Get-KeyCode).Character
            while ($MultiChoise.Keys -notcontains $Key)
            {
                Write-Host 'Incorrect input' -ForegroundColor Red
                $Key = (Get-KeyCode).Character
            }

            # Depending on switch variable $ReturnKey return the value or the key
            if (!$ReturnKey)
            {
                Write-Output $MultiChoise[$key]
            }
            else
            {
                Write-Output $key
            }
        }

        'Object[]'
        {
            # Defined possible characters
            $Alph = @()
            49..57 | ForEach-Object { $Alph += [char]$_ } # Numbers
            65..90 | ForEach-Object { $Alph += [char]$_ } # Chars

            # Verify that there is enough characters for the choises
            if (($MultiChoise | Measure-Object | Select-Object -ExpandProperty Count) -gt $Alph.Count)
            {
                Throw ('There are not enough defined characters({0}) for the number of choises({1})' -f ($Alph.Count), ($MultiChoise | Measure-Object | Select-Object -ExpandProperty Count))
            }
            else
            {
                # Define counter
                $Counter = 0

                # Define an array to hold all takes characters
                $SelectedAlph = @()

                # Print all choises to screen
                Write-Host ''
                $MultiChoise | ForEach-Object {
                    Write-Host ('   [{0}] ' -f ($Alph[$Counter])) -ForegroundColor Yellow -NoNewline
                    Write-Host ('{0}' -f ($_))              -ForegroundColor White

                    # Save taken character
                    $SelectedAlph += $Alph[$Counter]

                    # Increase counter
                    $Counter++
                }

                # Retreive use input
                $Key = (Get-KeyCode).Character

                # Check if key input is within possible range
                while ($SelectedAlph -notcontains $Key)
                {
                    Write-Host 'Incorrect input' -ForegroundColor Red
                    $Key = (Get-KeyCode).Character
                }

                # Depending on switch variable $ReturnKey return the value or the key
                if (!$ReturnKey)
                {
                    Write-Output $MultiChoise[($Alph.IndexOf([Char]($Key.ToString().ToUpper())))]
                }
                else
                {
                    Write-Output $key
                }
            }
        }
    }
}

function Compare-StringArray
{
    <#
    .DESCRIPTION
        Provides functionality to compare two string arrays.
    .PARAMETER ReferenceArray
        Defines the reference array
    .PARAMETER DifferencingArray
        Defines the differencing array
    .PARAMETER InBoth
        Specifies that only array items contained in both arrays are returned
    .PARAMETER AllCombined
        Specifies that all items in both arrays should be returned. Items that exist in both arrays are included once in the result.
    .PARAMETER ExclusiveInReferenceArray
        Specifies that all items that are exclusive or uniqe in the reference array are returned.
    .PARAMETER ExclusiveInBoth
        Specifies that all unique items froms both arrays are returned. Items that exist in both arrays are excluded from the result all together.
    .EXAMPLE
        Compare-StringArray -ReferenceArray @('Ett','Två','Tre') -DifferencingArray @('Tre','Fyra','Fem') -InBoth
        Returns Tre
    .EXAMPLE
        Compare-StringArray -ReferenceArray @('Ett','Två','Tre') -DifferencingArray @('Tre','Fyra','Fem') -AllCombined
        Returns Ett,Två,Tre,Fyra,Fem
    .EXAMPLE
        Compare-StringArray -ReferenceArray @('Ett','Två','Tre') -DifferencingArray @('Tre','Fyra','Fem') -ExclusiveInReferenceArray
        Returns Ett,Två
    .EXAMPLE
        Compare-StringArray -ReferenceArray @('Ett','Två','Tre') -DifferencingArray @('Tre','Fyra','Fem') -ExclusiveInBoth
        Returns Ett,Två,Fyra,Fem
    #>   
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Parameter used to select parameter set name')]
    [CmdletBinding()]
    param(
        [AllowEmptyCollection()][Parameter(Mandatory)][AllowNull()][string[]]$ReferenceArray,
        [AllowEmptyCollection()][Parameter(Mandatory)][AllowNull()][string[]]$DifferencingArray,
        [Parameter(Mandatory, ParameterSetName = 'InBoth')][switch]$InBoth,
        [Parameter(Mandatory, ParameterSetName = 'AllCombined')][switch]$AllCombined,
        [Parameter(Mandatory, ParameterSetName = 'ExclusiveInReferenceArray')][switch]$ExclusiveInReferenceArray,
        [Parameter(Mandatory, ParameterSetName = 'ExclusiveInBoth')][Alias('NoDuplicates')][switch]$ExclusiveInBoth
    )

    if ($null -eq $ReferenceArray)
    {
        $ReferenceArray = [string[]]@()
    }
    if ($null -eq $DifferencingArray)
    {
        $DifferencingArray = [string[]]@()
    }

    $ReferenceArrayHashSet = New-Object -TypeName System.Collections.Generic.HashSet[string] -ArgumentList (, $ReferenceArray)
    $DifferencingArrayHashSet = New-Object -TypeName System.Collections.Generic.HashSet[string] -ArgumentList (, $DifferencingArray)

    switch ($PSCmdlet.ParameterSetName)
    {
        'InBoth'
        {
            $copy = New-Object -TypeName 'System.Collections.Generic.HashSet[string]' -ArgumentList $ReferenceArrayHashSet
            $copy.IntersectWith($DifferencingArrayHashSet)
            [string[]]$copy
        }
        'AllCombined'
        {
            $copy = New-Object -TypeName 'System.Collections.Generic.HashSet[string]' -ArgumentList $ReferenceArrayHashSet
            $copy.UnionWith($DifferencingArrayHashSet)
            [string[]]$copy
        }
        'ExclusiveInReferenceArray'
        {
            $copy = New-Object -TypeName 'System.Collections.Generic.HashSet[string]' -ArgumentList $ReferenceArrayHashSet
            $copy.ExceptWith($DifferencingArrayHashSet)
            [string[]]$copy
        }
        'ExclusiveInBoth'
        {
            $copy = New-Object -TypeName 'System.Collections.Generic.HashSet[string]' -ArgumentList $ReferenceArrayHashSet
            $copy.SymmetricExceptWith($DifferencingArrayHashSet)
            [string[]]$copy
        }
    }
}

function Test-FileEndOfLine
{
    <#
    .DESCRIPTION
        asd
    .PARAMETER Name
        Description
    .EXAMPLE
        Test-FileEndOfLine
        Description of example
    #>

    [CmdletBinding(DefaultParameterSetName = 'ScriptFilePath')] # Enabled advanced function support
    param(
        [Parameter(Mandatory, ParameterSetName = 'ScriptFilePath')]
        [System.IO.FileInfo]
        $ScriptFilePath,

        [Parameter(Mandatory, ParameterSetName = 'RawCode')]
        [string]
        $RawCode,

        [string]
        $Encoding = 'UTF8'
    )

    BEGIN
    {

        # Import script file
        if ($PSCmdlet.ParameterSetName -eq 'ScriptFilePath')
        {
            try
            {
                $RawCode = Get-Content $ScriptFilePath -Raw -ErrorAction Stop -Encoding $Encoding
                Write-Verbose -Message 'Successfully imported file'
            }
            catch
            {
                Write-Error -Message 'Failed to import file' -ErrorRecord $_
                break
            }
        }
    }

    PROCESS
    {
        $WindowsRegex = "(`r`n|`n`r)"
        $UnixRegex = "(?<![`r])(`n)(?![`r])"
        $MacRegex = "(?<![`n])(`r)(?![`n])"

        switch -Regex ($RawCode)
        {
            $WindowsRegex
            {
                return 'Windows'
            }
            $UnixRegex
            {
                return 'Unix'
            }
            $MacRegex
            {
                return 'Mac'
            }
            default
            {
                return 'None'
            }
        }
    }
}

function Set-FileEndOfLine
{
    <#
    .DESCRIPTION
        asd
    .PARAMETER Name
        Description
    .EXAMPLE
        Set-FileEndOfLine
        Description of example
    #>

    [CmdletBinding()] # Enabled advanced function support
    param(
        [system.io.fileinfo]
        $FilePath
    )

    try
    {
        $CodeRaw = Get-Content -Path $FilePath -Raw -Encoding UTF8 -ErrorAction Stop
        $CodeRaw = $CodeRaw -replace "(?<![`r])(`n)(?![`r])", "`r`n"
        $CodeRaw = $CodeRaw -replace "(?<![`n])(`r)(?![`n])", "`r`n"
        $CodeRaw | Set-Content $FilePath -NoNewline -Encoding UTF8 -ErrorAction Stop
        return $true
    }
    catch
    {
        $_
        return $false
    }
}

Properties {
    $path_root = $PSScriptRoot
    $modulename = (Get-Item -Path $path_root).Name
    $path_root_source = "$path_root\source"
    $path_modulemanifest = "$path_root_source\$modulename.psd1"
    $import_modulemanifest = Import-PowerShellDataFile -Path $path_modulemanifest
    $buildconfig = Get-Content -Path "$path_root\module.config" | ConvertFrom-Json

    # Import modules
    Import-Module Configuration -ErrorAction Stop
    if ($buildconfig.sign)
    {
        Import-Module Microsoft.PowerShell.Security -ErrorAction Stop -Force
    }
    if ($buildconfig.createzip)
    {
        Import-Module Microsoft.PowerShell.Archive -ErrorAction Stop -Force
    }
    if ($buildconfig.runpestertests)
    {
        Import-Module Pester -ErrorAction stop -Force
    }
}

TaskSetup -setup {
    try
    {
        Get-Module $modulename -ErrorAction SilentlyContinue | Remove-Module -Force -ErrorAction Stop
    }
    catch
    {
        throw $_
    }
}

Task -name 'SetupBuildEnv' -depends @(
    'CreateMissingFolders',
    'ValidateModuleConfiguration',
    'FindMissingTests',
    'UpdateFunctionPSScriptInfo',
    'RebuildManifest',
    'UpdateFunctionsToExport',
    'UpdateLastBuildDate',
    'UpdateFileList'
    'UpdateEncoding',
    'UpdateEOL'
)

# Published tasks
Task -name 'Test' -depends @(
    'SetupBuildEnv',
    'PesterModuleTests',
    'PesterUnitTests',
    'PesterIntegrationTests'
)
Task -name 'Build' -depends @(
    'Test',
    'PatchVersion',
    'PreExportClean',
    'ExportCreate',
    'ExportPushModule',
    'PostExportClean'
    'CommitAndPushRepository'
)

Task -name 'Release' -depend @(
    'Test',
    'MinorVersion',
    'ChangeLog',
    'CreateModuleHelpFiles',
    'CommitAndPushRepository'
    'PreExportClean',
    'ExportCreate',
    'ExportPushModule',
    'ExportSign', 
    'BuildZIP', 
    'BuildInstaller',
    'PublishToGallery', 
    'PostExportClean'
    'CommitAndPushRepository'
)

Task -name default -depends 'Build'

Task -name 'CommitAndPushRepository' -precondition { $buildconfig.Github } -action {
    if (Test-Path -Path (Join-Path -Path $path_root -ChildPath '.git'))
    {
        git -C $path_root add .
        git -C $path_root commit -m 'Build commit'
        git -C $path_root push
    }
    else 
    {
        git -C $path_root init --initial-branch=main
        git -C $path_root add .
        git -C $path_root commit -m 'And so, it begins.'
        git remote add origin https://github.com/hanpq/$modulename.git
        hub create -p
        git push -u origin HEAD
    }
}

Task -name 'CreateMissingFolders' {
    $sourcerootfolders = @(
        'release', 
        'stage', 
        'installer',
        'source', 
        'source\data', 
        'source\docs', 
        'source\en-US', 
        'source\include', 
        'source\private', 
        'source\public', 
        'source\settings', 
        'tests', 
        'tests\integration', 
        'tests\module',
        'tests\unit'
    )
    foreach ($folder in $sourcerootfolders)
    {
        if (-not (Test-Path -Path (Join-Path -Path $path_root -ChildPath $folder)))
        {
            try
            {
                $measure = Measure-Command -Expression {
                    New-Item -Path (Join-Path -Path $path_root -ChildPath $Folder) -ItemType Directory -ErrorAction Stop
                }
                Write-CheckListItem -Message ('Default folder missing [{0}], folder successfully created' -f $Folder) -Severity Positive -Milliseconds $Measure.TotalMilliseconds
            }
            catch
            {
                Write-CheckListItem -Message ('Default folder missing [{0}], failed to create folder' -f $Folder) -Severity Negative -Milliseconds $Measure.TotalMilliseconds
                $_
            }
        }
    }
} 

Task -name 'PublishToGallery' -precondition { $buildconfig.PSGallery } -action {
    try
    {
        Write-Host
        $Continue = Confirm-Proceed -Title 'Publish to PSGallery' -Message 'Are you sure that you want to publish this module to the PSGallery?' -YesHelp 'Publish module to PSGallery' -NoHelp 'Do not publish module to PSGallery' -Default 1
        Write-Host
        if ($Continue)
        {
            $Measure = Measure-Command -Expression {
                $ExportFolder = Join-Path -Path $path_root -ChildPath ('\stage\{0}' -f $modulename) -ErrorAction Stop # "\PSSolutionModules\<ModuleName>\Export\<ModuleName>"
                Publish-Module -Path $ExportFolder -Repository 'PSGallery' -NuGetApiKey $Env:NUGET_KEY -ErrorAction Stop
            }
            Write-CheckListItem -Message 'Published module to PSGallery' -Severity Positive -Milliseconds $Measure.TotalMilliseconds
        }
        else
        {
            Write-Warning -Message 'Module was not published to PSGallery'
        }
    }
    catch
    {
        if ($_.exception.message -like 'The module*with version*cannot be published as the current version*is already available in the repository*')
        {
            Write-CheckListItem -Message 'This version is already published to PSGallery, please build a new version and try again...' -Severity Intermediate
        }
        else
        {
            Write-CheckListItem -Message 'Failed to publish module to PSGallery' -Severity Negative
            Write-Host $_
        }
    }
} 

Task -name 'ChangeLog' -action {
    Write-Host
    if (Confirm-Proceed -Title 'Update changelog' -Message 'Do you want to add a record in the changelog?' -YesHelp 'Yes' -NoHelp 'No' -Default 0)
    {
        $Measure = Measure-Command -Expression {
            try
            {
                $import_modulemanifest = Import-PowerShellDataFile -Path $path_modulemanifest -ErrorAction Stop
    
                # Request list of changes
                Write-Host

                $Changes = @()
                $Type = Show-MultiChoise -MultiChoise 'bug', 'feature', 'optimization', 'other', 'done'
                while ($Type -ne 'done')
                {
                    Write-Host -Object ('      Enter change item: ') -ForegroundColor DarkGray -NoNewline
                    $Change = Read-Host
                    $Changes += [pscustomobject]@{
                        Type    = $Type
                        Message = $Change
                    }
                    $Type = Show-MultiChoise -MultiChoise 'bug', 'feature', 'optimization', 'other', 'done'
                }

                Write-Host

                # Create changes file if it does not exist
                $PathToChangeFile = Join-Path -Path $path_root -ChildPath 'changelog.json' -ErrorAction Stop
                $EmptyJSON = "{`"Versions`": []}"
                if (-not (Test-Path $PathToChangeFile -ErrorAction Stop))
                {
                    $EmptyJSON | Out-File -FilePath $PathToChangeFile -ErrorAction Stop
                }

                # Import change file
                $ChangeFile = Get-Content -Path $PathToChangeFile  -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
                $NewVersion = [pscustomobject]@{
                    Version = ($import_modulemanifest.ModuleVersion.ToString())
                    Date    = ((Get-Date).ToString('yyyy-MM-dd'))
                    Items   = $Changes
                }
                $ChangeFile.Versions += $NewVersion

                # Export change file
                $ChangeFile | ConvertTo-Json -Depth 8 -ErrorAction Stop | Out-File $PathToChangeFile -ErrorAction Stop
            }
            catch
            {
                Throw $_
            } 
        }
        Write-CheckListItem -Message 'Changelog updated' -Severity Positive -Milliseconds $Measure.TotalMilliseconds
    }
    Write-Host
} 

Task -name 'MajorVersion' -description 'Published' -action {
    $Measure = Measure-Command -Expression {
        $NewVersion = Update-Metadata -Path $path_modulemanifest -Increment Major -Passthru
    }
    Write-CheckListItem -Message ('Module version updated in source to {0} ' -f $NewVersion) -Severity Positive -Milliseconds $Measure.TotalMilliseconds
} 

Task -name 'MinorVersion' -description 'Published' -action {
    $Measure = Measure-Command -Expression {
        $NewVersion = Update-Metadata -Path $path_modulemanifest -Increment Minor -Passthru
    }
    Write-CheckListItem -Message ('Module version updated in source to {0} ' -f $NewVersion) -Severity Positive -Milliseconds $Measure.TotalMilliseconds
} 

Task -name 'PatchVersion' -description 'Published' -action {
    $Measure = Measure-Command -Expression {
        $NewVersion = Update-Metadata -Path $path_modulemanifest -Increment Build -Passthru
    }
    Write-CheckListItem -Message ('Module version updated in source to {0} ' -f $NewVersion) -Severity Positive -Milliseconds $Measure.TotalMilliseconds
} 

Task -name 'ValidateModuleConfiguration' -action {
    switch ($buildconfig)
    {
        { $_.codecov -and -not $_.github } # Codecov depends on github
        {
            Write-CheckListItem -Severity Negative -Message 'If codecov should be used, GitHub must be enabled aswell'; throw
        }
        { $_.getpsdev -and -not $_.github } # GetPSDev depends on github
        { 
            Write-CheckListItem -Severity Intermediate -Message 'GetPSDev is enabled but github is not'
        }
        { $_.psgallery -and -not $_.github } # PSGallery depends on github
        {
            Write-CheckListItem -Severity Intermediate -Message 'PSGallery is enabled but github is not'
        }
        { $_.psgallery -and -not $_.sign } # PSGallery depends on Sign 
        {
            Write-CheckListItem -Severity Negative -Message 'If PSGallery should be used, Sign must be enabled aswell'; throw
        }
        { $_.getpsdev -and -not $_.createzip } # GetPSDev depends on createzip
        {
            Write-CheckListItem -Severity Negative -Message 'If GetPSDev should be used, CreateZIP must be enabled aswell'; throw
        }
    }
}

Task -name 'FindMissingTests' -action {
    $TestFolderPath = (Join-Path $path_root '\Tests\Unit\')
    $array_fileinfo_all_public_functions = @(Get-ChildItem -Path (Join-Path $path_root_source 'public') -Recurse -File -Filter '*.ps1')
    foreach ($File in $array_fileinfo_all_public_functions)
    {
        try
        {
            $FunctionTestFilePath = Join-Path -Path $TestFolderPath -ChildPath ('{0}.Tests.ps1' -f $File.BaseName)
            if (-not (Test-Path $FunctionTestFilePath))
            {
                Write-CheckListItem -Message ('Tests missing for {0}' -f $File.Name) -Severity Intermediate
            }
        }
        catch
        {
            Write-CheckListItem -Severity Negative -Message ('Failed to validate if tests are available for {0} with error:' -f $File.Name, $_.exception.message)
        }
    }
} 

Task -name 'UpdateFunctionPSScriptInfo' -action {

    $array_fileinfo_all_public_functions = @(Get-ChildItem -Path (Join-Path $path_root_source 'public') -Recurse -File -Filter '*.ps1')

    foreach ($File in $array_fileinfo_all_public_functions)
    {
        try
        {
            $null = Get-PSScriptInfo -FilePath $File.FullName -ErrorAction Stop
            $Result = Update-PSScriptInfo -FilePath $File.FullName
            if ($Result)
            {
                Write-CheckListItem -Message ('Updated PSScriptInfo for: {0}' -f $File.Name) -Severity Positive
            }
        }
        catch
        {
            Write-CheckListItem -Message ('Failed to update PSScriptInfo for: {0} with error: {1}' -f $File.Name, $_.exception.message)
        }
    }
} 

Task -name 'UpdateEncoding' -action {
    
    Get-ChildItem -Path $path_root_source -Recurse -Filter * -Include '*.ps1', '*.psd1', '*.psm1' | ForEach-Object {

        $EncodingObject = Get-FileEncoding -Path $PSItem.FullName

        $Encoding = $EncodingObject.details.encodingname | Select-Object -First 1

        if (-not ($Encoding -eq 'utf-8' -and $EncodingObject.details.Confidence -eq 1 -and $EncodingObject.details.Prober -eq $null))
        {
            try
            {
                $Measure = Measure-Command -Expression {
                    Convert-FileEncoding -Path $PSItem.FullName -SourceEncoding $Encoding -NewEncoding 'utf-8' -OutputWithBom -ErrorAction Stop
                }
                Write-CheckListItem -Message ('Converted encoding for file {1} from {0} to UTF8BOM ' -f $Encoding, $PSItem.Name) -Severity Positive
            }
            catch
            {
                throw $_
            }
        }
    }
} 

Task -name 'UpdateEOL' -action {
    Get-ChildItem -Path $path_root_source -Recurse -Filter * -Include '*.ps1', '*.psd1', '*.psm1' | ForEach-Object {
        
        $Result = Test-FileEndOfLine -ScriptFilePath $PSItem.FullName
        
        if (@('Windows', 'None') -notcontains $Result)
        {
            try
            {
                $measure = Measure-Command -Expression {
                    Set-FileEndOfLine -FilePath $PSItem.FullName -ErrorAction Stop
                }
                Write-CheckListItem -Message ('Successfully updated EOL for file {0} from {1} to Windows' -f $PSItem.Name, $Result) -Severity Positive -Milliseconds $measure.TotalMilliseconds
            }
            catch
            {
                Write-CheckListItem -Message ('Failed to update EOL for file {0} from {1} to Windows' -f $PSItem.Name, $Result) -Severity Negative
                $_
            }
        }
    }
} 

Task -name 'RebuildManifest' -action {
    try
    {
        Update-PSModuleManifest -Path $path_modulemanifest -ModuleName $modulename -ErrorAction Stop
    }
    catch
    {
        Write-CheckListItem -message ('Failed to rebuilded module manifest ' -f $PSItem) -Severity Negative
        $_
    }
} 

Task -name 'UpdateFunctionsToExport' {
    $manifestfunctions = Invoke-Expression ((Get-Metadata -Path $path_modulemanifest -PropertyName 'FunctionsToExport' -Passthru).Extent.Text)
    $publicfunctions = Get-ChildItem -Path "$path_root_source\public" -Recurse -File -Filter '*.ps1'

    if ($null -ne $publicfunctions)
    {
        # Replace functions to export string
        Update-Metadata -Path $path_modulemanifest -PropertyName 'FunctionsToExport' -Value $publicfunctions.BaseName
    }

    # Compare and print for information only
    Compare-StringArray -ReferenceArray $publicfunctions.BaseName -DifferencingArray $manifestfunctions -ExclusiveInReferenceArray | ForEach-Object {
        Write-CheckListItem -Message ('Added {0} to exportlist ' -f $PSItem) -Severity Positive
    }

    # Compare and print for information only
    Compare-StringArray -ReferenceArray $manifestfunctions -DifferencingArray $publicfunctions.BaseName -ExclusiveInReferenceArray | ForEach-Object {
        Write-CheckListItem -Message ('Removed {0} from exportlist ' -f $PSItem) -Severity Positive
    }
} 

Task -name 'UpdateLastBuildDate' -action {
    try
    {
        $Measure = Measure-Command -Expression {
            Update-Metadata -Path $path_modulemanifest -PropertyName 'LastBuildDate' -Value (Get-Date).ToString('yyyy-MM-dd')
        }
    }
    catch
    {
        Write-CheckListItem -Message 'Failed to update LastBuildDate in manifest' -Severity Negative
        $_
    }
} 

Task -name 'UpdateFileList' -action {
    try
    {
        $SavedErrorActionPreference = $global:ErrorActionPreference
        $global:ErrorActionPreference = 'Stop'

        $Measure = Measure-Command -Expression {
            Push-Location -Path $path_root_source
            $AllSourceFiles = Get-ChildItem -Path $path_root_source -Exclude 'logs', 'output', 'temp' | Get-ChildItem -File -Recurse
            $AllSourceFiles | ForEach-Object {
                $PSItem | Add-Member -MemberType NoteProperty -Name RelativePath -Value (
                    Resolve-Path -Path $PSItem.FullName -Relative
                )
            }
            Pop-Location
            Update-Metadata -Path $path_modulemanifest -PropertyName FileList -Value $AllSourceFiles.RelativePath
        }
    }
    catch
    {
        Write-CheckListItem -Message 'Failed to add filelist' -Severity Negative
        $_
    }
    finally
    {
        $global:ErrorActionPreference = $SavedErrorActionPreference
    }
} 

Task -name 'PesterUnitTests' -precondition { $buildconfig.RunPesterTests } -action {    
    # Pester configuration
    if (Get-ChildItem "$path_root\Tests\Unit")
    {
        $PesterConfig = [PesterConfiguration]::Default
        $PesterConfig.Run.Path = "$path_root\Tests\Unit"
        $PesterConfig.Run.PassThru = $true
        $PesterConfig.Output.Verbosity = 'Detailed'
        $Result = Invoke-Pester -Configuration $PesterConfig
    
        if ($Result.FailedCount -gt 0)
        { 
            throw
        }
        else
        {
            Write-CheckListItem -Message 'All pester tests passed' -Severity Positive
        }
    }
} 

Task -name 'PesterModuleTests' -precondition { $buildconfig.RunPesterTests } -action {    
    # Run Tests
    if (Get-ChildItem "$path_root\Tests\Module")
    {
        $PesterConfig = [PesterConfiguration]::Default
        $PesterConfig.Run.Path = "$path_root\Tests\Module"
        $PesterConfig.Run.PassThru = $true
        $PesterConfig.Output.Verbosity = 'Detailed'
        $Result = Invoke-Pester -Configuration $PesterConfig
    
        if ($Result.FailedCount -gt 0)
        { 
            throw
        }
        else
        {
            Write-CheckListItem -Message 'All pester tests passed' -Severity Positive
        }
    }
} 

Task -name 'PesterIntegrationTests' -precondition { $buildconfig.RunPesterTests } -action {   

    if (Get-ChildItem "$path_root\Tests\Integration")
    {
        $PesterConfig = [PesterConfiguration]::Default
        $PesterConfig.Run.Path = "$path_root\Tests\Integration"
        $PesterConfig.Run.PassThru = $true
        $PesterConfig.Output.Verbosity = 'Detailed'
        $Result = Invoke-Pester -Configuration $PesterConfig
    
        if ($Result.FailedCount -gt 0)
        { 
            throw
        }
        else
        {
            Write-CheckListItem -Message 'All pester tests passed' -Severity Positive
        }
    }
} 

Task -name 'CreateModuleHelpFiles' -action {
    try
    {
        $Measure = Measure-Command -Expression {
            Import-Module -Name $path_modulemanifest -Scope Global -ErrorAction Stop
            $null = New-MarkdownHelp -Module $modulename -OutputFolder (Join-Path -Path $path_root_source -ChildPath '\en-US') -Force -ErrorAction Stop
            $null = New-ExternalHelp -Path (Join-Path -Path $path_root_source -ChildPath '\en-US') -OutputPath (Join-Path -Path $path_root_source -ChildPath '\en-US') -Force -ErrorAction Stop
            Remove-Module -Name $modulename -Force -ErrorAction Stop
        }
    }
    catch
    {
        Write-CheckListItem -Message 'Failed to create module help files' -Severity Negative
        throw $_
    }
}

Task -name 'PreExportClean' -action {
    try
    {
        $Measure = Measure-Command -Expression {
            
            while ((Get-ChildItem -Path "$path_root\stage\$modulename" -Recurse))
            {
                (Get-ChildItem -Path "$path_root\stage\$modulename" -Recurse) | ForEach-Object {
                    $_ | Remove-Item -Force -Confirm:$false -ErrorAction SilentlyContinue -Recurse
                }
            }
        }
    }
    catch
    {
        throw $_
    }
} 

Task -name 'ExportCreate' -action {
    try
    {
        $Measure = Measure-Command -Expression {
            # Define and create export folder
            $import_modulemanifest = Import-PowerShellDataFile -Path $path_modulemanifest
            
            # Create export folder
            $ExportFolder = "$path_root\stage\$modulename\$($import_modulemanifest.ModuleVersion)"
            $null = New-Item -Path $ExportFolder -ErrorAction Stop -ItemType Directory

            # Copy PSD1 and PSM1
            Get-ChildItem -Path $path_root_source -File | Copy-Item -Destination $ExportFolder

            # Copy folders as-is
            $FoldersAsIs = @('data', 'docs', 'include', 'private', 'public', 'settings', 'en-US')
            foreach ($Folder in $FoldersAsIs)
            {
                Copy-Item -Path (Join-Path -Path $path_root_source -ChildPath $Folder) -Destination $ExportFolder -Recurse
            }
        }
    }
    catch
    {
        Write-CheckListItem -Message 'Failed to create stage' -Severity Negative -Milliseconds $Measure.TotalMilliseconds
        throw $_
    }
}

Task -name 'ExportSign' -precondition { $buildconfig.Sign } -action {
    try
    {
        $Cert = Get-ChildItem -Path Cert:\CurrentUser\My -CodeSigningCert | Where-Object { $_.subject -eq 'CN=HannesPalmquist' }
        if (-not $Cert)
        {
            try
            {
                $Cert = New-CodeSigningCert -Name 'HannesPalmquist' -FriendlyName 'HannesPalmquist' -ErrorAction Stop
                Write-CheckListItem -Message 'Successfully created Code Signing Certificate' -Severity Positive
            }
            catch
            {
                Write-CheckListItem -Message 'Failed to create Code Signing Certificate' -Severity Negative
                throw $_
            }
        }
        elseif ($Cert.NotAfter -lt (Get-Date))
        {
            Remove-Item -Path ('Cert:\CurrentUser\My\{0}' -f $Cert.Thumbprint) -Force
            try
            {
                $Cert = New-CodeSigningCert -Name 'HannesPalmquist' -FriendlyName 'HannesPalmquist' -ErrorAction Stop
                Write-CheckListItem -Message 'Successfully renewed Code Signing Certificate' -Severity Positive
            }
            catch
            {
                Write-CheckListItem -Message 'Failed to create Code Signing Certificate' -Severity Negative
                throw $_
            }        
        }
        if ($Cert)
        {
            $import_modulemanifest = Import-PowerShellDataFile -Path $path_modulemanifest
            
            $ExportPath = "$path_root\stage\$modulename\$($import_modulemanifest.moduleversion)"
            $ScriptsToBeSigned = Get-ChildItem -Path $ExportPath -Recurse -Include '*.ps1', '*.psm1', '*.psd1' | Where-Object { $_.FullName -notlike '*\data\*' -and $_.FullName -notlike '*\include\*' }
            foreach ($File in $ScriptsToBeSigned)
            {
                try
                {
                    $measure = Measure-Command -Expression {
                        $null = Set-AuthenticodeSignature -Certificate $cert -TimestampServer 'http://timestamp.digicert.com' -FilePath $File.FullName -ErrorAction stop  
                    }
                    Write-CheckListItem -Message ('Signed {0}  ' -f $File.Name) -Severity Positive -Milliseconds $measure.TotalMilliseconds
                }
                catch
                {
                    Write-CheckListItem -Message ('Failed to sign file {0}' -f $File.Name) -Severity Negative -Milliseconds $measure.TotalMilliseconds
                    throw $_
                }
            }    
        }
        else
        {
            Write-CheckListItem -Message 'Failed to sign script files, no cert found' -Severity Negative
        }
    }
    catch
    {
        throw $_.exception.message
    }
}

Task -name 'BuildZIP' -precondition { $buildconfig.CreateZIP }-action {
    try
    {
        $import_modulemanifest = Import-PowerShellDataFile -Path $path_modulemanifest
        
        $SourceArchive = "$path_root\stage\$modulename"
        $TargetArchive = "$path_root\release\$($import_modulemanifest.moduleversion)\$modulename.zip"
        $null = New-Item -Path "$path_root\release\$($import_modulemanifest.moduleversion)" -ItemType Directory -ErrorAction Stop
        Start-Sleep -Seconds 1
        Compress-Archive -Path $SourceArchive -DestinationPath $TargetArchive -Force
    }
    catch
    {
        Write-CheckListItem -Message 'Failed to build zip archive' -Severity Negative
        throw $_
    }
}

Task -name 'BuildInstaller' -precondition { $buildconfig.CreateInstall } -action {
    if ($ismacos -or $islinux)
    {
        Write-CheckListItem -Message 'Building installer is not supported on macos or linux by build script' -Severity Intermediate
        break
    }

    if (-not (Test-Path "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe"))
    {
        Write-CheckListItem -Message 'Inno Setup not installed' -Severity Negative
        break
    }
    
    try
    {
        $Measure = Measure-Command -Expression {
            # Reimport module manifest to get the new module version
            $import_modulemanifest = Import-PowerShellDataFile -Path $path_modulemanifest
            
            $InstallScriptTemplate = Get-Content "$path_root\installer\installscripttemplate.txt" -Raw
            $ReplaceHash = @{
                modulename      = $modulename
                moduleversion   = $import_modulemanifest.ModuleVersion
                moduleguid      = $import_modulemanifest.GUID
                path_stage      = "$path_root\stage"
                path_build      = "$path_root\release\$($import_modulemanifest.ModuleVersion)"
                apppublisher    = $buildconfig.installerconfig.AppPublisher
                apppublisherurl = $buildconfig.installerconfig.AppPublisherURL
                appsupporturl   = $buildconfig.installerconfig.AppSupportURL
                appupdatesurl   = $buildconfig.installerconfig.AppUpdatesURL
            }
            foreach ($key in $ReplaceHash.Keys)
            {
                $InstallScriptTemplate = $InstallScriptTemplate.Replace("[$Key]", $ReplaceHash[$Key])
            } 

            $InstallScriptTemplate | Out-File -FilePath "$path_root\installer\InstallScript.iss" -Encoding UTF8

            Start-Process -FilePath "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe" -ArgumentList '/Q', ('"{0}"' -f (Join-Path -Path $path_root -ChildPath 'Installer\InstallScript.iss')) -Wait -NoNewWindow
            Remove-Item -Path (Join-Path -Path $path_root -ChildPath ('\Installer\{0}' -f $modulename)) -Force -Recurse -ErrorAction SilentlyContinue
        }
        Write-CheckListItem -Message 'Compiled installer package' -Severity Positive -Milliseconds $Measure.TotalMilliseconds
    }
    catch
    {
        Write-CheckListItem -Message 'Failed to compile installer package' -Severity Negative
        throw $_
    }
} 

Task -name 'ExportPushModule' -precondition { $buildconfig.PushLocal } -action {
    try
    {
        $SourceArchive = "$path_root\stage\$modulename"

        $Destinations = @()
        if ($ismacos -or $islinux)
        {
            if (($buildconfig.os.macos -or $buildconfig.os.linux) -and $buildconfig.edition.core)
            {
                $destinations += "$HOME/.local/share/powershell/Modules"
            }
        }
        else
        {
            if ($buildconfig.os.windows -and $buildconfig.edition.desktop)
            {
                $destinations += "$([Environment]::GetFolderPath('mydocuments'))\WindowsPowerShell\Modules"
            }
            if ($buildconfig.os.windows -and $buildconfig.edition.core)
            {
                $Destinations += "$([Environment]::GetFolderPath('mydocuments'))\PowerShell\Modules"
            }
        }

    }
    catch
    {
        Write-CheckListItem -Message 'Failed to collect module destinations' -Severity Negative
        throw $_
    }
    $Destinations | ForEach-Object {
        try
        {
            Copy-Item -Path $SourceArchive -Destination $PSItem -Recurse -Force
        }
        catch
        {
            Write-CheckListItem -Message 'Failed to push to module directory' -Severity Negative
            $_
            continue
        }

        # Clean old versions
        Get-ChildItem "$PSItem\$modulename" -Directory -ErrorAction SilentlyContinue | 
        Select-Object -Property *, @{name = 'VersionObject'; exp = { [System.Version]($PSItem.BaseName) } } |
        Sort-Object -Property 'VersionObject' -Descending |
        Select-Object -Skip 5 | 
        ForEach-Object {

            # Workaround, a bug with remove-item and onedrive with enabled filesondemand caused it to fail when removing items. However 
            # using the Delete method of the file item circumvents this issue.
            $currentitem = $PSItem
            $path = $currentitem.fullname
            $Counter = 0
            while ((Get-ChildItem $path -Recurse) -and $Counter -le 10)
            {
                $AllItems = Get-ChildItem $path -Recurse | Sort-Object -Property fullname -Descending
                $AllItems | ForEach-Object {
                    try
                    {
                        $PSItem.Delete()
                    }
                    catch
                    {

                    }
                }

                $Counter++
            }
            if ($counter -gt 10)
            {
                Write-CheckListItem -Message ('Failed to remove old version: {0} with error: loop counter exceeded' -f $CurrentItem.Name) -Severity Negative
            }
            else
            {
                try
                {
                    $Item = Get-Item $path
                    $Item.Delete()
                    Write-CheckListItem -Message ('Successfully removed old version: {0}' -f $CurrentItem.Name) -Severity Positive
                }
                catch
                {
                    Write-CheckListItem -Message ('Failed to remove old version: {0} with error: {1}' -f $CurrentItem.Name, $_.exception.message) -Severity Negative
                } 
            }
        }
    }
} 

Task -name 'PostExportClean' -action {
    try
    {
        while ((Get-ChildItem -Path "$path_root\stage\$modulename" -Recurse))
        {
            (Get-ChildItem -Path "$path_root\stage\$modulename" -Recurse) | ForEach-Object {
                $_ | Remove-Item -Force -Confirm:$false -ErrorAction SilentlyContinue -Recurse
            }
            Remove-Item "$path_root\stage\$modulename"
        }
    }
    catch
    {
        Write-CheckListItem -Message 'Failed to clear export folder' -Severity Negative
        throw $_
    }
}

