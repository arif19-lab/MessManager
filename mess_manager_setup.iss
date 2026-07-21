[Setup]
AppId={{D1A2B3C4-E5F6-7890-1234-567890ABCDEF}
AppName=Mess Manager
AppVersion=1.0.0
AppPublisher=Arif19 Lab
AppPublisherURL=https://github.com/arif19-lab/MessManager
AppSupportURL=https://github.com/arif19-lab/MessManager
AppUpdatesURL=https://github.com/arif19-lab/MessManager
DefaultDirName={autopf}\Mess Manager
DisableProgramGroupPage=yes
; Output directory where the final Setup.exe will be saved
OutputDir=.\build\windows\installer
OutputBaseFilename=MessManager_Setup_v1.0.13
SetupIconFile=.\windows\runner\resources\app_icon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Copy the main executable
Source: ".\build\windows\x64\runner\Release\mess_manager.exe"; DestDir: "{app}"; Flags: ignoreversion
; Copy all DLLs and support files
Source: ".\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; Exclude the .pdb files (debugging symbols) to keep installer size small
; Source: ".\build\windows\x64\runner\Release\*.pdb"; DestDir: "{app}"; Flags: dontcopy

[Icons]
Name: "{autoprograms}\Mess Manager"; Filename: "{app}\mess_manager.exe"
Name: "{autodesktop}\Mess Manager"; Filename: "{app}\mess_manager.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\mess_manager.exe"; Description: "{cm:LaunchProgram,Mess Manager}"; Flags: nowait postinstall skipifsilent
