

BeforeAll {
    $ModuleSourceRootPath = Resolve-Path -Path ('{0}\..\..\source' -f $PSScriptRoot)
    $ModuleName = (Get-Item -Path $ModuleSourceRootPath).Parent.BaseName

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
                } catch
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

    function Get-PSScriptInfo
    {
        <#
      .DESCRIPTION
        Collect and parse psscriptinfo from file
      .PARAMETER FilePath
        Defines the path to the file from which to get psscriptinfo from.
      .EXAMPLE
        Get-PSScriptInfo -FilePath C:\temp\file.ps1
        Description of example
    #>

        [CmdletBinding()] # Enabled advanced function support
        param(
            [ValidateScript( { Test-Path -Path $_ -PathType Leaf })][Parameter(Mandatory)][string]$FilePath
        )

        PROCESS
        {
            try
            {
                $PSScriptInfo = [ordered]@{ }
                New-Variable astTokens -Force
                New-Variable astErr -Force
                $null = [System.Management.Automation.Language.Parser]::ParseFile($FilePath, [ref]$astTokens, [ref]$astErr)
                $FileContent = $astTokens.where{ $_.kind -eq 'comment' -and $_.text.Replace("`r", '').Split("`n")[0] -like '<#PSScriptInfo*' } | Select-Object -expand text
                $FileContent = $FileContent.Replace("`r", '').Split("`n")
                if ($FileContent)
                {
                    $FileContent | Select-Object -Skip 1 | ForEach-Object {
                        $CurrentRow = $PSItem
                        if ($CurrentRow.Trim() -like '.*')
                        {
                            # New attribute found, extract attribute name
                            $Attribute = $CurrentRow.Split('.')[1].Split(' ')[0]

                            # Check if row has value
                            if ($CurrentRow.Trim().Replace($Attribute, '').TrimStart('.').Trim().Length -gt 0)
                            {

                                # Value on same row
                                $Value = $CurrentRow.Trim().Split(' ', 2)[1].Trim()

                                # String Arrays
                                if (@() -contains $Attribute)
                                {
                                    $Value = $Value.Split(',').Trim()
                                }
                                # Datetime
                                if (@('CREATEDDATE' -contains $Attribute))
                                {
                                    $Value = $Value -as [datetime]
                                }
                                # System version
                                if (@('VERSION' -contains $Attribute))
                                {
                                    $Value = $Value -as [system.version]
                                }
                                # guid
                                if (@('GUID' -contains $Attribute))
                                {
                                    $Value = $Value -as [guid]
                                }

                                if (@('UNITTEST' -contains $Attribute))
                                {
                                    if ($Value -eq 'false')
                                    {
                                        $Value = $false
                                    } elseif ($Value -eq 'true')
                                    {
                                        $Value = $true
                                    } else
                                    {
                                        $Value = $null
                                    }
                                }

                                # Add attribute and value to PSScriptInfo
                                $null = $PSScriptInfo.Add($Attribute, $Value)
                            } else
                            {
                                # If no value is provided populate PSScriptInfo with attribute and an empty collection as value
                                $null = $PSScriptInfo.Add($Attribute, [collections.arraylist]::New())
                            }
                        } elseif ($CurrentRow -notlike '*#>*')
                        {
                            # If row is not an attribute and PSScriptInfo is not terminated add row as value in attribute collection
                            $null = $PSScriptInfo.$Attribute.Add($CurrentRow.Trim())
                        }

                    }
                    Write-Output $PSScriptInfo 
                } else
                {
                    Write-Error -Message 'No valid PSScriptInfo was found in file'
                }
            } catch
            {
                Write-Error -Message 'No valid PSScriptInfo was found in file' -ErrorRecord $_
            }
        }
    }   
    
    function Split-String
    {
        <#
    .DESCRIPTION
        Functions that wraps around the .net string method Split() or the powershell operator -split
    .PARAMETER InputString
        Defines the string to split
    .PARAMETER Separator
        Defines the separator to use when splitting the string. When the switch parameter -DoNotUseRegex
        is specified only a simple string or character will work as separator. If the -DoNotUseRegex parameter
        is omitted there are several options for the separator parameter value.

        -- Simple string
        -- Regex string ""
        -- Scriptblock that evalutates to true for the separator, ie {$_ -eq 'a' -or $_ -eq 'b'}
    .PARAMETER DoNotUseRegex
        Specifies if the .net string method split() is used or the powershell operator -split is used.
    .PARAMETER Options
        Defines regex options to use.
    .PARAMETER Count
        Defines the number of strings to return. Strings extending this value will be joined into a single string. Defaults to 0 which returns all items
    .EXAMPLE
        Split-String -InputString 'abc,def,ghi,jkl' -Separator ',' -Count 2 -DoNotUseRegex
        Splits the string 'abc,def,ghi,jkl' with the separator ','. It retreive the first two items and
        concatinates the rest with the same separator.
    .EXAMPLE
        Split-String -InputString 'abc,def,ghi,jkl' -Separator ',' -DoNotUseRegex
        Splits the string 'abc,def,ghi,jkl' with the separator ','.
    .EXAMPLE
        Split-String -InputString 'abc,def,ghi,jkl' -Separator ','
        Splits the string 'abc,def,ghi,jkl' using the regex expression ','
    .EXAMPLE
        Split-String -InputString 'abc,def,ghi,jkl' -Separator ',' -Count 2
        Splits the string 'abc,def,ghi,jkl' using the regex expression ',' and retrreives the first two results
    .EXAMPLE
        Split-String -InputString 'abc,def,ghi,jkl' -Separator ',' -Options 'IgnorePatternWhitespace'
        Splits the string 'abc,def,ghi,jkl' using the regex expression ',' and alters the regex options to IgnorePatternWhitespace (ignorecase is default)
    #>
        [CmdletBinding(DefaultParameterSetName = 'Regex')]
        param(
            [Parameter(Mandatory, ValueFromPipeline)]
            [string[]]$InputString,

            [Parameter(Mandatory)]
            [object]$Separator,

            [Parameter(ParameterSetName = 'NoRegex')]
            [switch]$DoNotUseRegex,

            [Parameter(ParameterSetName = 'Regex')]
            [System.Text.RegularExpressions.RegexOptions]$Options = 'IgnoreCase',

            [int]$Count = 0
        )
        begin
        {
            if ($Count -gt 0) { $Count++ }
        }
        process
        {
            $InputString | ForEach-Object {
                $CurrentString = $_
                switch ($PSCmdlet.ParameterSetName)
                {
                    'NoRegex'
                    {
                        if ($Count)
                        {
                            $Result = $CurrentString.Split($Separator)
                            $Result | Select-Object -First $Count
                            ($Result | Select-Object -Skip $Count) -join $Separator
                        } else
                        {
                            $CurrentString.Split($Separator)
                        }
                    }
                    'Regex'
                    {
                        $CurrentString -split $Separator, $Count, $Options
                    }
                }
            }
        }
        end {}
    }    
    #endregion

}
Describe -Name 'Module content' -Tag 'Module' -Fixture {
    Context -Name 'Module Root Folders' -Fixture {
        # Define test cases
        $TestCases = @(
            @{Foldername = 'data' }
            @{Foldername = 'docs' }
            @{Foldername = 'include' }
            @{Foldername = 'private' }
            @{Foldername = 'public' }
            @{Foldername = 'settings' }
        )
        It -Name '<Foldername> folder exists' -TestCases $TestCases -Test {
            Join-Path -Path $ModuleSourceRootPath -ChildPath $FolderName | Should -Exist
        }
    }

    Context -Name 'Mandatory Files' -Fixture {
        # Define test cases
        $ModuleSourceRootPath = Resolve-Path -Path ('{0}\..\..\Source' -f $PSScriptRoot)
        $ModuleName = (Get-Item -Path $ModuleSourceRootPath).Parent.BaseName
        $TestCases = @(
            @{File = ('\{0}.psd1' -f $ModuleName) }
            @{File = ('\{0}.psm1' -f $ModuleName) }
            @{File = ('\include\module.utility.functions.ps1') }
            @{File = ('\settings\config.json') }
        )
        It -Name '<File> file exists' -TestCases $TestCases -Test {
            Join-Path -Path $ModuleSourceRootPath -ChildPath $File | Should -Exist
        }
    }

    Context -Name 'Module Manifest' -Fixture {
        It -Name 'Test-ModuleManifest' -Test {
            { Test-ModuleManifest -Path (Join-Path -Path $ModuleSourceRootPath -ChildPath ('\{0}.psd1' -f $ModuleName)) } | Should -Not -Throw
        }
        It -Name 'Final FunctionsToExportValidation' -Test {
            $FunctionsToExportExpected = @(Get-ChildItem -Path (Join-Path -Path $ModuleSourceRootPath -ChildPath 'public') -Recurse -File -Filter '*.ps1' | Where-Object { $PSItem.BaseName -notlike '*.Tests' } | Select-Object -ExpandProperty BaseName)
            $ModuleManifest = Import-PowerShellDataFile -Path (Join-Path -Path $ModuleSourceRootPath -ChildPath ('\{0}.psd1' -f $ModuleName))
            Compare-StringArray -ReferenceArray $ModuleManifest.FunctionsToExport -DifferencingArray $FunctionsToExportExpected -ExclusiveInBoth | Should -Be $null
        }
    }
}

Describe -Name 'Foreach script file' -Tag 'Module' -Fixture {

    # Define testcases
    $ModuleSourceRootPath = Resolve-Path -Path ('{0}\..\..\Source' -f $PSScriptRoot)
    $ScriptFilesToAnalyze = Get-ChildItem -Path $ModuleSourceRootPath -Recurse -File -Include '*.ps1', '*.psm1' | Where-Object { $PSItem.Directory.Name -eq 'Source' -or $PSItem.Directory.FullName -like '*\source\public*' -or $PSItem.Directory.FullName -like '*\source\private*' }
    $TestCases = $ScriptFilesToAnalyze | ForEach-Object { 
        [hashtable]@{
            FileName  = $PSItem.Name
            File      = $PSItem
            CodeRaw   = Get-Content -Path $PSItem.FullName -Raw -Encoding UTF8
            CodeArray = Get-Content -Path $PSItem.FullName -ReadCount 0 -Encoding UTF8
        }
    }
    $FunctionTestCases = $TestCases | Where-Object { $PSItem.File.Name -like '*-*.ps1' -and $PSItem.File.Name -notlike '*.Tests.*' }

    It -Name 'Script Analyzer: <FileName>' -TestCases $TestCases -Test {
        $ModuleTestsAnalyzerSettingsPath = Join-Path -Path $PSScriptRoot -ChildPath 'Module.Tests.AnalyzerSettings.psd1'
        $Result = Invoke-ScriptAnalyzer -Path $File.FullName -Settings $ModuleTestsAnalyzerSettingsPath
        if ($Result)
        {
            foreach ($Entry in $Result)
            {
                switch ($Entry.Severity)
                {
                    'Warning' { Write-Host '      [~] ' -ForegroundColor Yellow -NoNewline; Write-Host ('{3} | {0} | {1}:{2} | {4}' -f $Entry.RuleName, $Entry.Line, $Entry.Column, $Entry.ScriptName, $Entry.Message) -ForegroundColor Yellow }
                    'Error' { Write-Host '      [-] ' -ForegroundColor Red -NoNewline; Write-Host ('{3} | {0} | {1}:{2} | {4}' -f $Entry.RuleName, $Entry.Line, $Entry.Column, $Entry.ScriptName, $Entry.Message) -ForegroundColor Red }
                    'Information' { Write-Host '      [*] ' -NoNewline; Write-Host ('{3} | {0} | {1}:{2} | {4}' -f $Entry.RuleName, $Entry.Line, $Entry.Column, $Entry.ScriptName, $Entry.Message) }
                    default { Write-Host '      [?] ' -ForegroundColor Cyan -NoNewline; Write-Host ('{3} | {0} | {1}:{2} | {4}' -f $Entry.RuleName, $Entry.Line, $Entry.Column, $Entry.ScriptName, $Entry.Message)-ForegroundColor Cyan }
                }
            } 
            if ($Result.Where{ $PSItem.Severity -eq 'Error' }.Count -gt 0)
            {
                $Result.Where{ $PSItem.Severity -eq 'Error' }.Count | Should -Be 0
            }
        }
    }

    It -Name 'Encoding: <FileName>' -TestCases $TestCases -Test {
        Test-Encoding -Path $File.FullName | Should -Be $true
    }

    It -Name 'Parse script file: <FileName>' -TestCases $TestCases -Test {
        { [Scriptblock]::Create($CodeRaw) } | Should -Not -Throw
    }

    It -Name 'Legacy snippets: <FileName>' -TestCases $TestCases -Test {
        $LegacyCodeSnippets = @{
            'DefaultParameterValuesWritePSScriptStartTime'  = "\`$PSDefaultParameterValues\['Write-PS\*:ScriptStartTime'\] = Get-Date"
            'ClearPSOldLogs'                                = 'Clear-PSOldLogs'
            'LegacyConfigFileReference'                     = "\`$Config_"
            'LegacyCommentBlocks_Triangle'                  = '▼'
            'LegacyCommentBlocks_Square'                    = '◆'
            'LegacyWriteSuccess_TargetObject'               = 'Write-Success.*-TargetObject'
            'LegacyWriteProgress_StartDateTime'             = 'Write-Progress.*-StartDateTime'
            'LegacyWriteProgress_CountAll'                  = 'Write-Progress.*-CountAll'
            'LegacyWriteInformation_TargetObject'           = 'Write-Information.*-TargetObject'
            'LegacyWriteVerbose_TargetObject'               = 'Write-Verbose.*-TargetObject'
            'LegacyWriteDebug_TargetObject'                 = 'Write-Debug.*-TargetObject'
            'LegacyWriteChange_Action'                      = 'Write-Change.*-Action'
            'LegacyWritePSLog'                              = 'Write-PSLog'
            'LegacyModuleVariable_Dir_Module'               = "\`$Dir_Module"
            'LegacyModuleVariable_File'                     = "\`$File_"
            'LegacyScriptHelp_Synopsis'                     = '\.SYNOPSIS'
            'LegacyScriptHelp_Functionality'                = '\.FUNCTIONALITY'
            'LegacyScriptHelp_Component'                    = '\.COMPONENT'
            'LegacyScriptHelp_Role'                         = '\s+\.ROLE\s+'
            'LegacyPSScriptInfo_TAGS'                       = '\.TAGS'
            'LegacyPSScriptInfo_LICENSEURI'                 = '\.LICENSEURI'
            'LegacyPSScriptInfo_PROJECTURI'                 = '\.PROJECTURI'
            'LegacyPSScriptInfo_ICONURI'                    = '\.ICONURI'
            'LegacyPSScriptInfo_EXTERNALMODULEDEPENDENCIES' = '\.EXTERNALMODULEDEPENDENCIES'
            'LegacyPSScriptInfo_REQUIREDSCRIPTS'            = '\.REQUIREDSCRIPTS'
            'LegacyPSScriptInfo_EXTERNALSCRIPTDEPENDENCIES' = '\.EXTERNALSCRIPTDEPENDENCIES'
            'LegacyPSScriptInfo_RELEASENOTES'               = '\.RELEASENOTES'
            'LegacyPSScriptInfo_PRIVATEDATA'                = '\s+\.PRIVATEDATA\s+'
            'LegacyPSScriptInfo_ORDEROFEXECUTION'           = '\.ORDEROFEXECUTION'
        }
        $MatchedLegacyCodeSnippets = foreach ($Entry in $LegacyCodeSnippets.Keys)
        {
            if ($CodeRaw -match $LegacyCodeSnippets[$Entry])
            {
                # Exclude module psm1 file from ModuleName check
                if (-not ($File.Extension -eq '.psm1' -and $Entry -eq 'LegacyModuleVariable_ModuleName'))
                {
                    $Entry
                }
            }
        }
        $MatchedLegacyCodeSnippets | Should -Be $null        
    }

    It -Name 'End Of Line Type: <FileName>' -TestCases $TestCases -Test {
        $Result = Test-FileEndOfLine -RawCode $CodeRaw
        ($Result -eq 'Windows' -or $Result -eq 'None') | Should -BeTrue
    }

    It -Name 'PSScriptInfo: <FileName>' -TestCases $FunctionTestCases -Test {
        $CodeRaw.SubString(0, 30) | Should -BeLike "*<#PSScriptInfo*`r`n*"
    }
    It -Name 'ScriptHelp|+.DESCRIPTION: <FileName>' -TestCases $FunctionTestCases -Test {
        $File.FullName | Should -FileContentMatch '.DESCRIPTION'
    }
    It -Name 'ScriptHelp|+.EXAMPLE: <FileName>' -TestCases $FunctionTestCases -Test {
        $File.FullName | Should -FileContentMatch '.EXAMPLE'
    }
    It -Name 'AdvancedFunction: <FileName>' -TestCases $FunctionTestCases -Test {
        $File.FullName | Should -FileContentMatch '\[CmdletBinding\(.*\)\]'
        $File.FullName | Should -FileContentMatch 'param\s*\('
    }
    It -Name 'Import PSScriptInfo: <FileName>' -TestCases $FunctionTestCases -Test {
        { Get-PSScriptInfo -FilePath $File.FullName } | Should -Not -Throw
    }
    It -Name 'Function Name and Filename Match: <FileName>' -TestCases $FunctionTestCases -Test {
        $FunctionDefinitionLine = $CodeArray | Where-Object { $_ -like 'function*' }
        $FunctionDefinitionLine | Split-String -Separator ' ' | Select-Object -First 1 -Skip 1 | Should -Be $File.BaseName        
    }
    It -Name 'OnlyOneFunctionPerFile: <FileName>'  -TestCases $FunctionTestCases -Test {
        $CodeArray.Where( { $_ -like 'function*' }).Count | Should -Be 1
    }
    It -Name 'FunctionHasInlineHelpSection: <FileName>'  -TestCases $FunctionTestCases -Test {
        $CodeRaw | Should -BeLike "*<#*.DESCRIPTION*.EXAMPLE*`#>*"
    }
    It -Name 'OnlyFunctionDefinitions: <FileName>' -TestCases $FunctionTestCases -Test {
        $AST = [Scriptblock]::Create($CodeRaw)        
        $NonFunctionDefinitions = $AST.AST.EndBlock.Statements | ForEach-Object {
            $CurrentStatement = $_
            if (($CurrentStatement.Extent.Text.Split("`n")[0].Trim()) -notlike ('function {0}*' -f ($CurrentStatement.Name)))
            {
                $CurrentStatement
            }
        }
        $NonFunctionDefinitions | Should -Be $null
    }
}

Describe -Name 'Setting files' -Tag 'Module' -Fixture {
    Context 'Importing setting files' {

        $ModuleSourceRootPath = Resolve-Path -Path ('{0}\..\..\Source' -f $PSScriptRoot)
        $ConfigsToTest = Get-ChildItem -Path (Join-Path -Path $ModuleSourceRootPath -ChildPath 'settings') -File -Recurse

        $TestCases = $ConfigsToTest | ForEach-Object { 
            [hashtable]@{
                FileName = $PSItem.Name
                File     = $PSItem
            }
        }

        It ('Parse <FileName>') -TestCases $TestCases {
            switch ($Config.Extension)
            {
                '.json'
                {
                    { Get-Content -Path $File.FullName | ConvertFrom-Json } | Should -Not -Throw
                }
                '.csv'
                {
                    { Import-Csv -Path $File.FullName -Delimiter ';' } | Should -Not -Throw
                }
            }
        }
    }    
}

Describe -Name 'Nested modules' -Tag 'Module' -Fixture {
    Context -Name 'Importing modules' -Fixture {
        $ModuleSourceRootPath = Resolve-Path -Path ('{0}\..\..\Source' -f $PSScriptRoot)
        $ModulesToTest = Get-ChildItem -Path (Join-Path -Path $ModuleSourceRootPath -ChildPath 'include') -Directory
        $TestCases = $ModulesToTest | ForEach-Object {
            [hashtable]@{ModuleName = $PSItem.Name; Module = $PSItem }
        }
        if ($null -ne $TestCases)
        {
            It -Name 'Importing module: <ModuleName>' -TestCases $TestCases -Test {
                Remove-Module -Name $Module.Name -ErrorAction SilentlyContinue -Force
                { Import-Module $Module.FullName -Force } | Should -Not -Throw
            }
        }
    }
}

