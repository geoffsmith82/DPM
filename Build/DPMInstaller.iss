; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "DPM Package Manager"
#ifndef MyAppVersion
  #define MyAppVersion "0.1.10-alpha"
#endif
#define MyAppPublisher "The Delphi Package Manager Project"
#define HelpURL "https://docs.delphi.dev"
#define SupportURL "https://github.com/DelphiPackageManager/DPM/issues"
#define UpdatesURL "https://github.com/DelphiPackageManager/DPM/releases"
#ifndef OutputFileName
  #define OutputFileName "DPMSetup-0.0.0.0"
#endif


[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{7762853B-A873-4F11-AAD1-2D6EAE938562}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#HelpURL}
AppSupportURL={#SupportURL}
AppUpdatesURL={#UpdatesURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
DisableWelcomePage=no
LicenseFile=..\LICENSE.txt
; need admin if we want to 
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
OutputBaseFilename={#OutputFileName}
Compression=lzma
SolidCompression=yes
WizardStyle=modern
UsedUserAreasWarning=no
ChangesEnvironment= CheckChangesPath 
SetupIconFile=..\Source\Images\dpm.ico
UninstallDisplayIcon={app}\dpm.exe

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Components]
Name: XE2; Description: Delphi XE2 IDE Support; Types: full; check: IsDelphiInstalled('9.0');
Name: XE3; Description: Delphi XE3 IDE Support; Types: full; check: IsDelphiInstalled('10.0');
Name: XE4; Description: Delphi XE4 IDE Support; Types: full; check: IsDelphiInstalled('11.0');
Name: XE5; Description: Delphi XE5 IDE Support; Types: full; check: IsDelphiInstalled('12.0');
Name: XE6; Description: Delphi XE6 IDE Support; Types: full; check: IsDelphiInstalled('14.0');
Name: XE7; Description: Delphi XE7 IDE Support; Types: full; check: IsDelphiInstalled('15.0');
Name: XE8; Description: Delphi XE8 IDE Support; Types: full; check: IsDelphiInstalled('16.0');
Name: Seattle-10.0; Description: Delphi 10.0 IDE Support; Types: full; check: IsDelphiInstalled('17.0');
Name: Berlin-10.1;  Description: Delphi 10.1 IDE Support; Types: full; check: IsDelphiInstalled('18.0');
Name: Tokyo-10.2;   Description: Delphi 10.2 IDE Support; Types: full; check: IsDelphiInstalled('19.0');
Name: Rio-10.3;     Description: Delphi 10.3 IDE Support; Types: full; check: IsDelphiInstalled('20.0');
Name: Sydney-10.4;  Description: Delphi 10.4 IDE Support; Types: full; check: IsDelphiInstalled('21.0');
Name: Alexandria-11.0;  Description: Delphi 11 IDE Support; Types: full; check: IsDelphiInstalled('22.0');
Name: Athens-12.0;  Description: Delphi 12 IDE Support; Types: full; check: IsDelphiInstalled('23.0');


[Tasks]
Name: AddToPath; Description: "Add dpm folder to PATH Environment variable"; GroupDescription: Environment:;


[Files]
Source: "..\Output\dpm.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\Output\DPM.IDE.XE2.dll"; DestDir: "{app}"; Flags: ignoreversion; Components : XE2
Source: "..\Output\DPM.IDE.XE3.dll"; DestDir: "{app}"; Flags: ignoreversion; Components : XE3
Source: "..\Output\DPM.IDE.XE4.dll"; DestDir: "{app}"; Flags: ignoreversion; Components : XE4
Source: "..\Output\DPM.IDE.XE5.dll"; DestDir: "{app}"; Flags: ignoreversion; Components : XE5
Source: "..\Output\DPM.IDE.XE6.dll"; DestDir: "{app}"; Flags: ignoreversion; Components : XE6
Source: "..\Output\DPM.IDE.XE7.dll"; DestDir: "{app}"; Flags: ignoreversion; Components : XE7
Source: "..\Output\DPM.IDE.XE8.dll"; DestDir: "{app}"; Flags: ignoreversion; Components : XE8

Source: "..\Output\DPM.IDE.D100.dll"; DestDir: "{app}"; Flags: ignoreversion; Components : Seattle-10.0
Source: "..\Output\DPM.IDE.D101.dll"; DestDir: "{app}"; Flags: ignoreversion; Components : Berlin-10.1
Source: "..\Output\DPM.IDE.D102.dll"; DestDir: "{app}"; Flags: ignoreversion; Components : Tokyo-10.2
Source: "..\Output\DPM.IDE.D103.dll"; DestDir: "{app}"; Flags: ignoreversion; Components : Rio-10.3
Source: "..\Output\DPM.IDE.D104.dll"; DestDir: "{app}"; Flags: ignoreversion; Components : Sydney-10.4
Source: "..\Output\DPM.IDE.D110.dll"; DestDir: "{app}"; Flags: ignoreversion; Components : Alexandria-11.0
Source: "..\Output\DPM.IDE.D120.dll"; DestDir: "{app}"; Flags: ignoreversion; Components : Athens-12.0

[Registry]
Root: HKCU; Subkey: "SOFTWARE\Embarcadero\BDS\9.0\Experts";  ValueType: string; ValueName: "DPM"; ValueData: "{app}\DPM.IDE.XE2.dll"; Components: XE2; Flags: uninsdeletevalue
Root: HKCU; Subkey: "SOFTWARE\Embarcadero\BDS\10.0\Experts"; ValueType: string; ValueName: "DPM"; ValueData: "{app}\DPM.IDE.XE3.dll"; Components: XE3; Flags: uninsdeletevalue
Root: HKCU; Subkey: "SOFTWARE\Embarcadero\BDS\11.0\Experts"; ValueType: string; ValueName: "DPM"; ValueData: "{app}\DPM.IDE.XE4.dll"; Components: XE4; Flags: uninsdeletevalue
Root: HKCU; Subkey: "SOFTWARE\Embarcadero\BDS\12.0\Experts"; ValueType: string; ValueName: "DPM"; ValueData: "{app}\DPM.IDE.XE5.dll"; Components: XE5; Flags: uninsdeletevalue
Root: HKCU; Subkey: "SOFTWARE\Embarcadero\BDS\14.0\Experts"; ValueType: string; ValueName: "DPM"; ValueData: "{app}\DPM.IDE.XE6.dll"; Components: XE6; Flags: uninsdeletevalue
Root: HKCU; Subkey: "SOFTWARE\Embarcadero\BDS\15.0\Experts"; ValueType: string; ValueName: "DPM"; ValueData: "{app}\DPM.IDE.XE7.dll"; Components: XE7; Flags: uninsdeletevalue
Root: HKCU; Subkey: "SOFTWARE\Embarcadero\BDS\16.0\Experts"; ValueType: string; ValueName: "DPM"; ValueData: "{app}\DPM.IDE.XE8.dll"; Components: XE8; Flags: uninsdeletevalue

Root: HKCU; Subkey: "SOFTWARE\Embarcadero\BDS\17.0\Experts"; ValueType: string; ValueName: "DPM"; ValueData: "{app}\DPM.IDE.D100.dll"; Components: Seattle-10.0; Flags: uninsdeletevalue
Root: HKCU; Subkey: "SOFTWARE\Embarcadero\BDS\18.0\Experts"; ValueType: string; ValueName: "DPM"; ValueData: "{app}\DPM.IDE.D101.dll"; Components: Berlin-10.1;  Flags: uninsdeletevalue
Root: HKCU; Subkey: "SOFTWARE\Embarcadero\BDS\19.0\Experts"; ValueType: string; ValueName: "DPM"; ValueData: "{app}\DPM.IDE.D102.dll"; Components: Tokyo-10.2;   Flags: uninsdeletevalue
Root: HKCU; Subkey: "SOFTWARE\Embarcadero\BDS\20.0\Experts"; ValueType: string; ValueName: "DPM"; ValueData: "{app}\DPM.IDE.D103.dll"; Components: Rio-10.3;     Flags: uninsdeletevalue
Root: HKCU; Subkey: "SOFTWARE\Embarcadero\BDS\21.0\Experts"; ValueType: string; ValueName: "DPM"; ValueData: "{app}\DPM.IDE.D104.dll"; Components: Sydney-10.4;  Flags: uninsdeletevalue
Root: HKCU; Subkey: "SOFTWARE\Embarcadero\BDS\22.0\Experts"; ValueType: string; ValueName: "DPM"; ValueData: "{app}\DPM.IDE.D110.dll"; Components: Alexandria-11.0;  Flags: uninsdeletevalue
Root: HKCU; Subkey: "SOFTWARE\Embarcadero\BDS\23.0\Experts"; ValueType: string; ValueName: "DPM"; ValueData: "{app}\DPM.IDE.D120.dll"; Components: Athens-12.0;  Flags: uninsdeletevalue

[Code]


function IsAppRunning(const FileName : string): Boolean;
var
    FSWbemLocator: Variant;
    FWMIService   : Variant;
    FWbemObjectSet: Variant;
begin
    Result := false;
    FSWbemLocator := CreateOleObject('WBEMScripting.SWBEMLocator');
    FWMIService := FSWbemLocator.ConnectServer('', 'root\CIMV2', '', '');
    FWbemObjectSet :=
      FWMIService.ExecQuery(
        Format('SELECT Name FROM Win32_Process Where Name="%s"', [FileName]));
    Result := (FWbemObjectSet.Count > 0);
    FWbemObjectSet := Unassigned;
    FWMIService := Unassigned;
    FSWbemLocator := Unassigned;
end;

function IsDelphiInstalled(const bdsvers: string ): boolean;
var
  app : string; 
begin
  result := RegQueryStringValue( HKCU, 'SOFTWARE\Embarcadero\BDS\' + bdsvers, 'App', app );
end;
  
const EnvironmentKey = 'Environment';

procedure EnvAddPath(instlPath: string);
var
    Paths: string;
begin
    { Retrieve current path (use empty string if entry not exists) }
    if not RegQueryStringValue(HKEY_CURRENT_USER, EnvironmentKey, 'Path', Paths) then
        Paths := '';

    if Paths = '' then
        Paths := instlPath + ';'
    else
    begin
        { Skip if string already found in path }
        if Pos(';' + Uppercase(instlPath) + ';',  ';' + Uppercase(Paths) + ';') > 0 then exit;
        if Pos(';' + Uppercase(instlPath) + '\;', ';' + Uppercase(Paths) + ';') > 0 then exit;

        { Append App Install Path to the end of the path variable }
        Log(Format('Right(Paths, 1): [%s]', [Paths[length(Paths)]]));
        if Paths[length(Paths)] = ';' then
            Paths := Paths + instlPath + ';'  { don't double up ';' in env(PATH) }
        else
            Paths := Paths + ';' + instlPath + ';' ;
    end;

    { Overwrite (or create if missing) path environment variable }
    if RegWriteStringValue(HKEY_CURRENT_USER, EnvironmentKey, 'Path', Paths)
    then Log(Format('The [%s] added to PATH: [%s]', [instlPath, Paths]))
    else Log(Format('Error while adding the [%s] to PATH: [%s]', [instlPath, Paths]));
end;

procedure EnvRemovePath(instlPath: string);
var
    Paths: string;
    P, Offset, DelimLen: Integer;
begin
    { Skip if registry entry not exists }
    if not RegQueryStringValue(HKEY_CURRENT_USER, EnvironmentKey, 'Path', Paths) then
        exit;

    { Skip if string not found in path }
    DelimLen := 1;     { Length(';') }
    P := Pos(';' + Uppercase(instlPath) + ';', ';' + Uppercase(Paths) + ';');
    if P = 0 then
    begin
        { perhaps instlPath lives in Paths, but terminated by '\;' }
        DelimLen := 2; { Length('\;') }
        P := Pos(';' + Uppercase(instlPath) + '\;', ';' + Uppercase(Paths) + ';');
        if P = 0 then exit;
    end;

    { Decide where to start string subset in Delete() operation. }
    if P = 1 then
        Offset := 0
    else
        Offset := 1;
    { Update path variable }
    Delete(Paths, P - Offset, Length(instlPath) + DelimLen);

    { Overwrite path environment variable }
    if RegWriteStringValue(HKEY_CURRENT_USER, EnvironmentKey, 'Path', Paths)
    then Log(Format('The [%s] removed from PATH: [%s]', [instlPath, Paths]))
    else Log(Format('Error while removing the [%s] from PATH: [%s]', [instlPath, Paths]));
end;


function CheckChangesPath : boolean;
begin
  result := WizardIsTaskSelected('AddToPath')
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
    if (CurStep = ssPostInstall) and IsTaskSelected('AddToPath') then 
      EnvAddPath(ExpandConstant('{app}'));
end;


procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  case CurUninstallStep of
    usAppMutexCheck: ; 
    usUninstall: ; 
    usPostUninstall: 
    begin
      EnvRemovePath(ExpandConstant('{app}'));
    end;
    usDone : ;
  end;
end;

function InitializeSetup: boolean;
begin
  Result := not IsAppRunning('bds.exe');
  if not Result then
    MsgBox('RAD Studio is running. Please close it before running the installer ', mbError, MB_OK);
end;

