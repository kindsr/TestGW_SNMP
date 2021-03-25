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
  Application.CreateForm(TAgentForm, AgentForm);
  Application.Run;
end.
