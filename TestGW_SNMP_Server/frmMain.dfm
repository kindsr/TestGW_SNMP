object Main: TMain
  Left = 0
  Top = 0
  Caption = 'Test Gateway Server for AIS'
  ClientHeight = 612
  ClientWidth = 588
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 588
    Height = 91
    Align = alTop
    BevelOuter = bvNone
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 0
    DesignSize = (
      588
      91)
    object Label1: TLabel
      Left = 439
      Top = 5
      Width = 77
      Height = 13
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      Caption = 'TCP Server Port'
      ExplicitLeft = 575
    end
    object Label2: TLabel
      Left = 439
      Top = 27
      Width = 78
      Height = 13
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      Caption = 'UDP Server Port'
      ExplicitLeft = 575
    end
    object Label3: TLabel
      Left = 481
      Top = 49
      Width = 35
      Height = 13
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      Caption = 'Host IP'
      ExplicitLeft = 617
    end
    object Label4: TLabel
      Left = 471
      Top = 71
      Width = 45
      Height = 13
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      Caption = 'Host Port'
      ExplicitLeft = 607
    end
    object btnTCPServer: TButton
      Left = 0
      Top = 0
      Width = 75
      Height = 91
      Align = alLeft
      Caption = 'TCP Server Start'
      TabOrder = 0
      WordWrap = True
      OnClick = btnTCPServerClick
    end
    object btnUDPServer: TButton
      Left = 75
      Top = 0
      Width = 75
      Height = 91
      Align = alLeft
      Caption = 'UDP Server Start'
      TabOrder = 1
      WordWrap = True
      OnClick = btnUDPServerClick
    end
    object edtTCPPort: TEdit
      Left = 520
      Top = 2
      Width = 64
      Height = 21
      Anchors = [akTop, akRight]
      NumbersOnly = True
      TabOrder = 2
      Text = '10151'
    end
    object edtUDPPort: TEdit
      Left = 520
      Top = 24
      Width = 64
      Height = 21
      Anchors = [akTop, akRight]
      NumbersOnly = True
      TabOrder = 3
      Text = '10161'
    end
    object edtHostIP: TEdit
      Left = 520
      Top = 46
      Width = 64
      Height = 21
      Anchors = [akTop, akRight]
      TabOrder = 4
      Text = '127.0.0.1'
    end
    object edtPort: TEdit
      Left = 520
      Top = 68
      Width = 64
      Height = 21
      Anchors = [akTop, akRight]
      NumbersOnly = True
      TabOrder = 5
      Text = '10162'
    end
    object btnTCPClient: TButton
      Left = 150
      Top = 0
      Width = 75
      Height = 91
      Align = alLeft
      Caption = 'TCP Client Start'
      TabOrder = 6
      WordWrap = True
      OnClick = btnTCPClientClick
    end
    object btnClear: TButton
      Left = 225
      Top = 0
      Width = 75
      Height = 91
      Align = alLeft
      Caption = 'Clear'
      TabOrder = 7
      WordWrap = True
      OnClick = btnClearClick
    end
    object btnAgent: TButton
      Left = 300
      Top = 0
      Width = 75
      Height = 91
      Align = alLeft
      Caption = 'Agents'
      TabOrder = 8
      WordWrap = True
      OnClick = btnAgentClick
    end
    object edVal1: TEdit
      Left = 381
      Top = 2
      Width = 36
      Height = 21
      Anchors = [akTop, akRight]
      NumbersOnly = True
      TabOrder = 9
      Text = '100'
    end
    object edVal2: TEdit
      Left = 381
      Top = 24
      Width = 36
      Height = 21
      Anchors = [akTop, akRight]
      NumbersOnly = True
      TabOrder = 10
      Text = '100'
    end
    object edVal3: TEdit
      Left = 381
      Top = 46
      Width = 36
      Height = 21
      Anchors = [akTop, akRight]
      NumbersOnly = True
      TabOrder = 11
      Text = '100'
    end
    object edVal4: TEdit
      Left = 381
      Top = 68
      Width = 36
      Height = 21
      Anchors = [akTop, akRight]
      TabOrder = 12
      Text = '100'
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 91
    Width = 588
    Height = 521
    Align = alClient
    BevelOuter = bvNone
    Caption = 'Panel2'
    ShowCaption = False
    TabOrder = 1
    object ListBox1: TListBox
      Left = 0
      Top = 0
      Width = 588
      Height = 521
      Align = alClient
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = #45208#45588#44256#46357#53076#46377
      Font.Style = []
      ItemHeight = 13
      ParentFont = False
      TabOrder = 0
    end
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 5000
    Left = 512
    Top = 184
  end
  object IdTCPClient1: TIdTCPClient
    ConnectTimeout = 0
    Host = '127.0.0.1'
    IPVersion = Id_IPv4
    Port = 13102
    ReadTimeout = -1
    Left = 432
    Top = 128
  end
  object IdTCPServer1: TIdTCPServer
    Bindings = <>
    DefaultPort = 50001
    OnConnect = IdTCPServer1Connect
    OnDisconnect = IdTCPServer1Disconnect
    OnExecute = IdTCPServer1Execute
    Left = 352
    Top = 128
  end
  object IdUDPServer1: TIdUDPServer
    Bindings = <>
    DefaultPort = 60001
    ThreadedEvent = True
    OnUDPRead = IdUDPServer1UDPRead
    Left = 512
    Top = 128
  end
  object IdAntiFreeze1: TIdAntiFreeze
    Left = 272
    Top = 128
  end
end
