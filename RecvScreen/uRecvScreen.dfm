object FormRecvScreen: TFormRecvScreen
  Left = 0
  Top = 0
  Caption = 'FormRecvScreen'
  ClientHeight = 539
  ClientWidth = 733
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Consolas'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 17
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 733
    Height = 137
    Align = alTop
    Caption = 'Panel1'
    TabOrder = 0
    object BtnBroadcast: TButton
      Left = 253
      Top = 93
      Width = 79
      Height = 39
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'To All'
      TabOrder = 0
      OnClick = BtnBroadcastClick
    end
    object btnClearMemo: TButton
      Left = 336
      Top = 93
      Width = 60
      Height = 39
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'Clear'
      TabOrder = 1
      OnClick = btnClearMemoClick
    end
    object btnSend: TButton
      Left = 189
      Top = 93
      Width = 60
      Height = 40
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'Send'
      TabOrder = 2
      OnClick = btnSendClick
    end
    object Memo1: TMemo
      Left = 0
      Top = 2
      Width = 417
      Height = 87
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Lines.Strings = (
        'Memo1')
      ScrollBars = ssVertical
      TabOrder = 3
    end
    object Panel3: TPanel
      Left = 448
      Top = 7
      Width = 276
      Height = 124
      Caption = 'Panel3'
      TabOrder = 4
      object BtnStart: TButton
        Left = 10
        Top = 53
        Width = 60
        Height = 36
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Caption = 'Start'
        TabOrder = 0
        OnClick = BtnStartClick
      end
      object BtnStop: TButton
        Left = 10
        Top = 90
        Width = 60
        Height = 35
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Caption = 'Stop'
        Enabled = False
        TabOrder = 1
        OnClick = BtnStopClick
      end
      object LedtPort: TLabeledEdit
        Left = 10
        Top = 24
        Width = 60
        Height = 25
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        EditLabel.Width = 40
        EditLabel.Height = 17
        EditLabel.Margins.Left = 2
        EditLabel.Margins.Top = 2
        EditLabel.Margins.Right = 2
        EditLabel.Margins.Bottom = 2
        EditLabel.Caption = 'Port:'
        TabOrder = 2
        Text = '54321'
      end
      object ListBoxClient: TListBox
        Left = 74
        Top = 8
        Width = 166
        Height = 108
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        ItemHeight = 17
        TabOrder = 3
      end
    end
    object edtSend: TEdit
      Left = 0
      Top = 98
      Width = 185
      Height = 25
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 5
      Text = 'TakeShot'
      OnKeyDown = edtSendKeyDown
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 137
    Width = 733
    Height = 402
    Align = alClient
    Caption = 'Panel2'
    TabOrder = 1
    object ImageScrollBox: TScrollBox
      Left = 1
      Top = 1
      Width = 731
      Height = 400
      HorzScrollBar.Smooth = True
      VertScrollBar.Smooth = True
      Align = alClient
      TabOrder = 0
      object imgShot: TImage
        Left = -3
        Top = 3
        Width = 153
        Height = 177
        AutoSize = True
      end
    end
  end
  object IdTCPServer1: TIdTCPServer
    OnStatus = IdTCPServer1Status
    Bindings = <>
    DefaultPort = 0
    OnBeforeBind = IdTCPServer1BeforeBind
    OnAfterBind = IdTCPServer1AfterBind
    OnBeforeListenerRun = IdTCPServer1BeforeListenerRun
    OnContextCreated = IdTCPServer1ContextCreated
    OnConnect = IdTCPServer1Connect
    OnDisconnect = IdTCPServer1Disconnect
    OnException = IdTCPServer1Exception
    OnListenException = IdTCPServer1ListenException
    OnExecute = IdTCPServer1Execute
    Left = 152
    Top = 8
  end
end
