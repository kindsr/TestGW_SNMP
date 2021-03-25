unit frmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, System.SyncObjs,
  IdAntiFreezeBase, IdAntiFreeze, IdUDPBase, IdUDPServer, IdCustomTCPServer,
  IdTCPServer, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdContext,
  IdGlobal, IdSocketHandle, uPacket, frmConfig, IdIOHandler, IdIOHandlerSocket,
  IdIOHandlerStack, IdSSL, IdSSLOpenSSL, frmAgent;

////////////////////////////////////////////////////////////////////////////////
///  Client
////////////////////////////////////////////////////////////////////////////////
type
  TIdcWriteThread = class(TThread)
  private
    FData: TStringList;
    FDisplayData: TStringList;
    FIdClient: TIdTCPClient;
    FCnt: Integer;
    FCS: TCriticalSection;
    FException: Exception;
    procedure SetData(const Value: TStringList);
    procedure SetDisplayData(const Value: TStringList);
    procedure SetIdClient(const Value: TIdTCPClient);
    procedure SetCnt(const Value: Integer);
    procedure SetCS(const Value: TCriticalSection);
    procedure DoHandleException;
  protected
    procedure Execute; override;
    procedure HandleException; virtual;
  public
    constructor Create;
    destructor Destroy; override;

    property Data : TStringList read FData write SetData;
    property DisplayData : TStringList read FDisplayData write SetDisplayData;
    property IdClient : TIdTCPClient read FIdClient write SetIdClient;
    property Cnt : Integer read FCnt write SetCnt;
    property CS : TCriticalSection read FCS write SetCS;
  end;

  TIdcReadThread = class(TThread)
  private
    FData: TStringList;
    FDisplayData: TStringList;
    FIdClient : TIdTCPClient;
    FCS: TCriticalSection;
    FException: Exception;
    procedure SetData(const Value: TStringList);
    procedure SetDisplayData(const Value: TStringList);
    procedure SetIndy(const Value: TIdTCPClient);
    procedure SetCS(const Value: TCriticalSection);
    procedure DoHandleException;
  protected
    procedure Execute; override;
    procedure HandleException; virtual;
  public
    constructor Create;
    destructor Destroy; override;

    property Data : TStringList read FData write SetData;
    property DisplayData : TStringList read FDisplayData write SetDisplayData;
    property IdClient : TIdTCPClient read FIdClient write SetIndy;
    property CS : TCriticalSection read FCS write SetCS;
  end;

type
  TIdcDisplayThread = class(TThread)
  private
    FData: TStringList;
    FListBox: TListBox;
    FCS: TCriticalSection;
    procedure SetListBox(const Value: TListBox);
    procedure SetData(const Value: TStringList);
    procedure SetCS(const Value: TCriticalSection);
  protected

    procedure Display;
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;

    property ListBox : TListBox read FListBox write SetListBox;
    property Data : TStringList read FData write SetData;
    property CS : TCriticalSection read FCS write SetCS;
  end;

////////////////////////////////////////////////////////////////////////////////
///  Server
////////////////////////////////////////////////////////////////////////////////
type
  TSimple = Class
   public
     aContext : TIdContext;
     bRead : Boolean;
     data : String;
   end;

 TIdsWriteThread = class(TThread)
  private
    FListBox: TListBox;
    FsData: TStringList;
    FIdClient : TIdTCPClient;
    FtCS: TCriticalSection;
    FSave_Context : Tlist;
    procedure SetListBox(const Value: TListBox);
    procedure SetsData(const Value: TStringList);
    procedure SetIndy(const Value: TIdTCPClient);
    procedure SettCS(const Value: TCriticalSection);
    procedure SetSave_Context(const Value: Tlist);
  protected

    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;

    property ListBox : TListBox read FListBox write SetListBox;
    property sData : TStringList read FsData write SetsData;
    property tCS : TCriticalSection read FtCS write SettCS;
    property Save_Context : TList Read FSave_Context Write SetSave_Context;
  end;

 TIdsDisplayThread = class(TThread)
  private
    FsData: TStringList;
    FListBox: TListBox;
    FtCS: TCriticalSection;
    procedure SetListBox(const Value: TListBox);
    procedure SetsData(const Value: TStringList);
    procedure SettCS(const Value: TCriticalSection);
  protected

    procedure Display;
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;

    property ListBox : TListBox read FListBox write SetListBox;
    property sData : TStringList read FsData write SetsData;
    property tCS : TCriticalSection read FtCS write SettCS;
  end;


type
  TMain = class(TForm)
    Panel1: TPanel;
    btnTCPServer: TButton;
    btnUDPServer: TButton;
    Panel2: TPanel;
    Timer1: TTimer;
    edtTCPPort: TEdit;
    edtUDPPort: TEdit;
    edtHostIP: TEdit;
    edtPort: TEdit;
    btnTCPClient: TButton;
    IdTCPClient1: TIdTCPClient;
    IdTCPServer1: TIdTCPServer;
    IdUDPServer1: TIdUDPServer;
    IdAntiFreeze1: TIdAntiFreeze;
    ListBox1: TListBox;
    btnClear: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    btnAgent: TButton;
    edVal1: TEdit;
    edVal2: TEdit;
    edVal3: TEdit;
    edVal4: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnTCPClientClick(Sender: TObject);
    procedure btnTCPServerClick(Sender: TObject);
    procedure IdTCPServer1Execute(AContext: TIdContext);
    procedure btnUDPServerClick(Sender: TObject);
    procedure IdUDPServer1UDPRead(AThread: TIdUDPListenerThread;
      const AData: TIdBytes; ABinding: TIdSocketHandle);
    procedure IdTCPServer1Connect(AContext: TIdContext);
    procedure IdTCPServer1Disconnect(AContext: TIdContext);
    procedure btnClearClick(Sender: TObject);
    procedure btnAgentClick(Sender: TObject);
  private
    procedure ProcessMsg(msg: string);
    { Private declarations }
  public
    slSendToServerData : TStringList;
    slSendToClientData : TStringList;
    iCnt : Integer;
    cs : TCriticalSection;
    ReadThread : TIdcReadThread;
    WriteThread : TIdcWriteThread;
    DisplayThread : TIdcDisplayThread;
    Save_Context  : Tlist;
    IdsWriteThread : TIdsWriteThread;
    IdsDisplayThread : TIdsDisplayThread;
    CTS_Lock: TCriticalSection;
    sData: TStringList;
    sDataClient: TStringList;
    { Public declarations }
  end;

var
  Main: TMain;
  PacketHeader: TReqPacketHeader;
  BodyLength: Integer;

implementation

{$R *.dfm}


{ TIdcWriteThread }

constructor TIdcWriteThread.Create;
begin
  FreeOnTerminate := False;
  Cnt := 0;
  inherited Create( true );
end;

destructor TIdcWriteThread.Destroy;
begin

  inherited;
end;

procedure TIdcWriteThread.DoHandleException;
begin
  // Cancel the mouse capture
  if GetCapture <> 0 then SendMessage(GetCapture, WM_CANCELMODE, 0, 0);
  // Now actually show the exception
//  if FException is Exception then
//    Application.ShowException(FException)
//  else
//    ShowException(FException, nil);
end;

procedure TIdcWriteThread.Execute;
const
  // Route
  Header: array[0..78] of Integer = (122, 123, 53, 102, 51, 51, 48, 55, 100, 98, 45, 97, 101, 56, 50, 45, 53, 54, 50, 57, 45, 102, 100, 100, 49, 45, 97, 52, 55, 56, 52, 99, 49, 102, 102, 51, 99, 55, 1, 41, 70, 15, 0, 54, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  Body: array[0..51] of Integer = (102, 14, 13, 91, 77, 43, 63, 63, 34, 2, 63, 15, 100, 68, 63, 63, 0, 63, 63, 109, 72, 63, 52, 63, 63, 63, 63, 63, 63, 32, 68, 64, 50, 48, 49, 57, 48, 53, 48, 50, 49, 48, 50, 48, 49, 57, 48, 53, 48, 56, 49, 50);
var
  cmd : String;
  i: Integer;
  ReqByte: TIdBytes;
begin
  if not IdClient.Connected Then  exit;

//  SetLength(ReqByte, Length(Header)+Length(Body));
//  for i := Low(Header) to High(Header) do
//  begin
//    ReqByte[i] := Header[i];
//  end;
//
//  for i := Length(Header) to Length(Header)+Length(Body)-1 do
//  begin
//    ReqByte[i] := Body[i-Length(Header)];
//  end;

  while not Terminated do
  begin
    try
      IdClient.CheckForGracefulDisconnect(True);
      IdClient.IOHandler.CheckForDisconnect(True, True);

  //    inc( FCnt );
  //
  //    IdClient.IOHandler.Write(Inttostr( Cnt )+#02#$d#$a );
  //
  //    CS.Enter;
  //    try
  //      Data.Add( 'Write = ' + IntToStr( FCnt ) );
  //    finally
  //      CS.Leave;
  //    end;

      // 여기서부터
      if Data.Count > 0 then
      begin
  //      CS.Enter;
  //      try
    //      IdClient.IOHandler.Write(Data[0]+#$d#$a);
    //      IdClient.IOHandler.Write(IndyTextEncoding_ASCII.GetString(ReqByte)+#$d#$a);
    //      Data.BeginUpdate;
    //      Data.Delete(0);
    //      Data.EndUpdate;

          for i := 0 to Data.Count-1 do
          begin
            DisplayData.Add('[WRITETHREAD] ' + Data[i]);
            IdClient.IOHandler.Write(Data[i]+#$d#$a);
          end;
          Data.Clear;
  //      finally
  //        CS.Leave;
  //      end;

      end;
    except
      HandleException;
    end;

    Application.ProcessMessages;
    WaitForSingleObject( Handle, 10 );
  end;
end;

procedure TIdcWriteThread.HandleException;
begin
  // This function is virtual so you can override it
  // and add your own functionality.
  FException := Exception(ExceptObject);
  try
    // Don't show EAbort messages
    if not (FException is EAbort) then
      Synchronize(DoHandleException);
  finally
    FException := nil;
  end;
end;

procedure TIdcWriteThread.SetCnt(const Value: Integer);
begin
  FCnt := Value;
end;

procedure TIdcWriteThread.SetCS(const Value: TCriticalSection);
begin
  FCS := Value;
end;

procedure TIdcWriteThread.SetData(const Value: TStringList);
begin
  FData := Value;
end;

procedure TIdcWriteThread.SetDisplayData(const Value: TStringList);
begin
  FDisplayData := Value;
end;

procedure TIdcWriteThread.SetIdClient(const Value: TIdTCPClient);
begin
  FIdClient := Value;
end;

{ TIdcReadThread }

constructor TIdcReadThread.Create;
begin
  FreeOnTerminate := False;
  inherited Create( True );
end;

destructor TIdcReadThread.Destroy;
begin

  inherited;
end;

procedure TIdcReadThread.DoHandleException;
begin
  // Cancel the mouse capture
  if GetCapture <> 0 then SendMessage(GetCapture, WM_CANCELMODE, 0, 0);
  // Now actually show the exception
//  if FException is Exception then
//    Application.ShowException(FException)
//  else
//    ShowException(FException, nil);
end;

procedure TIdcReadThread.Execute;
var
  t : Cardinal;
  byteMsgFromServer: TIdBytes;
  byteBodyFromServer: TIdBytes;
  procedure AddData( aStr : String );
  begin
    CS.Enter;
    try
      Data.Add( aStr );
    finally
      CS.Leave;
    end;
  end;
begin
  while not Terminated do
  try
    try
      t := GetTickCount;

      repeat
        IdClient.CheckForGracefulDisconnect(True);
        IdClient.IOHandler.CheckForDisconnect(True, True);
        IdClient.IOHandler.CheckForDataOnSource( 100 );
        if GetTickCount - t > 3000 then
        begin
          AddData( '>>>>>>>>>>>>>>>>>>> Read Time Out <<<<<<<<<<<<<<<<<<<<' );
          Break;
        end;

        WaitForSingleObject( Handle, 10 );
        Application.ProcessMessages;

      until IdClient.IOHandler.InputBuffer.Size > 0;

      if GetTickCount - t > 1000 then
        Continue;

  //    CS.Enter;
  //    try
  //      Data.Add( 'Read = ' + IdClient.IOHandler.ReadLn );
  //    finally
  //      CS.Leave;
  //    end;

      // ... read message from server
    //  msgFromServer := MWIdTCPClient.IOHandler.ReadLn();

      if BodyLength > 0 then
        IdClient.IOHandler.ReadBytes(byteMsgFromServer, BodyLength)
      else
        IdClient.IOHandler.ReadBytes(byteMsgFromServer, SizeOf(TReqPacketHeader));

      // ... messages log
      DisplayData.Add('[TCP_CLIENT - FROM SERVER] ' + IndyTextEncoding_ASCII.GetString(byteMsgFromServer));

      if (byteMsgFromServer[0] = PACKET_DELIMITER_1) and (byteMsgFromServer[1] = PACKET_DELIMITER_2) then
      begin
        SetPacketHeader(byteMsgFromServer, PacketHeader);
    //    FillChar(byteBodyFromServer, PacketHeader.BodySize, #0);
        case PacketHeader.MsgType of
          PACKET_TYPE_REQ: ;
          PACKET_TYPE_NOTI: ;
          PACKET_TYPE_RES:
            begin
              BodyLength := PacketHeader.BodySize;
            end;
        end;
      end
      else
      begin
        case PacketHeader.MsgType of
          PACKET_TYPE_REQ: ;
          PACKET_TYPE_NOTI: ;
          PACKET_TYPE_RES:
            begin
    //          len := Length(byteBodyFromServer);
              SetLength(byteBodyFromServer, BodyLength);
              Move(byteMsgFromServer[0], byteBodyFromServer[0], Length(byteMsgFromServer));
              DisplayData.Add('[BODY] ' + IndyTextEncoding_ASCII.GetString(byteBodyFromServer));
              DisplayData.Add('[LENGTH] ' + IntToStr(Length(byteBodyFromServer)));
              BodyLength := 0;
              // New ECDIS 로 전달할 내용
              Data.BeginUpdate;
              Data.Add(IndyTextEncoding_ASCII.GetString(GetPacketHeaderBytes(PacketHeader)+byteBodyFromServer));
              Data.EndUpdate;
            end;
        end;
      end;

    finally
      WaitForSingleObject( Handle, 10 );
      Application.ProcessMessages;
    end;
  except
    HandleException;
  end;
end;

procedure TIdcReadThread.HandleException;
begin
  // This function is virtual so you can override it
  // and add your own functionality.
  FException := Exception(ExceptObject);
  try
    // Don't show EAbort messages
    if not (FException is EAbort) then
      Synchronize(DoHandleException);
  finally
    FException := nil;
  end;
end;

procedure TIdcReadThread.SetCS(const Value: TCriticalSection);
begin
  FCS := Value;
end;

procedure TIdcReadThread.SetData(const Value: TStringList);
begin
  FData := Value;
end;

procedure TIdcReadThread.SetDisplayData(const Value: TStringList);
begin
  FDisplayData := Value;
end;

procedure TIdcReadThread.SetIndy(const Value: TIdTCPClient);
begin
  FIdClient := Value;
end;

{ TIdcDisplayThread }

constructor TIdcDisplayThread.Create;
begin
  inherited Create( True );
end;

destructor TIdcDisplayThread.Destroy;
begin
  inherited;
end;

procedure TIdcDisplayThread.Display;
var
  I: Integer;
begin
  With ListBox do
  begin
//    Items.Add( 'Data Count = ' + IntToStr( Data.Count ) );
    for I := 0 to Data.Count - 1 do
    begin
      Items.Add(  Data[i] );
      ItemIndex := Count -1;
    end;

    Data.Clear;
  end;
end;

procedure TIdcDisplayThread.Execute;
begin
  while not Terminated do
  begin
    CS.Enter;
    try
      Synchronize( Display );
    finally
      CS.Leave;
    end;
    Application.ProcessMessages;
    WaitForSingleObject( Handle, 10 );
  end;
end;

procedure TIdcDisplayThread.SetCS(const Value: TCriticalSection);
begin
  FCS := Value;
end;

procedure TIdcDisplayThread.SetData(const Value: TStringList);
begin
  FData := Value;
end;

procedure TIdcDisplayThread.SetListBox(const Value: TListBox);
begin
  FListBox := Value;
end;

procedure TMain.btnAgentClick(Sender: TObject);
begin
  if not AgentForm.Showing then
    AgentForm.Show;
end;

procedure TMain.btnClearClick(Sender: TObject);
begin
  ListBox1.Clear;
end;

procedure TMain.btnTCPClientClick(Sender: TObject);
begin
  if TButton(Sender).Tag = 0 then
  begin
    TButton(Sender).Tag := 1;
    TButton(Sender).Caption := 'TCP Client Stop';

    IdTCPClient1.Host := edtHostIP.Text;
    IdTCPClient1.Port := StrToInt(edtPort.Text);

//    ListBox1.Clear;
    try
      if not IdTCPClient1.Connected then
        IdTCPClient1.Connect;
    except
      TButton(Sender).Tag := 0;
      TButton(Sender).Caption := 'TCP Client Start';
      Exit;
    end;

    ReadThread.CS          := cs;
    ReadThread.IdClient    := IdTCPClient1;
    ReadThread.Data        := slSendToClientData;
    ReadThread.DisplayData := sDataClient;

    WriteThread.CS          := cs;
    WriteThread.IdClient    := IdTCPClient1;
    WriteThread.Data        := slSendToServerData;
    WriteThread.DisplayData := sDataClient;

    DisplayThread.ListBox  := ListBox1;
    DisplayThread.CS      := cs;
    DisplayThread.Data     := sDataClient;

    WriteThread.Resume;
    ReadThread.Resume;
    DisplayThread.Resume;
  end
  else
  begin
    TButton(Sender).Tag := 0;
    TButton(Sender).Caption := 'TCP Client Start';

    if not ReadThread.Suspended then
      ReadThread.Suspend;
    if not WriteThread.Suspended then
      WriteThread.Suspend;
    if not DisplayThread.Suspended then
      DisplayThread.Suspend;
  end;
end;

procedure TMain.btnTCPServerClick(Sender: TObject);
var
  i: Integer;
  list : TList;
begin
  if TButton(Sender).Tag = 0 then
  begin
    TButton(Sender).Tag := 1;
    TButton(Sender).Caption := 'TCP Server Stop';

    IdTCPServer1.Bindings.Add.Port := StrToInt(edtTCPPort.Text);
    IdTcpServer1.Active := True;

    IdsWriteThread.Resume;
    IdsDisplayThread.Resume;
  end
  else
  begin
    TButton(Sender).Tag := 0;
    TButton(Sender).Caption := 'TCP Server Start';

    if not IdsWriteThread.Suspended then
      IdsWriteThread.Suspend;
    if not IdsDisplayThread.Suspended then
      IdsDisplayThread.Suspend;

    list := IdTcpServer1.Contexts.LockList;
    try
      Try
        for i := 0 to list.Count - 1 do
        begin
          TIdContext( list[i] ).Connection.Disconnect;
        end;
      except
      End;
    finally
      IdTcpServer1.Contexts.UnlockList;
    end;
    IdTCPServer1.Bindings.Clear;
    IdTcpServer1.Active := False;
  end;
end;

procedure TMain.btnUDPServerClick(Sender: TObject);
begin
  if TButton(Sender).Tag = 0 then
  begin
    TButton(Sender).Tag := 1;
    TButton(Sender).Caption := 'UDP Server Stop';

    IdUDPServer1.Bindings.Clear;
    IdUDPServer1.Bindings.Add.Port := StrToInt(edtUDPPort.Text);

    {Activate the Indy Server}
    IdUDPServer1.Active := True;
  end
  else
  begin
    TButton(Sender).Tag := 0;
    TButton(Sender).Caption := 'UDP Server Start';

    IdUDPServer1.Active := False;
  end;
end;

procedure TMain.FormCreate(Sender: TObject);
begin
  Config.LoadConfig(ExtractFilePath(Application.ExeName) + ChangeFileExt(ExtractFileName(Application.ExeName), '.ini'));

  edtTCPPort.Text := IntToStr(ConfigInfo.TCPPort);
  edtUDPPort.Text := IntToStr(ConfigInfo.UDPPort);
  edtHostIP.Text := ConfigInfo.HostIP;
  edtPort.Text := IntToStr(ConfigInfo.HostPort);

  // Client
  cs := TCriticalSection.Create;
  ReadThread := TIdcReadThread.Create;
  WriteThread := TIdcWriteThread.Create;
  DisplayThread := TIdcDisplayThread.Create;
  slSendToServerData := TStringList.Create;
  slSendToClientData := TStringList.Create;

  // Server
  CTS_Lock := TCriticalSection.Create;
  sData := TStringList.Create;
  sDataClient := TStringList.Create;
  Save_Context := TList.Create;


  IdsWriteThread          := TIdsWriteThread.Create;
  IdsWriteThread.tCS      := CTS_Lock;
  IdsWriteThread.sData    := slSendToClientData;
  IdsWriteThread.Save_Context := Save_Context;
  IdsWriteThread.ListBox  := ListBox1;

  IdsDisplayThread          := TIdsDisplayThread.Create;
  IdsDisplayThread.tCS      := CTS_Lock;
  IdsDisplayThread.sData    := sData;
  IdsDisplayThread.ListBox  := ListBox1;
end;

procedure TMain.FormDestroy(Sender: TObject);
var
  i: Integer;
begin
  // Client
  if WriteThread.Suspended then
    WriteThread.Resume;
  WriteThread.Terminate;

  if ReadThread.Suspended then
    ReadThread.Resume;
  ReadThread.Terminate;

  if DisplayThread.Suspended then
    DisplayThread.Resume;
  DisplayThread.Terminate;

  WriteThread.WaitFor;
  ReadThread.WaitFor;
  DisplayThread.WaitFor;

  ReadThread.Free;
  WriteThread.Free;
  DisplayThread.Free;
  cs.Free;
  slSendToServerData.free;
  slSendToClientData.free;

  // Server
  if IdsWriteThread.Suspended then
    IdsWriteThread.Resume;
  IdsWriteThread.Terminate;

  if IdsDisplayThread.Suspended then
    IdsDisplayThread.Resume;
  IdsDisplayThread.Terminate;

  IdsWriteThread.WaitFor;
  IdsWriteThread.Free;

  IdsDisplayThread.WaitFor;
  IdsDisplayThread.Free;

  IdTCPServer1.Active := False;

  CTS_Lock.Free;

  for i := 0 to Save_Context.Count - 1 do
    TSimple( Save_Context[i] ).Free;

  Save_Context.Free;
  sData.Free;
end;

procedure TMain.IdTCPServer1Connect(AContext: TIdContext);
begin
  sData.Add('[TCP_SERVER] Client Connected!');
  sData.Add('[TCP_SERVER] Port=' + edtTCPPort.Text + ' ' + '(PeerIP=' + AContext.Binding.PeerIP + ' - ' + 'PeerPort=' + IntToStr(AContext.Binding.PeerPort) + ')');
end;

procedure TMain.IdTCPServer1Disconnect(AContext: TIdContext);
begin
  sData.Add('[TCP_SERVER] Client Disconnected! Peer=' + AContext.Binding.peerIP + ':' + IntToStr(AContext.Binding.peerPort));
end;

procedure TMain.IdTCPServer1Execute(AContext: TIdContext);
var
  CMD : String;
  UP_Ver, UP_FileName : String;
  simple : TSimple;
  msgFromClient: string;
  byteMsgFromClient: TIdBytes;
  byteMsgToClient: TIdBytes;
  caseInt: Integer;
begin
  msgFromClient := '';
  If AContext.Connection.IOHandler.Connected Then
//    CMD := AContext.Connection.IOHandler.ReadLn( #02#$d#$a, 500 );
    msgFromClient := AContext.Connection.IOHandler.ReadLn();
//    msgFromClient := AContext.Connection.IOHandler.ReadLn;

  if msgFromClient = '' then Exit;

  byteMsgFromClient := IndyTextEncoding_ASCII.GetBytes(msgFromClient);

  // ... message log
  sData.Add('[CLIENT] (Peer=' + AContext.Binding.PeerIP + ':' + IntToStr(AContext.Binding.PeerPort) + ') ' + msgFromClient);
  sData.Add('Read Data Size: ' + inttostr(length(msgFromClient)) );
  caseInt := StrToInt(Trim(msgFromClient));
  // ... process message from Client
  ProcessMsg(msgFromClient);

  WaitForSingleObject( handle, 1);
end;

procedure TMain.IdUDPServer1UDPRead(AThread: TIdUDPListenerThread;
  const AData: TIdBytes; ABinding: TIdSocketHandle);
var
  PeerPort: Integer;
  PeerIP: string;
  msgFromClient: string;
begin
  try
    // ... get message from client
    msgFromClient := BytesToString(AData);

    PeerIP := ABinding.PeerIP;
    PeerPort := ABinding.PeerPort;

    ListBox1.Items.Add('[UDP_CLIENT] (Peer=' + PeerIP + ':' + IntToStr(PeerPort) + ') ' + msgFromClient);
    slSendToServerData.Add(msgFromClient);
  except
    on E: Exception do
    begin
    end;
  end;
end;

{ TIdsWriteThread }

constructor TIdsWriteThread.Create;
begin
  FreeOnTerminate := False;
  inherited Create( True );
end;

destructor TIdsWriteThread.Destroy;
begin
  inherited;
end;

procedure TIdsWriteThread.Execute;
var
  t : Cardinal;
  Simple : TSimple;
begin
  while not Terminated do
  Begin
    Try

      if Save_Context.Count > 0 then
      try
//        tCS.Enter;
        Simple := TSimple( Save_Context[0] );  // 저장된 클라이언트의 접속정보.

        if ( Simple.aContext <> nil ) And
           ( Simple.aContext.Connection <> nil ) And
           ( Simple.aContext.Connection.IOHandler <> nil ) And
           ( Simple.aContext.Connection.IOHandler.connected ) then
        begin
          Simple.aContext.Connection.IOHandler.Write( Simple.data + #$d#$a );

//          sData.Add('Write = ' + Simple.data );

          Simple.aContext := nil;
          Simple.data := '';
          Simple.Free;
        end;
      Finally
        Save_Context.Delete( 0 );  // 모든 처리가 끝났으니 바2바2
//        tCS.Leave;
      End;

    finally
      WaitForSingleObject( Handle, 10 );
      Application.ProcessMessages;
    end;
  End;
end;

procedure TIdsWriteThread.SetIndy(const Value: TIdTCPClient);
begin
  FIdClient := Value;
end;

procedure TIdsWriteThread.SetListBox(const Value: TListBox);
begin
  FListBox := Value;
end;

procedure TIdsWriteThread.SetSave_Context(const Value: Tlist);
begin
  FSave_Context := Value;
end;

procedure TIdsWriteThread.SetsData(const Value: TStringList);
begin
  FsData := Value;
end;

procedure TIdsWriteThread.SettCS(const Value: TCriticalSection);
begin
  FtCS := Value;
end;

{ TIdsDisplayThread }

constructor TIdsDisplayThread.Create;
begin
  inherited Create( True );
end;

destructor TIdsDisplayThread.Destroy;
begin
  inherited;
end;

procedure TIdsDisplayThread.Display;
var
  I: Integer;
begin
  if sData.Count = 0 then exit;

  With ListBox do
  begin
//    Items.Add( 'sData Count = ' + IntToStr( sData.Count ) );
    for I := 0 to sData.Count - 1 do
    begin
      Items.Add(  sData[i] );
      ItemIndex := Count -1;
    end;

    sData.Clear;
  end;
end;

procedure TIdsDisplayThread.Execute;
begin
  while not Terminated do
  begin
    tCS.Enter;
    try
      Synchronize(  Display );
    finally
      tCS.Leave;
    end;
    Application.ProcessMessages;
    WaitForSingleObject( Handle, 10 );
  end;
end;

procedure TIdsDisplayThread.SetListBox(const Value: TListBox);
begin
  FListBox := Value;
end;

procedure TIdsDisplayThread.SetsData(const Value: TStringList);
begin
  FsData := Value;
end;

procedure TIdsDisplayThread.SettCS(const Value: TCriticalSection);
begin
  FtCS := Value;
end;

procedure TMain.ProcessMsg(msg: string);
var
  msgInt: Integer;
begin
  if TryStrToInt(Trim(msg), msgInt) then
  begin
    if msgInt mod StrToInt(edVal1.Text) = 0 then
      AgentForm.SetAgentStatus('SBDC01', 3, msg)
    else if msgInt mod StrToInt(edVal2.Text) = 0 then
      AgentForm.SetAgentStatus('SBDC02', 3, msg)
    else if msgInt mod StrToInt(edVal3.Text) = 0 then
      AgentForm.SetAgentStatus('SBDC03', 3, msg)
    else if msgInt mod StrToInt(edVal4.Text) = 0 then
      AgentForm.SetAgentStatus('SBDC04', 3, msg)
    else if msgInt mod (StrToInt(edVal1.Text)*2) = 0 then
      AgentForm.SetAgentStatus('SBDC05', 3, msg);
  end;
end;

end.
