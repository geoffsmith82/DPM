﻿unit DPM.IDE.InstallerContext;

interface

uses
  Spring.Collections,
  DPM.Core.Types,
  DPM.Core.Logging,
  DPM.Core.Dependency.Interfaces,
  DPM.Core.Package.Installer.Interfaces,
  DPM.Core.Package.InstallerContext;
type

  TDPMIDEPackageInstallerContext = class(TCorePackageInstallerContext, IPackageInstallerContext)
  private
  protected
    function IsDesignPackageInstalled(const packageName: string; out platform : TDPMPlatform; out project : string): Boolean;override;
    function RegisterDesignPackage(const platform: TDPMPlatform; const packageFile: string; const dependsOn: IList<string>; out errorMessage : string) : boolean;override;
    procedure Clear;override;
  public
    constructor Create(const logger : ILogger);override;
  end;

implementation

{ TDPMIDEPackageInstallerContext }

constructor TDPMIDEPackageInstallerContext.Create(const logger: ILogger);
begin
  inherited Create(logger);

end;


function TDPMIDEPackageInstallerContext.IsDesignPackageInstalled(const packageName: string; out platform : TDPMPlatform; out project : string): Boolean;
begin
  result := false;
end;

function TDPMIDEPackageInstallerContext.RegisterDesignPackage(const platform: TDPMPlatform; const packageFile: string; const dependsOn: IList<string>; out errorMessage : string) : boolean;
begin
  result := false;
end;

procedure TDPMIDEPackageInstallerContext.Clear;
begin
  inherited;
end;

end.

