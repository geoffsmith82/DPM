unit DPM.Core.Spec.Writer;

interface

uses
  DPM.Core.Types,
  DPM.Core.Logging,
  DPM.Core.Options.Spec,
  DPM.Core.Spec.Interfaces;

type
  TPackageSpecWriter = class(TInterfacedObject, IPackageSpecWriter)
  private
    FLogger : ILogger;
    FSpec : IPackageSpec;
  protected
    function CreateSpecFile(const options : TSpecOptions) : Boolean;
  public
    constructor Create(const logger : ILogger; spec: IPackageSpec);
    procedure SaveToFile(filename: string);
  end;

implementation

uses
  System.IOUtils,
  System.SysUtils,
  JSONDataObjects,
  DPM.Core.Project.Interfaces;

{ TPackageSpecWriter }

constructor TPackageSpecWriter.Create(const logger : ILogger; spec: IPackageSpec);
begin
  FLogger := logger;
  FSpec := spec;
end;

function TPackageSpecWriter.CreateSpecFile(const options : TSpecOptions) : Boolean;
begin
  result := false;

end;

procedure TPackageSpecWriter.SaveToFile(filename: string);
var
  relativePath: String;
begin
  JsonSerializationConfig.IndentChar := ' ';

  if not TPath.IsRelativePath(Fspec.MetaData.Icon) then
  begin
    relativePath := ExtractRelativePath(ExtractFilePath(filename), filename);
    Fspec.MetaData.Icon := relativePath;
  end;

  TFile.WriteAllText(Filename, Fspec.ToJson);
end;

end.

