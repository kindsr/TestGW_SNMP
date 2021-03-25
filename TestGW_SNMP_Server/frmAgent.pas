unit frmAgent;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.IniFiles, scControls,
  scModernControls, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.WinXCtrls, System.ImageList,
  Vcl.ImgList, frmAgentDetail;

const
  POS_X1 = 8;
  POS_X2 = 89;
  POX_X3 = 170;
  POS_Y1 = 8;
  POS_Y2 = 72;
  BTN_WIDTH = 78;
  BTN_HEIGHT = 58;
  CMD_INDEX = 2;

type
  TAgent = record
    name: string;
    terminal: string;
    counter: string;
    kioskNo: string;
    kioskIp: string;
    left: Integer;
    top: Integer;
  end;

type
  TCounter = record
    number: string;
    index: string;
    agents: array of TAgent;
  end;

type
  TAgentForm = class(TForm)
    ImageList1: TImageList;
    sbPanel: TScrollBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure RelativePanel1DockDrop(Sender: TObject; Source: TDragDockObject;
      X, Y: Integer);
    procedure RelativePanel1DockOver(Sender: TObject; Source: TDragDockObject;
      X, Y: Integer; State: TDragState; var Accept: Boolean);
  private
    FStartDragPosOffset: TPoint;
    procedure btnDynClick(Sender: TObject);
    procedure LoadAgent(agentList: TStringList);
    procedure MakeButtons(agentList: TStringList);
    procedure btnDynMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LoadCounter(counterList: TStringList);
    procedure MakePanels(counterList: TStringList);
    { Private declarations }
  public
    btnDyn: array of TButton;
    pnlDyn: array of TRelativePanel;
    function FindCounterControl(counter: string): TControl;
    function FindAgentControl(counter, agent: string): TControl;
    function SetAgentStatus(agentName: string; agentStatus: Integer;
      sentence: string): Boolean;
    { Public declarations }
  end;

var
  AgentForm: TAgentForm;
  AgentList, CounterList: TStringList;
  ini : TMemIniFile;
  Agents: array of TAgent;
  Counters: array of TCounter;

implementation

uses frmMain;

{$R *.dfm}

procedure TAgentForm.FormCreate(Sender: TObject);
begin
  AgentList := TStringList.Create;
  CounterList := TStringList.Create;
  LoadCounter(CounterList);
end;

procedure TAgentForm.FormDestroy(Sender: TObject);
begin
  if Assigned(CounterList) then
    CounterList.Destroy;
  if Assigned(AgentList) then
    AgentList.Destroy;
end;

procedure TAgentForm.LoadCounter(counterList: TStringList);
var
  i: Integer;
begin
  ini := TMemIniFile.Create('.\Agents\CounterList.ini');

  try
    ini.ReadSectionValues('COUNTER', counterList);
  finally
    FreeAndNil(ini);
  end;

  MakePanels(counterList);
  LoadAgent(AgentList);
end;

procedure TAgentForm.MakePanels(counterList: TStringList);
var
  i, j: Integer;
  nextPosLeft, nextPosTop: Integer;
  s: TArray<string>;
begin
  SetLength(Counters, counterList.Count);
  SetLength(pnlDyn, counterList.Count);

  for i := 0 to counterList.Count-1 do
  begin
    s := counterList[i].Split(['=']);
    Counters[i].number := s[0];
    SetLength(Counters[i].agents, 0);

    pnlDyn[i] := TRelativePanel.Create(Self);
    nextPosLeft := 10*(i+1) + 100*i;
    nextPosTop := 30;
    with TLabel.Create(nil) do
    begin
      Parent := sbPanel;
      AutoSize := False;
      Alignment := taCenter;
      Width := 100;
      Height := 26;
      Left := nextPosLeft;
      Top := 8;
      Name := Format('lblDyn%d',[i]);
      Caption := Counters[i].number;
      Visible := True;
      BringToFront;
    end;

    with pnlDyn[i] do
    begin
      Parent := sbPanel;
      ParentBackground := False;
      BorderStyle := bsSingle;
      BorderWidth := 3;
      Width := 100;
      Height := 10;
      Left := nextPosLeft;
      Top := nextPosTop;
      if Self.ClientWidth < Screen.MonitorFromWindow(Handle).Width then
        Self.ClientWidth := nextPosLeft + Width + 40;
      Name := Format('pnlDyn%d',[i]);
      Caption := Counters[i].number;
      Hint := s[1] + ' : ' + s[0];
      ShowCaption := False;
      ShowHint := True;
//      OnMouseDown := btnDynMouseDown;
//      OnDockDrop := RelativePanel1DockDrop;
//      OnDockOver := RelativePanel1DockOver;
      Visible := True;
    end;
  end;
end;


procedure TAgentForm.LoadAgent(agentList: TStringList);
var
  i: Integer;
begin
  ini := TMemIniFile.Create('.\Agents\AgentList.ini');

  try
    ini.ReadSectionValues('AGENT', agentList);
  finally
    FreeAndNil(ini);
  end;

  MakeButtons(agentList);
end;


procedure TAgentForm.MakeButtons(agentList: TStringList);
var
  i, j: Integer;
  nextPosLeft, nextPosTop: Integer;
  s, kioskDetail: TArray<string>;
  foundControl: TControl;
begin
  SetLength(Agents, agentList.Count);
  SetLength(btnDyn, agentList.Count);

  for i := 0 to High(Agents) do
  begin
    s := agentList[i].Split(['=']);
    Agents[i].name := s[0];

    kioskDetail := s[1].Split(['|']);
    Agents[i].terminal := kioskDetail[0];
    Agents[i].counter := kioskDetail[1];
    Agents[i].kioskNo := kioskDetail[2];
    Agents[i].kioskIp := kioskDetail[3];

    for j := Low(Counters) to High(Counters) do
    begin
      if Counters[j].number = Agents[i].counter then
      begin
        SetLength(Counters[j].agents, Length(Counters[j].agents)+1);
        Agents[i].left := POS_X1;
        Agents[i].top := 8*Length(Counters[j].agents) + BTN_HEIGHT*(Length(Counters[j].agents)-1);
        Counters[j].agents[Length(Counters[j].agents)-1] := Agents[i];
      end;
    end;
  end;

  for i := 0 to High(Agents) do
  begin
    foundControl := FindCounterControl(Agents[i].counter);
    btnDyn[i] := TButton.Create(foundControl);
    with btnDyn[i] do
    begin
      Parent := TWinControl(foundControl);
      ParentColor := False;
      Width := BTN_WIDTH;
      Height := BTN_HEIGHT;
      Left := Agents[i].left;
      Top := Agents[i].top;
      Color := clBtnFace;
      Name := Format('btnDyn%d',[i]);
      Caption := Agents[i].name;
      Hint := Agents[i].name;
      Images := ImageList1;
      ImageIndex := 0;
      ImageAlignment := iaCenter;
      ShowHint := True;
      OnClick := btnDynClick;
//      OnMouseDown := btnDynMouseDown;
//      OnDockDrop := RelativePanel1DockDrop;
//      OnDockOver := RelativePanel1DockOver;
      Parent.ClientHeight := Top + BTN_HEIGHT + 8;
    end;
  end;
end;

procedure TAgentForm.RelativePanel1DockDrop(Sender: TObject;
  Source: TDragDockObject; X, Y: Integer);
begin
  TControl(Source).Left := X - FStartDragPosOffset.X;
  TControl(Source).Top := Y - FStartDragPosOffset.Y;
end;

procedure TAgentForm.RelativePanel1DockOver(Sender: TObject;
  Source: TDragDockObject; X, Y: Integer; State: TDragState;
  var Accept: Boolean);
begin
  Accept := true;
end;

procedure TAgentForm.btnDynClick(Sender: TObject);
begin
//  Main.CmdClick(TButton(Sender).Caption);
//  TButton(Sender).
  if Assigned(AgentDetailForm) then
    AgentDetailForm.Free;
  AgentDetailForm := TAgentDetailForm.Create(nil);
//  if AgentDetailForm.WindowState <> wsMaximized then
//  begin
    AgentDetailForm.Left := Self.Left + Self.Width;
    AgentDetailForm.Top := Self.Top;
//  end;

  if not AgentDetailForm.LoadDevice(TButton(Sender).Caption) then Exit;
  AgentDetailForm.Caption := TButton(Sender).Caption;
  CurAgentName := TButton(Sender).Caption;
//  SetAgentStatus('SBDC05', 3, '');

  if not AgentDetailForm.Showing then
    AgentDetailForm.Show;
end;

procedure TAgentForm.btnDynMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    TControl(Sender).BeginDrag(True);
    FStartDragPosOffset.SetLocation(X, Y);

//    PageControl1.ActivePageIndex := TControl(Sender).Tag;
  end;
end;

function TAgentForm.FindCounterControl(counter: string): TControl;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to ComponentCount-1 do
  begin
    if (Components[i].ClassType = TRelativePanel) and (TRelativePanel(Components[i]).Caption = counter) then
    begin
      Result := TControl(Components[i]);
      Exit;
    end;
  end;
end;

function TAgentForm.FindAgentControl(counter, agent: string): TControl;
var
  i: Integer;
  foundControl: TControl;
begin
  Result := nil;
  foundControl := FindCounterControl(agent);

  for i := 0 to foundControl.ComponentCount-1 do
  begin
    if (foundControl.Components[i].ClassType = TButton) and (TButton(foundControl.Components[i]).Caption = counter) then
    begin
      Result := TControl(foundControl.Components[i]);
      Exit;
    end;
  end;
end;

function TAgentForm.SetAgentStatus(agentName: string; agentStatus: Integer; sentence: string): Boolean;
var
  i, j: Integer;
  foundControl: TControl;
  parseSentence: Integer;
  tmpInt: Integer;
begin
  Result := False;
  if CurAgentName <> agentName then Exit;
  if agentStatus > ImageList1.Count-1 then Exit;

  for i := 0 to Length(Agents)-1 do
  begin
    if Agents[i].name = agentName then
    begin
      foundControl := FindAgentControl(Agents[i].name, Agents[i].counter);
      TButton(foundControl).ImageIndex := agentStatus;
//      AgentDetailForm.SetDeviceStatus('DCS', 3);
      if TryStrToInt(Trim(sentence), parseSentence) then
      begin
        if parseSentence mod 3 = 0 then
          AgentDetailForm.SetDeviceStatus('DCS', 3)
        else if parseSentence mod 8 = 0 then
          AgentDetailForm.SetDeviceStatus('BHS', 3)
        else if parseSentence mod 7 = 0 then
          AgentDetailForm.SetDeviceStatus('BTP', 3)
        else
        begin
          AgentDetailForm.SetDeviceStatus('DCS', tmpInt mod 4);
          Inc(tmpInt);
        end;
      end;

      Result := True;
      Exit;
    end;
  end;

end;

end.
