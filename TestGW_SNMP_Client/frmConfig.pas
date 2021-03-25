unit frmConfig;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.IniFiles;

type
  TConfigRec = packed record
    HostIP: string;
    HostPort: Integer;
    TCPPort: Integer;
    UDPPort: Integer;
    RetryPeriod: Integer;
    HeartbeatPeriod: Integer;
    MMSI: string;
  end;

type
  TConfig = class(TForm)
  private
    { Private declarations }
  public
    procedure LoadConfig(AFileName: string);
    { Public declarations }
  end;

var
  Config: TConfig;
  ConfigInfo: TConfigRec;

implementation

{$R *.dfm}

procedure TConfig.LoadConfig(AFileName: string);
var
  iniFile: TIniFile;
begin
  if not FileExists(AFileName) then Exit;

  iniFile := TIniFile.Create(AFileName);

  try
    ConfigInfo.HostIP := iniFile.ReadString('GW', 'HOSTIP', '127.0.0.1');
    ConfigInfo.HostPort := iniFile.ReadInteger('GW', 'HOSTPORT', 13102);
    ConfigInfo.TCPPort := iniFile.ReadInteger('GW', 'TCPPORT', 50001);
    ConfigInfo.UDPPort := iniFile.ReadInteger('GW', 'UDPPORT', 60001);
    ConfigInfo.RetryPeriod := iniFile.ReadInteger('GW', 'RETRY', 5000);
    ConfigInfo.HeartbeatPeriod := iniFile.ReadInteger('GW', 'HBEAT', 10000);
    ConfigInfo.MMSI := iniFile.ReadString('GW', 'MMSI', '123456789');
  finally
    iniFile.Free;
  end;
end;

end.
