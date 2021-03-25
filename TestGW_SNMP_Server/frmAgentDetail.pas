unit frmAgentDetail;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, acPNG, Vcl.ExtCtrls, System.IniFiles, Vcl.StdCtrls,
  System.ImageList, Vcl.ImgList;

type
  TAgentDetailForm = class(TForm)
    Image1: TImage;
    pnlDevice: TPanel;
    ImageList1: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    procedure MakeLabels(deviceList: TStringList);
    { Private declarations }
  public
    lblDyn: array of TLabel;
    btnDyn: array of TButton;
    function LoadDevice(agentName: string): Boolean;
    function SetDeviceStatus(deviceName: string; deviceStatus: Integer): Boolean;
    { Public declarations }
  end;

var
  AgentDetailForm: TAgentDetailForm;
  DeviceList: TStringList;
  ini : TMemIniFile;
  CliHeight: Integer;
  CurAgentName: string;

implementation

{$R *.dfm}

procedure TAgentDetailForm.FormCreate(Sender: TObject);
begin
  DeviceList := TStringList.Create;
end;

procedure TAgentDetailForm.FormDestroy(Sender: TObject);
begin
  if Assigned(DeviceList) then
    DeviceList.Free;
end;

function TAgentDetailForm.LoadDevice(agentName: string): Boolean;
var
  deviceList: TStringList;
begin
  Result := False;

  if not FileExists('.\Agents\' + agentName + '.ini') then Exit;

  deviceList := TStringList.Create;
  ini := TMemIniFile.Create('.\Agents\' + agentName + '.ini');

  try
    ini.ReadSectionValues('DEVICE', deviceList);
  finally
    FreeAndNil(ini);
  end;

  CliHeight := Self.ClientHeight;
  MakeLabels(deviceList);
  Result := True;
end;

procedure TAgentDetailForm.MakeLabels(deviceList: TStringList);
var
  i: Integer;
  nextPosLeft, nextPosTop: Integer;
  s: TArray<string>;
begin
  SetLength(lblDyn, deviceList.Count);
  SetLength(btnDyn, deviceList.Count);

  for i := 0 to deviceList.Count-1 do
  begin
    s := deviceList[i].Split(['=']);

    nextPosLeft := 4;
    nextPosTop := 10*(i+1) + 26*i;
    Self.ClientHeight := cliHeight + nextPosTop + 30;

    btnDyn[i] := TButton.Create(pnlDevice);
    with btnDyn[i] do
    begin
      Parent := pnlDevice;
      ParentColor := False;
      AutoSize := False;
      Width := 26;
      Height := 26;
      Left := nextPosLeft;
      Top := nextPosTop;
      Name := Format('btnDyn%d',[i]);
      Caption := '';
      ImageAlignment := iaCenter;
      Images := ImageList1;
      ImageIndex := 0;
      Tag := StrToInt(s[1]);
      Enabled := False;
      Visible := True;
    end;

    lblDyn[i] := TLabel.Create(pnlDevice);
    with lblDyn[i] do
    begin
      Parent := pnlDevice;
      AutoSize := False;
      Alignment := taLeftJustify;
      Layout := tlCenter;
      Width := 160;
      Height := 26;
      Left := nextPosLeft+30;
      Top := nextPosTop;
      Name := Format('lblDyn%d',[i]);
      Caption := s[0];
      Tag := StrToInt(s[1]);
      Visible := True;
      BringToFront;
    end;
  end;
end;

function TAgentDetailForm.SetDeviceStatus(deviceName: string; deviceStatus: Integer): Boolean;
var
  i: Integer;
  btnName: string;
begin
  Result := False;
  if deviceStatus > ImageList1.Count-1 then Exit;

  for i := 0 to pnlDevice.ComponentCount - 1 do
  begin
    if (pnlDevice.Components[i].ClassType = TLabel) and (TLabel(pnlDevice.Components[i]).Caption = deviceName) then
    begin
      btnName := TLabel(pnlDevice.Components[i]).Name;
      btnName := btnName.Replace('lblDyn','btnDyn',[rfReplaceAll]);
      TButton(pnlDevice.FindComponent(btnName)).ImageIndex := deviceStatus;
      Result := True;
      Exit;
    end;
  end;
end;

end.
