unit DPM.Creator.Packaging.Archiver;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  DPM.Core.Packaging.Archive,
  DPM.Core.Packaging.Archive.Writer;

type
  TDryRunPackageArchiveWriter = class(TInterfacedObject, IPackageArchiveWriter)
  private
    FIcons : TObjectList<TFileItems>;
    FFiles : TObjectList<TFileItems>;
    FBasePath : string;
    function GetFiles: TObjectList<TFileItems>;
  public
    procedure SetBasePath(const path : string);
    function WriteMetaDataFile(const stream : TStream) : Boolean;
    function AddIcon(const filePath : string) : boolean;
    function AddFile(const filePath : string) : Boolean; overload;
    function AddFile(const fileName : string; const archiveFileName : string) : boolean; overload;
    function AddFiles(const files : System.TArray < System.string > ) : Boolean;
    constructor Create;
    destructor Destroy; override;

    function GetArchiveName : string;
    function GetArchivePath : string;
    function Open(const fileName : string) : boolean;
    procedure Close;
    function Exists : boolean;
    function IsArchive : boolean;
    function GetLastErrorString : string;
  end;

implementation

{ TDryRunackageArchiveWriter }

function TDryRunPackageArchiveWriter.AddFile(const filePath: string): Boolean;
var
  filenameItem : TFileItems;
begin
  filenameItem := TFileItems.Create;
  filenameItem.filename := filePath;
  FFiles.Add(filenameItem);
  Result := True;
end;

function TDryRunPackageArchiveWriter.AddFile(const fileName, archiveFileName: string): boolean;
var
  filenameItem : TFileItems;
begin
  filenameItem := TFileItems.Create;
  filenameItem.archiveFilename := archiveFileName;
  filenameItem.filename := filename;
  FFiles.Add(filenameItem);
  Result := True;
end;

function TDryRunPackageArchiveWriter.AddFiles(const files: System.TArray<System.string>): Boolean;
var
  filename : TFileItems;
  i: Integer;
begin
  for i := 0 to High(files) do
  begin
    filename := TFileItems.Create;
    filename.filename := files[i];
    FFiles.Add(filename);
  end;

  Result := True;
end;

function TDryRunPackageArchiveWriter.AddIcon(const filePath: string): boolean;
var
  icon : TFileItems;
begin
  icon := TFileItems.Create;
  icon.filename := filePath;
  FIcons.Add(icon);
  Result := True;
end;

procedure TDryRunPackageArchiveWriter.Close;
begin

end;

constructor TDryRunPackageArchiveWriter.Create;
begin
  FIcons := TObjectList<TFileItems>.Create;
  FFiles := TObjectList<TFileItems>.Create;
end;

destructor TDryRunPackageArchiveWriter.Destroy;
begin
  FreeAndNil(FIcons);
  FreeAndNil(FFiles);
end;

function TDryRunPackageArchiveWriter.Exists: boolean;
begin

end;

function TDryRunPackageArchiveWriter.GetArchiveName: string;
begin

end;

function TDryRunPackageArchiveWriter.GetArchivePath: string;
begin

end;

function TDryRunPackageArchiveWriter.GetFiles: TObjectList<TFileItems>;
begin
  Result := FFiles;
end;

function TDryRunPackageArchiveWriter.GetLastErrorString: string;
begin

end;

function TDryRunPackageArchiveWriter.IsArchive: boolean;
begin

end;

function TDryRunPackageArchiveWriter.Open(const fileName: string): boolean;
begin

end;

procedure TDryRunPackageArchiveWriter.SetBasePath(const path: string);
begin
  FBasePath := path;
end;

function TDryRunPackageArchiveWriter.WriteMetaDataFile(const stream: TStream): Boolean;
begin

end;

end.
