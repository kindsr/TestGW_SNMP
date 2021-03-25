unit uTCPSSL;
interface
uses
  Classes,SysUtils,
  IdGlobal,IdSSLOpenSSLHeaders,IdSSLOpenSSL,IdContext,
  IdIOHandler,IdCustomTCPServer,IdTCPServer,IdTCPClient;
(*
  https://testssl.sh/
  used for testing SSL/TLS
*)
const
  WSANO_RECOVERY = 11003;

  SSL_OP_STRONG =
    SSL_OP_ALL                                    or
    SSL_OP_NO_SSLv2 or SSL_OP_NO_SSLv3            or
    SSL_OP_NO_TLSv1 or SSL_OP_NO_TLSv1_1          or
    SSL_OP_CIPHER_SERVER_PREFERENCE               or
    SSL_OP_SINGLE_DH_USE                          or
    SSL_OP_SINGLE_ECDH_USE                        or
    SSL_OP_NO_SESSION_RESUMPTION_ON_RENEGOTIATION ;

  SSLStrongCiphers =
    'ECDHE-RSA-AES256-GCM-SHA384:' +
    'ECDHE-RSA-AES256-SHA384:'     +
    'ECDHE-RSA-AES256-SHA:'        +
    'AES256-GCM-SHA384:'           +
    /////////////////////////////////
    'AES256-SHA256:'   +
    'AES256-SHA:'      +
    'CAMELLIA256-SHA:' +
    /////////////////////////////////
    '!aNULL:'       +
    '!eNULL:'       +
    '!EXPORT:'      +
    '!RC4:'         +
    '!DES:'         +
    '!MD5@STRENGTH' ;
    /////////////////////////////////
type
  TTCPContext            = class;
  TTCPContextClass       = class of TTCPContext;
  TTCPClient             = class;
  TTCPClientEvent        = procedure(Client:TTCPClient) of object;
  TTCPVerifyEvent        = function(Client:TTCPClient;const Certificate:string):Boolean of object;
  TTCPServerEvent        = procedure(AContext:TTCPContext) of object;
  TTCPServerVerifyEvent  = function(AContext:TTCPContext;const Certificate:string):Boolean of object;
  TTCPServerExecuteEvent = function(AContext:TTCPContext):Boolean of object;

  TTCPSSLOptions=class
  private
    FKeyPassword   : RawByteString;
    FCACertPEM     : RawByteString;
    FCertPEM       : RawByteString;
    FPrivateKeyPEM : RawByteString;
    FP12           : TBytes;
    FCiphers       : RawByteString;
    FCACert        : PX509;
    FCert          : PX509;
    FPrivateKey    : PEVP_PKEY;
    procedure SetCert(Index:Integer;Value:string);
    procedure SetP12(Value:TBytes);
    procedure PrepareSSL;
  public
    constructor Create;
    destructor  Destroy;override;
    property    CACert      : string index 1 write SetCert;
    property    Cert        : string index 2 write SetCert;
    property    PrivateKey  : string index 3 write SetCert;
    property    KeyPassword : string index 4 write SetCert;
    property    Ciphers     : string index 5 write SetCert;
    property    P12         : TBytes write FP12;
  end;

  TTCPSSLIOClient = class(TIdSSLIOHandlerSocketOpenSSL)
  private
    FSSLOptions : TTCPSSLOptions;
    FSSLCtx     : Pointer;
    property PassThrough;
  protected
    procedure InitComponent;override;
  public
    destructor Destroy;override;
    property   SSLOptions:TTCPSSLOptions read FSSLOptions write FSSLOptions;
    procedure  StartSSL;override;
  end;

  TTCPSSLIOServer = class(TIdServerIOHandlerSSLOpenSSL)
  private
    FSSLOptions : TTCPSSLOptions;
    FSSLCtx     : Pointer;
  protected
    procedure InitComponent;override;
  public
    procedure  Init;override;
    destructor Destroy;override;
    property   SSLOptions:TTCPSSLOptions read FSSLOptions write FSSLOptions;
  end;

  TTCPContext = class(TIdServerContext)
  private
    FPeerCertificate : string;
  public
    property PeerCertificate:string read FPeerCertificate;
  end;

  TTCPClient=class(TIdTCPClient)
  private
  var
    FCert            ,
    FPrivateKey      ,
    FCACert          ,
    FKeyPassword     ,
    FCiphers         : string;
    FP12             : TBytes;
    FSSLEnabled      : Boolean;
    FSSLHandler      : TTCPSSLIOClient;
    FPeerCertificate : string;
    FOnVerify        : TTCPVerifyEvent;
    FOnConnect       : TTCPClientEvent;
    FOnDisconnect    : TTCPClientEvent;
    function  GetCert(Index:Integer):string;
    procedure SetCert(Index:Integer;Value:string);
  protected
    procedure InitComponent;override;
    procedure DoOnConnected;override;
    procedure DoOnDisconnected;override;
  public
    property   CACert      : string index 1 read GetCert write SetCert;
    property   Cert        : string index 2 read GetCert write SetCert;
    property   PrivateKey  : string index 3 read GetCert write SetCert;
    property   KeyPassword : string index 4 read GetCert write SetCert;
    property   Ciphers     : string index 5 read GetCert write SetCert;
    property   P12         : TBytes read FP12 write FP12;

    property   SSLEnabled:Boolean  read FSSLEnabled write FSSLEnabled;

    procedure  Connect;override;
    function   Connected:Boolean;override;

    property   PeerCertificate:string read FPeerCertificate;

    property   OnVerify     : TTCPVerifyEvent read FOnVerify     write FOnVerify;
    property   OnConnect    : TTCPClientEvent read FOnConnect    write FOnConnect;
    property   OnDisconnect : TTCPClientEvent read FOnDisconnect write FOnDisconnect;
  end;

  TTCPServer=class(TIdTCPServer)
  private
    FCACert        ,
    FCert          ,
    FPrivateKey    ,
    FKeyPassword   ,
    FCiphers       : string;
    FP12           : TBytes;
    FSSLEnabled    : Boolean;
    FSSLHandler    : TTCPSSLIOServer;
    FOnVerify      : TTCPServerVerifyEvent;
    FOnConnect     : TTCPServerEvent;
    FOnDisconnect  : TTCPServerEvent;
    FOnExecute     : TTCPServerExecuteEvent;
    function  GetCert(Index:Integer):string;
    procedure SetCert(Index:Integer;Value:string);
  protected
    procedure InitComponent;override;
    procedure CheckOkToBeActive;override;
    procedure SetActive(Value:Boolean);override;
    procedure DoConnect(AContext:TIdContext);override;
    procedure DoDisconnect(AContext:TIdContext);override;
    function  DoExecute(AContext:TIdContext):Boolean;override;
  public
    property   CACert      : string index 1 read GetCert write SetCert;
    property   Cert        : string index 2 read GetCert write SetCert;
    property   PrivateKey  : string index 3 read GetCert write SetCert;
    property   KeyPassword : string index 4 read GetCert write SetCert;
    property   Ciphers     : string index 5 read GetCert write SetCert;
    property   P12         : TBytes read FP12 write FP12;

    property   SSLEnabled:Boolean  read FSSLEnabled write FSSLEnabled;

    property   OnVerify     : TTCPServerVerifyEvent  read FOnVerify     write FOnVerify;
    property   OnConnect    : TTCPServerEvent        read FOnConnect    write FOnConnect;
    property   OnDisconnect : TTCPServerEvent        read FOnDisconnect write FOnDisconnect;
    property   OnExecute    : TTCPServerExecuteEvent read FOnExecute    write FOnExecute;
  end;

implementation

uses
  IdCTypes,IdStackConsts,IdStack,
  IdResourceStringsCore,IdResourceStringsProtocols,
  IdSSL,IdExplicitTLSClientServerBase;

const
  SSL_CTRL_SET_ECDH_AUTO = 94;
var
  SSLLoaded : Boolean = False;

procedure LoadSSL;
begin
  if SSLLoaded then Exit;
  SSLLoaded := True;
  LoadOpenSSLLibrary;
end;

///////////////////////////////////////////////////////////////////////////
function X509ToPEM(X509:Pointer):string;
var
  MemIO     : pBIO;
  iResult   : Integer;
  RawResult : RawByteString;
  P         : Pointer;
begin
  Result := '';
  if X509=nil then Exit;
  MemIO   := BIO_new(BIO_s_mem);
  iResult := PEM_write_bio_X509(MemIO,X509);
  if iResult=1 then
  begin
    P := nil;
    SetLength(RawResult,BIO_get_mem_data(MemIO,P));
    if RawResult<>'' then BIO_read(MemIO,PAnsiChar(RawResult),Length(RawResult));
    Result := string(RawResult);
  end;
  BIO_free(MemIO);
end;

procedure LoadCert(PEM:RawByteString;var x509:PX509);
var
  Buffer : PBIO;
begin
  if x509<>nil then X509_free(x509);
  x509 := nil;
  if Length(PEM)=0 then Exit;
  Buffer := BIO_new_mem_buf(PAnsiChar(PEM),Length(PEM));
  try
    x509 := PEM_read_bio_X509(Buffer,nil,nil,nil);
  finally
    BIO_free(Buffer);
  end;
end;

procedure LoadKey(PEM:RawByteString;const KeyPassword:RawByteString;var xKey:PEVP_PKEY);
var
  Buffer : PBIO;
begin
  if xKey<>nil then EVP_PKEY_free(xKey);
  if Length(PEM)=0 then Exit;
  Buffer := BIO_new_mem_buf(PAnsiChar(PEM),Length(PEM));
  try
    xKey := PEM_read_bio_PrivateKey(Buffer,nil,nil,PAnsiChar(KeyPassword));
  finally
    BIO_free(Buffer);
  end;
end;
///////////////////////////////////////////////////////////////////////////
constructor TTCPSSLOptions.Create;
begin
  FKeyPassword := '';
  FCACert      := nil;
  FCert        := nil;
  FPrivateKey  := nil;
  FCiphers     := '';
  FP12         := nil;
end;

destructor TTCPSSLOptions.Destroy;
begin
  (*
  if FCACert<>nil then X509_free(FCACert);
  if FCert<>nil then X509_free(FCert);
  if FPrivateKey<>nil then EVP_PKEY_free(FPrivateKey);
  *)
  inherited;
end;

procedure TTCPSSLOptions.SetCert(Index:Integer;Value:string);
var
  RawValue : RawByteString;
begin
  RawValue := RawByteString(Trim(Value));
  case index of
    1: FCACertPEM     := RawValue;
    2: FCertPEM       := RawValue;
    3: FPrivateKeyPEM := RawValue;
    4: FKeyPassword   := RawByteString(Value);
    5: FCiphers       := RawByteString(Value);
  end;
end;

procedure TTCPSSLOptions.SetP12(Value: TBytes);
var
  MemIO     : PBIO;
  p12       : PPKCS12;
  xCA       : PSTACK_OF_X509;
  Err       ,
  i         : Integer;
  CertChain : string;
procedure Clear;
begin
  if xCA        <>nil then sk_pop_free(xCA,@X509_free);
  if FCACert    <>nil then X509_free(FCACert);
  if FCert      <>nil then X509_free(FCert);
  if FPrivateKey<>nil then EVP_PKEY_free(FPrivateKey);
  xCA         := nil;
  FCACert     := nil;
  FCert       := nil;
  FPrivateKey := nil;
end;
begin
  if Value=nil then Exit;
  xCA := nil;
  Clear;
  MemIO := BIO_new_mem_buf(@Value[0],Length(Value));
  p12   := d2i_PKCS12_bio(MemIO,nil);
  Err   := 1;
  if Assigned(p12) then
  begin
    Err := PKCS12_parse(p12,PAnsiChar(FKeyPassword),FPrivateKey,FCert,@xCA);
    PKCS12_free(p12);
  end;
  BIO_free(MemIO);
  if Err<=0 then Clear else
  begin
    if xCA<>nil then
    begin
      CertChain := '';
      for i:=0 to sk_num(xCA)-1 do CertChain := X509ToPEM(sk_value(xCA,i))+CertChain;
      sk_pop_free(xCA,@X509_free);
      CACert := CertChain;
      LoadCert(FCACertPEM,FCACert);
    end;
  end;
end;

procedure TTCPSSLOptions.PrepareSSL;
begin
  if FP12=nil then
  begin
    LoadCert(FCACertPEM,FCACert);
    LoadCert(FCertPEM,FCert);
    LoadKey(FPrivateKeyPEM,FKeyPassword,FPrivateKey);
  end
  else SetP12(FP12);
end;
///////////////////////////////////////////////////////////////////////////
type
  TTCPSSLSocket=class(TIdSSLSocket)
  end;

  TTCPSSLContext=class(TIdSSLContext)
  end;
///////////////////////////////////////////////////////////////////////////
function VerifyCallback(Ok: TIdC_INT; ctx: PX509_STORE_CTX): TIdC_INT; cdecl;
begin
  Result := 1;
end;

procedure TTCPSSLIOClient.InitComponent;
begin
  LoadSSL;
  inherited;
  FSSLOptions := TTCPSSLOptions.Create;
  PassThrough := True;
end;

destructor TTCPSSLIOClient.Destroy;
begin
  if fSSLContext<>nil then FreeAndNil(fSSLContext);
  inherited;
end;

procedure TTCPSSLIOClient.StartSSL;
begin
  LoadSSL;
  if fSSLContext<>nil then FreeAndNil(fSSLContext);
  fSSLContext      := TIdSSLContext.Create;
  fSSLContext.Mode := sslmClient;
  FSSLCtx          := SSL_CTX_new(SSLv23_client_method);
  if FSSLCtx<>nil then
  begin
    FSSLOptions.PrepareSSL;
    TTCPSSLContext(fSSLContext).fContext := FSSLCtx;
    SSL_CTX_set_options(FSSLCtx,SSL_OP_STRONG);
    SSL_CTX_ctrl(FSSLCtx,SSL_CTRL_SET_ECDH_AUTO,1,nil);
    SSL_CTX_add_extra_chain_cert(FSSLCtx,FSSLOptions.FCACert);
    SSL_CTX_use_certificate(FSSLCtx,FSSLOptions.FCert);
    SSL_CTX_use_PrivateKey(FSSLCtx,FSSLOptions.FPrivateKey);
    SSL_CTX_set_verify(FSSLCtx,SSL_VERIFY_PEER,VerifyCallback);
    SSL_CTX_set_verify_depth(FSSLCtx,0);
    if FSSLOptions.FCiphers<>'' then SSL_CTX_set_cipher_list(FSSLCtx,PAnsiChar(FSSLOptions.FCiphers));
  end
  else
  begin
    FreeAndNil(fSSLContext);
    EIdOSSLCreatingContextError.RaiseException(RSSSLCreatingContextError);
  end;
  try
    if (not PassThrough) then OpenEncodedConnection;
  except
  end;
end;
///////////////////////////////////////////////////////////////////////////
procedure TTCPSSLIOServer.InitComponent;
begin
  LoadSSL;
  inherited;
  FSSLCtx     := nil;
  FSSLOptions := TTCPSSLOptions.Create;
end;

destructor TTCPSSLIOServer.Destroy;
begin
  if fSSLContext<>nil then FreeAndNil(fSSLContext);
  FreeAndNil(FSSLOptions);
  inherited;
end;

procedure TTCPSSLIOServer.Init;
begin
  LoadSSL;
  if fSSLContext<>nil then FreeAndNil(fSSLContext);
  fSSLContext      := TIdSSLContext.Create;
  fSSLContext.Mode := sslmServer;
  FSSLCtx          := SSL_CTX_new(SSLv23_server_method);
  if FSSLCtx<>nil then
  begin
    FSSLOptions.PrepareSSL;
    TTCPSSLContext(fSSLContext).fContext := FSSLCtx;
    SSL_CTX_set_options(FSSLCtx,SSL_OP_STRONG);
    SSL_CTX_ctrl(FSSLCtx,SSL_CTRL_SET_ECDH_AUTO,1,nil);
    SSL_CTX_add_extra_chain_cert(FSSLCtx,FSSLOptions.FCACert);
    SSL_CTX_use_certificate(FSSLCtx,FSSLOptions.FCert);
    SSL_CTX_use_PrivateKey(FSSLCtx,FSSLOptions.FPrivateKey);
    SSL_CTX_set_verify(FSSLCtx,SSL_VERIFY_PEER or SSL_VERIFY_CLIENT_ONCE,VerifyCallback);
    SSL_CTX_set_verify_depth(FSSLCtx,0);
    if FSSLOptions.FCiphers<>'' then SSL_CTX_set_cipher_list(FSSLCtx,PAnsiChar(FSSLOptions.FCiphers));
  end
  else
  begin
    FreeAndNil(fSSLContext);
    EIdOSSLCreatingContextError.RaiseException(RSSSLCreatingContextError);
  end;
end;
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
procedure TTCPClient.InitComponent;
begin
  LoadSSL;
  inherited;
  Host             := '';
  Port             := 0;
  FCert            := '';
  FCACert          := '';
  FPrivateKey      := '';
  FKeyPassword     := '';
  FP12             := nil;
  FPeerCertificate := '';
  FOnVerify        := nil;
  FOnConnect       := nil;
  FOnDisconnect    := nil;
  FSSLEnabled      := False;
  FSSLHandler      := TTCPSSLIOClient.Create(Self);
  IOHandler        := FSSLHandler;
end;

procedure TTCPClient.Connect;
begin
  FSSLHandler.PassThrough := (not FSSLEnabled);
  try
    inherited;
  except
  end;
end;

function TTCPClient.Connected: Boolean;
begin
  try
    Result := inherited;
  except
    Result := False;
  end;
end;

function TTCPClient.GetCert(Index: Integer): string;
begin
  case index of
    1: Result := FCACert;
    2: Result := FCert;
    3: Result := FPrivateKey;
    4: Result := FKeyPassword;
    5: Result := FCiphers;
  end;
end;

procedure TTCPClient.SetCert(Index:Integer;Value:string);
begin
  Value := Trim(Value);
  case index of
    1:
    begin
      FCACert                       := Value;
      FSSLHandler.SSLOptions.CACert := Value
    end;
    2:
    begin
      FCert                       := Value;
      FSSLHandler.SSLOptions.Cert := Value;
    end;
    3:
    begin
      FPrivateKey                       := Value;
      FSSLHandler.SSLOptions.PrivateKey := Value
    end;
    4:
    begin
      FKeyPassword                       := Value;
      FSSLHandler.SSLOptions.KeyPassword := Value
    end;
    5:
    begin
      FCiphers                       := Value;
      FSSLHandler.SSLOptions.Ciphers := Value
    end;
  end;
end;

procedure TTCPClient.DoOnConnected;
var
  SSLSocket : TTCPSSLSocket;
  x509      : PX509;
  OK        : Boolean;
begin
  FPeerCertificate := '';
  SSLSocket        := TTCPSSLSocket(TTCPSSLIOClient(FIOHandler).SSLSocket);
  if Assigned(SSLSocket) then
  begin
    try
      x509 := SSL_get_peer_certificate(SSLSocket.fSSL);
    except
      x509 := nil;
    end;
    FPeerCertificate := X509ToPEM(x509);
  end;
  if Assigned(FOnVerify) then OK := FOnVerify(Self,FPeerCertificate)
                         else OK := True;
  if (not OK) then
  begin
    try
      Disconnect;
    finally
    end;
    Exit;
  end;
  if Assigned(FOnConnect) then FOnConnect(Self);
end;

procedure TTCPClient.DoOnDisconnected;
begin
  try
    IOHandler.InputBuffer.Clear;
  except
  end;
  if Assigned(FOnDisconnect) then FOnDisconnect(Self);
end;
///////////////////////////////////////////////////////////////////////////
procedure TTCPServer.InitComponent;
begin
  LoadSSL;
  inherited;
  FCiphers      := SSLStrongCiphers;
  ContextClass  := TTCPContext;
  FCert         := '';
  FPrivateKey   := '';
  FCACert       := '';
  FKeyPassword  := '';
  FP12          := nil;
  FSSLEnabled   := False;
  FOnVerify     := nil;
  FOnConnect    := nil;
  FOnDisconnect := nil;
  FSSLHandler   := TTCPSSLIOServer.Create(Self);
end;

function TTCPServer.GetCert(Index: Integer): string;
begin
  case index of
    1: Result := FCACert;
    2: Result := FCert;
    3: Result := FPrivateKey;
    4: Result := FKeyPassword;
    5: Result := FCiphers;
  end;
end;

procedure TTCPServer.SetCert(Index:Integer;Value:string);
begin
  Value := Trim(Value);
  case index of
    1: FCACert      := Value;
    2: FCert        := Value;
    3: FPrivateKey  := Value;
    4: FKeyPassword := Value;
    5: FCiphers     := Value;
  end;
end;

procedure TTCPServer.SetActive(Value: Boolean);
begin
  if Value and FSSLEnabled then
  begin
    if FP12<>nil then
    begin
      FSSLHandler.FSSLOptions.CACert     := '';
      FSSLHandler.FSSLOptions.Cert       := '';
      FSSLHandler.FSSLOptions.PrivateKey := '';
      FSSLHandler.FSSLOptions.P12        := FP12;
    end
    else
    begin
      FSSLHandler.FSSLOptions.CACert     := FCACert;
      FSSLHandler.FSSLOptions.Cert       := FCert;
      FSSLHandler.FSSLOptions.PrivateKey := FPrivateKey;
    end;
    FSSLHandler.FSSLOptions.KeyPassword := FKeyPassword;
    FSSLHandler.FSSLOptions.Ciphers     := FCiphers;
    IOHandler                           := FSSLHandler;
  end
  else
  begin
    if Value then IOHandler := nil;
  end;
  try
    inherited SetActive(Value);
  except
  end;
end;

procedure TTCPServer.CheckOkToBeActive;
begin
  if not Assigned(FOnExecute) then raise EIdTCPNoOnExecute.Create(RSNoOnExecute);
end;

procedure TTCPServer.DoConnect(AContext:TIdContext);
var
  IOHandler : TIdIOHandler;
  SSLSocket : TTCPSSLSocket;
  x509      : PX509;
  OK        : Boolean;
begin
  if FSSLEnabled then
  begin
    IOHandler                              := TIdSSLIOHandlerSocketBase(AContext.Connection.IOHandler);
    TTCPSSLIOClient(IOHandler).PassThrough := False;
    SSLSocket                              := TTCPSSLSocket(TTCPSSLIOClient(IOHandler).SSLSocket);
    if Assigned(SSLSocket) then
    begin
      try
        x509 := SSL_get_peer_certificate(SSLSocket.fSSL);
      except
        x509 := nil;
      end;
      TTCPContext(AContext).FPeerCertificate := X509ToPEM(x509);
    end;
    if Assigned(FOnVerify) then OK := FOnVerify(TTCPContext(AContext),TTCPContext(AContext).FPeerCertificate)
                           else OK := True;
  end
  else OK := True;
  if (not OK) then
  begin
    try
      AContext.Connection.Disconnect;
    finally
    end;
    Exit;
  end;
  if Assigned(FOnConnect) then FOnConnect(TTCPContext(AContext));
end;

procedure TTCPServer.DoDisconnect(AContext:TIdContext);
begin
  if Assigned(FOnDisconnect) then FOnDisconnect(TTCPContext(AContext));
end;

function TTCPServer.DoExecute(AContext:TIdContext):Boolean;
begin
  Result := FOnExecute(TTCPContext(AContext));
end;

end.
