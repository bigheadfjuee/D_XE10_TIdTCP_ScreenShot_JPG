unit uRecvScreen;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdContext, IdBaseComponent, IdComponent,
  IdCustomTCPServer, IdTCPServer, Vcl.StdCtrls, IdGlobal, IdException,
  IdSocketHandle, IdThread, IdSync, jpeg,
  Vcl.ExtCtrls, UnitGlobal;

type
  TMyIdNotify = class(TIdNotify)
  protected
    procedure DoNotify; override;
  public
    mMyData: TMyData;
    isMyData: Boolean;
    strMsg: String;
  end;

type
  TFormRecvScreen = class(TForm)
    Memo1: TMemo;
    BtnStart: TButton;
    BtnStop: TButton;
    BtnBroadcast: TButton;
    IdTCPServer1: TIdTCPServer;
    LedtPort: TLabeledEdit;
    ListBoxClient: TListBox;
    edtSend: TEdit;
    btnSend: TButton;
    btnClearMemo: TButton;
    Panel1: TPanel;
    Panel2: TPanel;
    ImageScrollBox: TScrollBox;
    imgShot: TImage;
    Panel3: TPanel;
    procedure IdTCPServer1Execute(AContext: TIdContext);
    procedure BtnStartClick(Sender: TObject);
    procedure BtnStopClick(Sender: TObject);
    procedure IdTCPServer1AfterBind(Sender: TObject);
    procedure IdTCPServer1BeforeBind(AHandle: TIdSocketHandle);
    procedure IdTCPServer1BeforeListenerRun(AThread: TIdThread);
    procedure IdTCPServer1Connect(AContext: TIdContext);
    procedure IdTCPServer1ContextCreated(AContext: TIdContext);
    procedure IdTCPServer1Disconnect(AContext: TIdContext);
    procedure IdTCPServer1Exception(AContext: TIdContext;
      AException: Exception);
    procedure IdTCPServer1ListenException(AThread: TIdListenerThread;
      AException: Exception);
    procedure IdTCPServer1Status(ASender: TObject; const AStatus: TIdStatus;
      const AStatusText: string);
    procedure BtnBroadcastClick(Sender: TObject);
    procedure btnSendClick(Sender: TObject);
    procedure btnClearMemoClick(Sender: TObject);
    procedure edtSendKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private

    procedure SendMessage;
    procedure Multi_cast;

    { Private declarations }
  public
    { Public declarations }
    procedure StopServer;
  end;

  // --------------------------------------------
type
  TMyContext = class(TIdContext)
  public
    UserName: String;
    Password: String;
  end;

var
  FormRecvScreen: TFormRecvScreen;

implementation

{$R *.dfm}

procedure TFormRecvScreen.BtnBroadcastClick(Sender: TObject);
begin
  Multi_cast;
end;

procedure TFormRecvScreen.btnClearMemoClick(Sender: TObject);
begin
  Memo1.Lines.Clear;
end;

procedure TFormRecvScreen.btnSendClick(Sender: TObject);
var
  str: TStringBuilder;
begin
  SendMessage;
end;

procedure TFormRecvScreen.BtnStartClick(Sender: TObject);
begin
  IdTCPServer1.Bindings.DefaultPort := StrToInt(LedtPort.Text);

  Memo1.Lines.Add(IdTCPServer1.Bindings.DefaultPort.ToString());
  try
    IdTCPServer1.Active := True;
  except
    on E: EIdException do
      Memo1.Lines.Add('== EIdException: ' + E.Message);
  end;

  BtnStop.Enabled := True;
end;

procedure TFormRecvScreen.BtnStopClick(Sender: TObject);
begin
  StopServer;
end;

procedure TFormRecvScreen.edtSendKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    Multi_cast;
end;

procedure TFormRecvScreen.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  StopServer;
end;

procedure TFormRecvScreen.SendMessage;
var
  List: TList;
  str: TStringBuilder;
begin
  if ListBoxClient.ItemIndex = -1 then
  begin
    Memo1.Lines.Add('請選擇一個 Client');
  end
  else
  begin

    try
      List := IdTCPServer1.Contexts.LockList;
      if List.Count = 0 then
      begin
        exit;
      end;
      TIdContext(List[ListBoxClient.ItemIndex]).Connection.IOHandler.WriteLn
        (edtSend.Text, IndyTextEncoding_UTF8);
    finally
      IdTCPServer1.Contexts.UnlockList;
    end;

    str := TStringBuilder.Create;
    str.Append('SendMessage(');
    str.Append(ListBoxClient.Items[ListBoxClient.ItemIndex]);
    str.Append('): ');
    str.Append(edtSend.Text);
    Memo1.Lines.Add(str.ToString);
    str.DisposeOf;
  end;

end;

procedure TFormRecvScreen.Multi_cast;
var
  List: TList;
  I: Integer;
begin
  List := IdTCPServer1.Contexts.LockList;
  try
    if List.Count = 0 then
    begin
      Memo1.Lines.Add('沒有Client連線！');
      exit;
    end
    else
      Memo1.Lines.Add('Multi_cast:' + edtSend.Text);

    for I := 0 to List.Count - 1 do
    begin
      try
        TIdContext(List[I]).Connection.IOHandler.WriteLn(edtSend.Text,
          IndyTextEncoding_UTF8);

      except
        on E: EIdException do
          Memo1.Lines.Add('== EIdException: ' + E.Message);
      end;
    end;

  finally
    IdTCPServer1.Contexts.UnlockList;
  end;

end;

procedure TFormRecvScreen.IdTCPServer1AfterBind(Sender: TObject);
begin
  Memo1.Lines.Add('S-AfterBind');
end;

procedure TFormRecvScreen.IdTCPServer1BeforeBind(AHandle: TIdSocketHandle);
begin
  Memo1.Lines.Add('S-BeforeBind');
end;

procedure TFormRecvScreen.IdTCPServer1BeforeListenerRun(AThread: TIdThread);
begin
  Memo1.Lines.Add('S-BeforeListenerRun');
end;

procedure TFormRecvScreen.IdTCPServer1Connect(AContext: TIdContext);
var
  str: String;
begin
  str := AContext.Binding.PeerIP + '_' + AContext.Binding.PeerPort.ToString;
  Memo1.Lines.Add(DateTimeToStr(Now));
  Memo1.Lines.Add('S-Connect: ' + str);

  ListBoxClient.Items.Add(str);
  // 自動選擇最後新增的
  if ListBoxClient.Count > -1 then
    ListBoxClient.ItemIndex := ListBoxClient.Count - 1;
end;

procedure TFormRecvScreen.IdTCPServer1ContextCreated(AContext: TIdContext);
var
  str: String;
begin
  str := AContext.Binding.PeerIP + '_' + AContext.Binding.PeerPort.ToString;
  Memo1.Lines.Add(DateTimeToStr(Now));
  Memo1.Lines.Add('S-ContextCreated ' + str);
end;

procedure TFormRecvScreen.IdTCPServer1Disconnect(AContext: TIdContext);
var
  Index: integer;
  str: String;
begin
  str := AContext.Binding.PeerIP + '_' + AContext.Binding.PeerPort.ToString;
  Index := ListBoxClient.Items.IndexOf(str);
  ListBoxClient.Items.Delete(index);
  Memo1.Lines.Add(DateTimeToStr(Now));
  Memo1.Lines.Add('S-Disconnect: ' + str);
end;

procedure TFormRecvScreen.IdTCPServer1Exception(AContext: TIdContext;
  AException: Exception);
begin
  Memo1.Lines.Add('S-Exception:' + AException.Message);
end;

procedure TMyIdNotify.DoNotify;
begin
  if isMyData then
  begin
    with FormRecvScreen.Memo1.Lines do
    begin
      Add('ID:' + Inttostr(mMyData.Id));
      Add('Name:' + StrPas(mMyData.Name));
      Add('Sex:' + mMyData.sex);
      Add('Age:' + Inttostr(mMyData.age));
      Add('UpdateTime:' + DateTimeToStr(mMyData.UpdateTime));
    end;
  end
  else
  begin
    FormRecvScreen.Memo1.Lines.Add(strMsg);
  end;

end;

// 元件內建的 thread ？
procedure TFormRecvScreen.IdTCPServer1Execute(AContext: TIdContext);
var
  size: integer;
  mStream: TMemoryStream;
  jpg: TJpegImage;
  temp: TIdBytes;

begin

  // ScreenThief 的方式

  size := AContext.Connection.IOHandler.ReadUInt64;
  mStream := TMemoryStream.Create;
  AContext.Connection.IOHandler.ReadStream(mStream, size, False);

  jpg := TJpegImage.Create;
  try
    mStream.Position := 0;
    jpg.LoadFromStream(mStream);
    imgShot.Picture.Assign(jpg);
  finally
    jpg.DisposeOf;
  end;

end;

procedure TFormRecvScreen.IdTCPServer1ListenException
  (AThread: TIdListenerThread; AException: Exception);
begin
  Memo1.Lines.Add('S-ListenException: ' + AException.Message);
end;

procedure TFormRecvScreen.IdTCPServer1Status(ASender: TObject;
  const AStatus: TIdStatus; const AStatusText: string);
begin
  Memo1.Lines.Add(DateTimeToStr(Now));
  Memo1.Lines.Add('S-Status: ' + AStatusText);
end;

procedure TFormRecvScreen.StopServer;
var
  Index: integer;
  Context: TIdContext;
begin
  if IdTCPServer1.Active then
  begin
    IdTCPServer1.OnDisconnect := nil;
    ListBoxClient.Clear;

    with IdTCPServer1.Contexts.LockList do
    begin
      if Count > 0 then
      begin
        try
          for index := 0 to Count - 1 do
          begin
            Context := Items[index];
            if Context = nil then
              continue;
            Context.Connection.IOHandler.WriteBufferClear;
            Context.Connection.IOHandler.InputBuffer.Clear;
            Context.Connection.IOHandler.Close;

            if Context.Connection.Connected then
              Context.Connection.Disconnect;
          end;
        finally
          IdTCPServer1.Contexts.UnlockList;
        end;
      end;
    end;

    try
       IdTCPServer1.Active := False;
    except
      on E: EIdException do
        Memo1.Lines.Add('== EIdException: ' + E.Message);
    end;
  end;
  IdTCPServer1.OnDisconnect := IdTCPServer1Disconnect;
end;

end.
