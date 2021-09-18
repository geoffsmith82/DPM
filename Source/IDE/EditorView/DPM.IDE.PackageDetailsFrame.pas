{***************************************************************************}
{                                                                           }
{           Delphi Package Manager - DPM                                    }
{                                                                           }
{           Copyright � 2019 Vincent Parrett and contributors               }
{                                                                           }
{           vincent@finalbuilder.com                                        }
{           https://www.finalbuilder.com                                    }
{                                                                           }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}

unit DPM.IDE.PackageDetailsFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.pngimage,
  Vcl.Themes,
  ToolsAPI,
  DPM.Core.Types,
  DPM.Core.Configuration.Interfaces,
  DPM.Core.Package.Interfaces,
  DPM.Core.Logging,
  DPM.IDE.Logger,
  DPM.Core.Options.Search,
  DPM.IDE.Details.Interfaces,
  DPM.IDE.PackageDetailsPanel,
  DPM.IDE.IconCache,
  DPM.IDE.Types,
  DPM.Controls.VersionGrid,
  Spring.Container,
  Spring.Collections,
  VSoft.Awaitable,
  SVGInterfaces;

{$I ..\DPMIDE.inc}

type
  TPackageDetailsFrame = class(TFrame, IPackageDetailsView)
    sbPackageDetails : TScrollBox;
    pnlPackageId : TPanel;
    pnlInstalled : TPanel;
    lblPackageId : TLabel;
    imgPackageLogo : TImage;
    pnlVersion : TPanel;
    Label1 : TLabel;
    txtInstalledVersion : TEdit;
    btnUninstall : TButton;
    lblVersionTitle : TLabel;
    cboVersions : TComboBox;
    btnInstallOrUpdate : TButton;
    procedure cboVersionsMeasureItem(Control : TWinControl; Index : Integer; var Height : Integer);
    procedure cboVersionsDrawItem(Control : TWinControl; Index : Integer; Rect : TRect; State : TOwnerDrawState);
    procedure cboVersionsChange(Sender : TObject);
    procedure btnInstallOrUpdateClick(Sender : TObject);
    procedure btnUninstallClick(Sender : TObject);
  private
    FContainer : TContainer;
    FIconCache : TDPMIconCache;
    FPackageSearcher : IPackageSearcher;
    FPackageMetaData : IPackageSearchResultItem;
    FDetailsPanel : TPackageDetailsPanel;
    FCurrentTab : TDPMCurrentTab;
    FCancellationTokenSource : ICancellationTokenSource;
    FRequestInFlight : boolean;
    FVersionsDelayTimer : TTimer;
    FConfiguration : IConfiguration;
    FLogger : IDPMIDELogger;
    FClosing : boolean;
    FIncludePreRelease : boolean;
    FPackageInstalledVersion : string;
    FPackageId : string;
    FProjectFile : string;
    FCurrentPlatform : TDPMPlatform;

    FIDEStyleServices : TCustomStyleServices;
  protected
    function GetIncludePreRelease : boolean;
    procedure SetIncludePreRelease(const Value : boolean);
    procedure VersionsDelayTimerEvent(Sender : TObject);
    procedure OnDetailsUriClick(Sender : TObject; const uri : string; const element : TDetailElement);
    procedure Loaded; override;

  public
    constructor Create(AOwner : TComponent); override;
    procedure Init(const container : TContainer; const iconCache : TDPMIconCache; const config : IConfiguration; const packageSearcher : IPackageSearcher; const projectOrGroup : IOTAProject);
    procedure Configure(const value : TDPMCurrentTab; const preRelease : boolean);
    procedure SetPackage(const package : IPackageSearchResultItem);
    procedure SetPlatform(const platform : TDPMPlatform);
    procedure ViewClosing;
    procedure ThemeChanged(const StyleServices : TCustomStyleServices {$IFDEF THEMESERVICES}; const ideThemeSvc : IOTAIDEThemingServices{$ENDIF});
    property IncludePreRelease : boolean read FIncludePreRelease write SetIncludePreRelease;
  end;

implementation

{$R *.dfm}

uses
  System.StrUtils,
  WinApi.ShellApi,
  SVGGraphic,
  DPM.Core.Utils.Strings,
  DPM.Core.Dependency.Version,
  DPM.Core.Repository.Interfaces,
  DPM.Core.Options.Install,
  DPM.Core.Options.UnInstall,
  DPM.Core.Package.Installer.Interfaces,
  DPM.IDE.Constants;

  { TPackageDetailsFrame }

procedure TPackageDetailsFrame.btnInstallOrUpdateClick(Sender : TObject);
var
  packageInstaller : IPackageInstaller;
  options : TInstallOptions;
  installResult : boolean;
  newVersion : TPackageVersion;
  sVersion : string;
  context : IPackageInstallerContext;
begin
  btnInstallOrUpdate.Enabled := false;
  installResult := false;
  try
    if FRequestInFlight then
      FCancellationTokenSource.Cancel;

    while FRequestInFlight do
      Application.ProcessMessages;
    FCancellationTokenSource.Reset;
    FLogger.Clear;
    FLogger.StartInstall(FCancellationTokenSource);
    FPackageSearcher.InstallStarting;

    if btnInstallOrUpdate.Caption = 'Update' then
    begin
      //get the version from the current item.
      sVersion := cboVersions.Items[cboVersions.ItemIndex];
      if TStringUtils.StartsWith(sVersion, cLatestPrerelease, true) then
        Delete(sVersion, 1, Length(cLatestPrerelease))
      else if TStringUtils.StartsWith(sVersion, cLatestStable, true) then
        Delete(sVersion, 1, Length(cLatestStable));
      newVersion := TPackageVersion.Parse(sVersion);
    end
    else
      newVersion := TPackageVersion.Parse(FPackageMetaData.Version);


    FLogger.Information('Installing package ' + FPackageMetaData.Id + ' - ' + newVersion.ToString + ' [' + FPackageSearcher.GetCurrentPlatform + ']');


    options := TInstallOptions.Create;
    options.ConfigFile := FConfiguration.FileName;
    options.PackageId := FPackageMetaData.Id;
    options.Version := newVersion;
    options.ProjectPath := FProjectFile;
    options.Platforms := [ProjectPlatformToDPMPlatform(FPackageSearcher.GetCurrentPlatform)];
    options.Prerelease := FIncludePreRelease;
    options.CompilerVersion := IDECompilerVersion;

    //make sure we have the correct metadata for the new version
    FPackageMetaData := FPackageSearcher.SearchForPackages(options).FirstOrDefault;


    //install will fail if a package is already installed, unless you specify force.
    if btnInstallOrUpdate.Caption = 'Update' then
      options.Force := true;

    packageInstaller := FContainer.Resolve<IPackageInstaller>;
    context := FContainer.Resolve<IPackageInstallerContext>;
    installResult := packageInstaller.Install(FCancellationTokenSource.Token, options, context);
    if installResult then
    begin
//      FPackageMetaData.InstalledVersion := FPackageMetaData.Version;
      FPackageMetaData.Installed := true;
      FPackageInstalledVersion := FPackageMetaData.Version;
      FLogger.Information('Package ' + FPackageMetaData.Id + ' - ' + newVersion.ToString + ' [' + FPackageSearcher.GetCurrentPlatform + '] installed.');
      FPackageSearcher.PackageInstalled(FPackageMetaData);
      SetPackage(FPackageMetaData);
    end
    else
      FLogger.Error('Package ' + FPackageMetaData.Id + ' - ' + newVersion.ToString + ' [' + FPackageSearcher.GetCurrentPlatform + '] did not install.');

  finally
    btnInstallOrUpdate.Enabled := true;
    FLogger.EndInstall(installResult);
  end;



end;

procedure TPackageDetailsFrame.btnUninstallClick(Sender : TObject);
var
  packageInstaller : IPackageInstaller;
  context : IPackageInstallerContext;
  options : TUnInstallOptions;
  uninstallResult : boolean;
begin
  btnUninstall.Enabled := false;
  uninstallResult := false;
  try
    if FRequestInFlight then
      FCancellationTokenSource.Cancel;

    while FRequestInFlight do
      Application.ProcessMessages;
    FCancellationTokenSource.Reset;
    FLogger.Clear;
    FLogger.StartUnInstall(FCancellationTokenSource);
    FPackageSearcher.InstallStarting;
    FLogger.Information('UnInstalling package ' + FPackageMetaData.Id + ' - ' + FPackageMetaData.Version + ' [' + FPackageSearcher.GetCurrentPlatform + ']');

    options := TUnInstallOptions.Create;
    options.ConfigFile := FConfiguration.FileName;
    options.PackageId := FPackageMetaData.Id;
    options.Version := TPackageVersion.Parse(FPackageMetaData.Version);
    options.ProjectPath := FProjectFile;
    options.Platforms := [ProjectPlatformToDPMPlatform(FPackageSearcher.GetCurrentPlatform)];
    options.CompilerVersion := IDECompilerVersion;

    packageInstaller := FContainer.Resolve<IPackageInstaller>;
    context := FContainer.Resolve<IPackageInstallerContext>;
    uninstallResult := packageInstaller.UnInstall(FCancellationTokenSource.Token, options, context);
    if uninstallResult then
    begin
//      FPackageMetaData.InstalledVersion := FPackageMetaData.Version;
      FPackageMetaData.Installed := true;
      FPackageInstalledVersion := FPackageMetaData.Version;
      FLogger.Information('Package ' + FPackageMetaData.Id + ' - ' + FPackageMetaData.Version + ' [' + FPackageSearcher.GetCurrentPlatform + '] uninstalled.');
      FPackageSearcher.PackageUninstalled(FPackageMetaData);
      SetPackage(nil);
    end
    else
      FLogger.Error('Package ' + FPackageMetaData.Id + ' - ' + FPackageMetaData.Version + ' [' + FPackageSearcher.GetCurrentPlatform + '] did not uninstall.');

  finally
    btnUninstall.Enabled := true;
    FLogger.EndUnInstall(uninstallResult);
  end;
end;

procedure TPackageDetailsFrame.cboVersionsChange(Sender : TObject);
var
  searchOptions : TSearchOptions;
  package : IPackageSearchResultItem;
  sVersion : string;
begin
  searchOptions := FPackageSearcher.GetSearchOptions;
  searchOptions.SearchTerms := FPackageMetaData.Id;

  sVersion := cboVersions.Items[cboVersions.ItemIndex];
  if TStringUtils.StartsWith(sVersion, cLatestPrerelease, true) then
    Delete(sVersion, 1, Length(cLatestPrerelease))
  else if TStringUtils.StartsWith(sVersion, cLatestStable, true) then
    Delete(sVersion, 1, Length(cLatestStable));

  searchOptions.Version := TPackageVersion.Parse(sVersion);
  searchOptions.Prerelease := true;
  searchOptions.Commercial := true;
  searchOptions.Trial := true;

  FPackageSearcher.SearchForPackagesAsync(searchOptions)
  .OnException(
    procedure(const e : Exception)
    begin
      FRequestInFlight := false;
      if FClosing then
        exit;
      FLogger.Error(e.Message);
    end)
  .OnCancellation(
    procedure
    begin
      FRequestInFlight := false;
      //if the view is closing do not do anything else.
      if FClosing then
        exit;
      FLogger.Debug('Cancelled searching for packages.');
    end)
  .Await(
    procedure(const theResult : IList<IPackageSearchResultItem>)
    begin
      FRequestInFlight := false;
      //if the view is closing do not do anything else.
      if FClosing then
        exit;
      //        FLogger.Debug('Got search results.');
      package := theResult.FirstOrDefault;
      SetPackage(package);
    end);
end;

procedure TPackageDetailsFrame.cboVersionsDrawItem(Control : TWinControl; Index : Integer; Rect : TRect; State : TOwnerDrawState);
begin
  cboVersions.Canvas.FillRect(Rect);

  if (cboVersions.Items.Count = 0) or (index < 0) then
    exit;

  if odComboBoxEdit in State then
    cboVersions.Canvas.TextOut(Rect.Left + 1, Rect.Top + 1, cboVersions.Items[Index]) //Visual state of the text in the edit control
  else
    cboVersions.Canvas.TextOut(Rect.Left + 2, Rect.Top, cboVersions.Items[Index]); //Visual state of the text(items) in the deployed list


  if odComboBoxEdit in State then
    exit;

  if Integer(cboVersions.Items.Objects[index]) <> 0 then
  begin
    cboVersions.Canvas.Pen.Color := clGray;
    cboVersions.Canvas.MoveTo(Rect.Left, Rect.Bottom - 1);
    cboVersions.Canvas.LineTo(Rect.Right, Rect.Bottom - 1);
  end;


end;

procedure TPackageDetailsFrame.cboVersionsMeasureItem(Control : TWinControl; Index : Integer; var Height : Integer);
begin
  if (cboVersions.Items.Count = 0) or (index < 0) then
    exit;
  if cboVersions.Items.Objects[index] <> nil then
    Inc(Height, 4);
end;

procedure TPackageDetailsFrame.Configure(const value : TDPMCurrentTab; const preRelease : boolean);
begin
  if (FCurrentTab <> value) or (FIncludePreRelease <> preRelease) then
  begin
    FPackageMetaData := nil;
    FPackageId := '';
    FDetailsPanel.SetDetails(nil);
    FCurrentTab := value;
    FIncludePreRelease := preRelease;
    case FCurrentTab of
      TDPMCurrentTab.Installed :
        begin
          btnInstallOrUpdate.Caption := 'Update';
        end;
      TDPMCurrentTab.Updates :
        begin
          btnInstallOrUpdate.Caption := 'Update';

        end;
      TDPMCurrentTab.Search :
        begin
          btnInstallOrUpdate.Caption := 'Install';

        end;
      TDPMCurrentTab.Conflicts : ;
    end;
    SetPackage(nil);
  end;

end;

constructor TPackageDetailsFrame.Create(AOwner : TComponent);
begin
  inherited;
  //not published in older versions, so get removed when we edit in older versions.
  {$IFDEF STYLEELEMENTS}
  StyleElements := [seFont];
  {$ENDIF}
  FDetailsPanel := TPackageDetailsPanel.Create(AOwner);
  FDetailsPanel.ParentColor := false;
  FDetailsPanel.ParentBackground := false;
  FDetailsPanel.DoubleBuffered := true;
  FDetailsPanel.Align := alTop;
  FDetailsPanel.Height := 200;
  FDetailsPanel.Top := pnlVErsion.Top + pnlVErsion.Top + 20;
  FDetailsPanel.OnUriClick := Self.OnDetailsUriClick;
  FDetailsPanel.Parent := sbPackageDetails;

  FCurrentPlatform := TDPMPlatform.UnknownPlatform;
  FVersionsDelayTimer := TTimer.Create(AOwner);
  FVersionsDelayTimer.Interval := 200;
  FVersionsDelayTimer.Enabled := false;
  FVersionsDelayTimer.OnTimer := VersionsDelayTimerEvent;
  FCancellationTokenSource := TCancellationTokenSourceFactory.Create;

end;

function TPackageDetailsFrame.GetIncludePreRelease: boolean;
begin
  result := FIncludePreRelease;
end;

procedure TPackageDetailsFrame.Init(const container : TContainer; const iconCache : TDPMIconCache; const config : IConfiguration; const packageSearcher : IPackageSearcher; const projectOrGroup : IOTAProject);
begin
  FContainer := container;
  FIconCache := iconCache;
  FConfiguration := config;
  FLogger := FContainer.Resolve<IDPMIDELogger>;
  FPackageSearcher := packageSearcher;
  FProjectFile := projectOrGroup.FileName;
  SetPackage(nil);

end;


procedure TPackageDetailsFrame.Loaded;
begin
  inherited;
  //  sbPackageDetails.Color := Self.Color;
  //  sbPackageDetails.ParentBackground := false;
  //
  //  FDetailsPanel.ParentColor := true;
  //  FDetailsPanel.ParentBackground := false;
  //  FDetailsPanel.Color := Self.Color;
  //  FDetailsPanel.Font.Assign(Self.Font);

end;

procedure TPackageDetailsFrame.OnDetailsUriClick(Sender : TObject; const uri : string; const element : TDetailElement);
begin
  case element of
    deNone : ;
    deLicense,
    deProjectUrl,
    deReportUrl : ShellExecute(Application.Handle, 'open', PChar(uri), nil, nil, SW_SHOWNORMAL);
    deTags : ;
  end;

end;

procedure TPackageDetailsFrame.SetIncludePreRelease(const Value : boolean);
begin
  if FIncludePreRelease <> Value then
  begin
    FIncludePreRelease := Value;
    SetPackage(FPackageMetaData);
  end;
end;

procedure TPackageDetailsFrame.SetPackage(const package : IPackageSearchResultItem);
var
  logo : IPackageIconImage;
  bFetchVersions : boolean;
  graphic : TGraphic;
begin
  FVersionsDelayTimer.Enabled := false;
  if FRequestInFlight then
    FCancellationTokenSource.Cancel;

  FPackageMetaData := package;

  if package <> nil then
  begin
    if (package.Id <> FPackageId) then
    begin
      bFetchVersions := true;
      FPackageId := package.Id;
      if package.Installed then
        FPackageInstalledVersion := package.Version
      else
        FPackageInstalledVersion := '';
    end
    else
    begin
      //same id, so we might just be displaying a new version.
      //since we're just getting the item from the feed rather than the project
      //it won't have installed or installed version set.
      if package.Installed then
        FPackageInstalledVersion := package.Version
      else
      begin
        if package.Version = FPackageInstalledVersion then
          package.Installed := true;
      end;
      bFetchVersions := false; //we already have them.
    end;

    lblPackageId.Caption := package.Id;
    logo := FIconCache.Request(package.Id);
    if logo = nil then
      logo := FIconCache.Request('missing_icon');
    if logo <> nil then
    begin
      graphic := logo.ToGraphic;
      try
        imgPackageLogo.Picture.Assign(graphic);
        imgPackageLogo.Visible := true;
      finally
        graphic.Free;
      end;
    end
    else
      imgPackageLogo.Visible := false;

    case FCurrentTab of
      TDPMCurrentTab.Search :
        begin
          pnlInstalled.Visible := FPackageInstalledVersion <> '';
          if pnlInstalled.Visible then
          begin
            btnInstallOrUpdate.Caption := 'Update'
          end
          else
          begin
            btnInstallOrUpdate.Caption := 'Install';
          end;
        end;
      TDPMCurrentTab.Installed :
        begin
          pnlInstalled.Visible := true;
          btnInstallOrUpdate.Caption := 'Update';
        end;
      TDPMCurrentTab.Updates :
        begin
          pnlInstalled.Visible := true;
          btnInstallOrUpdate.Caption := 'Update';
        end;
      TDPMCurrentTab.Conflicts : ;
    end;

    if FPackageInstalledVersion <> '' then
      txtInstalledVersion.Text := FPackageInstalledVersion
    else
      txtInstalledVersion.Text := 'not installed';
    btnInstallOrUpdate.Enabled := (not package.Installed) or (package.LatestVersion <> package.Version);

    sbPackageDetails.Visible := true;

    FVersionsDelayTimer.Enabled := bFetchVersions;
  end
  else
  begin
    sbPackageDetails.Visible := false;
    //    pnlPackageId.Visible := false;
    //    pnlInstalled.Visible := false;
    //    pnlVErsion.Visible := false;
  end;

  FDetailsPanel.SetDetails(package);
end;

procedure TPackageDetailsFrame.SetPlatform(const platform : TDPMPlatform);
begin
  if platform <> FCurrentPlatform then
  begin

  end;
end;

procedure TPackageDetailsFrame.ThemeChanged(const StyleServices : TCustomStyleServices {$IFDEF THEMESERVICES}; const ideThemeSvc : IOTAIDEThemingServices{$ENDIF});
begin
  {$IFDEF THEMESERVICES}
  FIDEStyleServices := StyleServices;
  ideThemeSvc.ApplyTheme(Self);
  {$ELSE}
  FIDEStyleServices := Vcl.Themes.StyleServices;
  {$ENDIF}

  sbPackageDetails.Color := FIDEStyleServices.GetSystemColor(clWindow);

  {$IF CompilerVersion >= 32.0}
  sbPackageDetails.ParentColor := false;
  sbPackageDetails.ParentBackground := false;
  sbPackageDetails.StyleElements := [seFont];
  sbPackageDetails.Color := FIDEStyleServices.GetSystemColor(clWindow);

  pnlPackageId.StyleElements := [seFont];
  pnlPackageId.Color := sbPackageDetails.Color;

  pnlInstalled.StyleElements := [seFont];
  pnlInstalled.Color := sbPackageDetails.Color;

  pnlVersion.StyleElements := [seFont];
  pnlVersion.Color := sbPackageDetails.Color;

  FDetailsPanel.StyleElements := [seFont];
  FDetailsPanel.Color := sbPackageDetails.Color;
  FDetailsPanel.Font.Color := FIDEStyleServices.GetSystemColor(clWindowText);

  {$ELSE}
  sbPackageDetails.Color := FIDEStyleServices.GetSystemColor(clWindow);
  FDetailsPanel.Color := FIDEStyleServices.GetSystemColor(clWindow);
  FDetailsPanel.Font.Color := FIDEStyleServices.GetSystemColor(clWindowText);

  {$IFEND}

end;

procedure TPackageDetailsFrame.VersionsDelayTimerEvent(Sender : TObject);
var
  versions : IList<TPackageVersion>;
  repoManager : IPackageRepositoryManager;
  options : TSearchOptions;
  config : IConfiguration;
  lStable : string;
  lPre : string;
  sVersion : string;
  sInstalledVersion : string;
begin
  FVersionsDelayTimer.Enabled := false;
  if FRequestInFlight then
    FCancellationTokenSource.Cancel;
  while FRequestInFlight do
    Application.ProcessMessages;
  FCancellationTokenSource.Reset;

  cboVersions.Clear;
  repoManager := FContainer.Resolve<IPackageRepositoryManager>;

  options := TSearchOptions.Create;
  options.CompilerVersion := IDECompilerVersion;
  options.AllVersions := true;
  options.SearchTerms := FPackageMetaData.Id;
  options.Prerelease := FIncludePreRelease;

  options.Platforms := [FCurrentPlatform];

  config := FConfiguration;

  sInstalledVersion := FPackageInstalledVersion;

  TAsync.Configure<IList<TPackageVersion>> (
    function(const cancelToken : ICancellationToken) : IList<TPackageVersion>
    begin
      result := repoManager.GetPackageVersions(cancelToken, options, config);
    end, FCancellationTokenSource.Token)
  .OnException(
    procedure(const e : Exception)
    begin
      FRequestInFlight := false;
      if FClosing then
        exit;
      FLogger.Error(e.Message);
    end)
  .OnCancellation(
    procedure
    begin
      FRequestInFlight := false;
      //if the view is closing do not do anything else.
      if FClosing then
        exit;
      FLogger.Debug('Cancelled getting package versions.');
    end)
  .Await(
    procedure(const theResult : IList<TPackageVersion>)
    var
      version : TPackageVersion;
    begin
      FRequestInFlight := false;
      //if the view is closing do not do anything else.
      if FClosing then
        exit;
      versions := theResult;
      FLogger.Debug('Got package versions .');
      cboVersions.Items.BeginUpdate;
      try
        cboVersions.Clear;

        if versions.Any then
        begin
          if options.Prerelease then
          begin
            version := versions.FirstOrDefault(
              function(const value : TPackageVersion) : boolean
              begin
                result := not value.IsStable;
              end);
            if not version.IsEmpty then
              lPre := cLatestPrerelease + version.ToStringNoMeta;
          end;
          version := versions.FirstOrDefault(
            function(const value : TPackageVersion) : boolean
            begin
              result := value.IsStable;
            end);
          if not version.IsEmpty then
            lStable := cLatestStable + version.ToStringNoMeta;
          if (lStable <> '') and (lPre <> '') then
          begin
            cboVersions.Items.Add(lPre);
            cboVersions.Items.AddObject(lStable, TObject(1));
          end
          else if lStable <> '' then
            cboVersions.Items.AddObject(lStable, TObject(1))
          else if lPre <> '' then
            cboVersions.Items.AddObject(lPre, TObject(1));
          for version in versions do
            cboVersions.Items.Add(version.ToStringNoMeta);

          if FCurrentTab = TDPMCurrentTab.Installed then
            cboVersions.ItemIndex := cboVersions.Items.IndexOf(sInstalledVersion)
          else
            cboVersions.ItemIndex := 0;

          sVersion := cboVersions.Items[cboVersions.ItemIndex];
          if TStringUtils.StartsWith(sVersion, cLatestPrerelease, true) then
            Delete(sVersion, 1, Length(cLatestPrerelease))
          else if TStringUtils.StartsWith(sVersion, cLatestStable, true) then
            Delete(sVersion, 1, Length(cLatestStable));

          btnInstallOrUpdate.Enabled := sVersion <> sInstalledVersion;
        end;
      finally
        cboVersions.Items.EndUpdate;
      end;

    end);

end;

procedure TPackageDetailsFrame.ViewClosing;
begin
  FClosing := true;
  FPackageSearcher := nil;
  FCancellationTokenSource.Cancel;
end;

end.
