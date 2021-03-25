program TestGW_SNMP_Server;

uses
  Vcl.Forms, ShellApi, Windows,
  frmMain in 'frmMain.pas' {Main},
  uPacket in 'uPacket.pas',
  frmConfig in 'frmConfig.pas' {Config},
  frmAgent in 'frmAgent.pas' {AgentForm},
  Vcl.Themes,
  Vcl.Styles,
  frmAgentDetail in 'frmAgentDetail.pas' {AgentDetailForm};

{$R *.res}

const
  MUTEX_NAME = 'TestGW_SNMP_Server';

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
  Application.CreateForm(TAgentForm, AgentForm);
  Application.Run;
end.
