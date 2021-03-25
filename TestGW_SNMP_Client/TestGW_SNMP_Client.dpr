program TestGW_SNMP_Client;

uses
  Vcl.Forms,
  ShellApi,
  Windows,
  frmMain in 'frmMain.pas' {Main},
  uPacket in 'uPacket.pas',
  frmConfig in 'frmConfig.pas' {Config},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

const
  MUTEX_NAME = 'TestGW_SNMP_Client';

var
  mMutex: THandle;

begin
  // mutex 열기
  mMutex := OpenMutex(MUTEX_ALL_ACCESS, False, MUTEX_NAME);

  // mutex 이미 있다면 실행 중지
  if mMutex <> 0 then Exit;

  // 없으면 mutex만들고 시작
  mMutex := CreateMutex(nil, True, MUTEX_NAME);

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMain, Main);
  Application.CreateForm(TConfig, Config);
  Application.Run;
end.
