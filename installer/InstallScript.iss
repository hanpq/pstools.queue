[Setup]
AppId={{ 8b96f3d4-ebf3-4c6a-a99a-1c5392ecc8da }}
AppName=pstools.queue
AppVersion=1.1
AppPublisher=
AppPublisherURL=
AppSupportURL=
AppUpdatesURL=
DefaultDirName={userdocs}\WindowsPowerShell\Modules\pstools.queue
DisableDirPage=yes
DefaultGroupName=pstools.queue
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
OutputDir=C:\Users\hanpalmq\OneDrive\DEV\Powershell\modules\pstools.queue\release\1.1
OutputBaseFilename=pstools.queue.1.1.Installer
Compression=lzma
SolidCompression=yes
WizardStyle=modern
Uninstallable=yes
SetupIconFile=C:\Users\hanpalmq\OneDrive\DEV\Powershell\modules\pstools.queue\stage\pstools.queue\1.1\data\appicon.ico

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "C:\Users\hanpalmq\OneDrive\DEV\Powershell\modules\pstools.queue\stage\pstools.queue\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist

[Icons]
Name: "{userdesktop}\pstools.queue"; Filename: "{sys}\WindowsPowerShell\v1.0\powershell.exe"; Parameters: "-executionpolicy bypass -noexit -noprofile -file ""{app}\1.1\data\banner.ps1"""; IconFilename: "{app}\1.1\data\AppIcon.ico"

[Run]
Filename: "Powershell.exe"; Parameters: "-executionpolicy bypass -noexit -noprofile -file ""{app}\1.1\data\banner.ps1"""; Description: "Run pstools.queue"; Flags: postinstall nowait


