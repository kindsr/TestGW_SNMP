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
  // mutex ����
  mMutex := OpenMutex(MUTEX_ALL_ACCESS, False, MUTEX_NAME);

  // mutex �̹� �ִٸ� ���� ����
  if mMutex <> 0 then Exit;

  // ������ mutex����� ����
  mMutex := CreateMutex(nil, True, MUTEX_NAME);

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMain, Main);
  Application.CreateForm(TConfig, Config);
  Application.Run;
end.
