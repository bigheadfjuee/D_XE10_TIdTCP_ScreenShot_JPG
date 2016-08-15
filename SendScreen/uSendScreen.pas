unit uSendScreen;

interface

// IdGlobal =>  用到 TIdBytes, RawToBytes
//
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdContext,
  IdCustomTCPServer, IdTCPServer, IdGlobal, IdException, Vcl.ExtCtrls,
  UnitGlobal, uThread, jpeg;

type
  TFormSendScreen = class(TForm)
    IdTCPClient1: TIdTCPClient;
    Memo1: TMemo;
    tmrAutoConnect: TTimer;
    BtnStart: TButton;
    BtnStop: TButton;
    edtHost: TLabeledEdit;
    edtPort: TLabeledEdit;
    BtnClearMemo: TButton;
    btnDiscon: TButton;
    tmrShot: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tmrAutoConnectTimer(Sender: TObject);
    procedure IdTCPClient1Connected(Sender: TObject);
    procedure BtnStopClick(Sender: TObject);
    procedure BtnStartClick(Sender: TObject);
    procedure IdTCPClient1AfterBind(Sender: TObject);
    procedure IdTCPClient1BeforeBind(Sender: TObject);
    procedure IdTCPClient1Disconnected(Sender: TObject);
    procedure IdTCPClient1SocketAllocated(Sender: TObject);
    procedure IdTCPClient1Status(ASender: TObject; const AStatus: TIdStatus;
      const AStatusText: string);
    procedure IdTCPClient1Work(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
    procedure IdTCPClient1WorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Int64);
    procedure IdTCPClient1WorkEnd(ASender: TObject; AWorkMode: TWorkMode);
    procedure BtnClearMemoClick(Sender: TObject);
    procedure btnDisconClick(Sender: TObject);
    procedure tmrShotTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    thread: TReadThread;

    procedure InitConnectGUI(init: Boolean);

    procedure MyScreenShot(x: integer; y: integer; Width: integer;
      Height: integer; bm: TBitmap);

  public
    { Public declarations }
    procedure ParseCmd(cmd: String);
  end;

var
  FormSendScreen: TFormSendScreen;

procedure BMPtoJPGStream(const Bitmap: TBitmap; var AStream: TMemoryStream);

implementation

{$R *.dfm}

procedure TFormSendScreen.FormCreate(Sender: TObject);
var
  x: integer;
begin
  edtHost.text := IdTCPClient1.Host;
  edtPort.text := IntToStr(IdTCPClient1.Port);

  InitConnectGUI(True);
end;

procedure TFormSendScreen.FormShow(Sender: TObject);
begin
  BtnStartClick(Sender);
end;

procedure TFormSendScreen.IdTCPClient1AfterBind(Sender: TObject);
begin
  Memo1.Lines.Add('C-AfterBind');
end;

procedure TFormSendScreen.IdTCPClient1BeforeBind(Sender: TObject);
begin
  Memo1.Lines.Add('C-BeforeBind');
end;

procedure TFormSendScreen.IdTCPClient1Connected(Sender: TObject);
begin
  Memo1.Lines.Add(DateTimeToStr(Now));
  Memo1.Lines.Add('C-Connected');
  BtnStop.Enabled := False;

  // 用 thread 的方法
  thread := TReadThread.Create;
  thread.IdTCPClient := IdTCPClient1;
  thread.FreeOnTerminate := true;

  // 用 timer 的方法
  // tmReadLn.Enabled := True;
end;

procedure TFormSendScreen.IdTCPClient1Disconnected(Sender: TObject);
begin

  thread.Terminate;
  Memo1.Lines.Add(DateTimeToStr(Now));
  Memo1.Lines.Add('C-Disconnected');
end;

procedure TFormSendScreen.IdTCPClient1SocketAllocated(Sender: TObject);
begin
  Memo1.Lines.Add('C-SocketAllocated');
end;

procedure TFormSendScreen.IdTCPClient1Status(ASender: TObject;
  const AStatus: TIdStatus; const AStatusText: string);
begin
  Memo1.Lines.Add(DateTimeToStr(Now));
  Memo1.Lines.Add('C-Status: ' + AStatusText);
end;

procedure TFormSendScreen.IdTCPClient1Work(ASender: TObject;
  AWorkMode: TWorkMode; AWorkCount: Int64);
begin
  // Memo1.Lines.Add('C-Client1Work');
end;

procedure TFormSendScreen.IdTCPClient1WorkBegin(ASender: TObject;
  AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin
  // Memo1.Lines.Add('C-WorkBegin');
end;

procedure TFormSendScreen.IdTCPClient1WorkEnd(ASender: TObject;
  AWorkMode: TWorkMode);
begin
  // Memo1.Lines.Add('C-WorkEnd');
end;

procedure TFormSendScreen.tmrAutoConnectTimer(Sender: TObject);
begin
  if not IdTCPClient1.Connected then
  begin
    Memo1.Lines.Add('Timer1每5秒自動連線中…');
    try
      IdTCPClient1.Connect;
    except
      on E: EIdException do
        Memo1.Lines.Add('== EIdException: ' + E.Message);
    end;
  end
  else
  begin
    tmrAutoConnect.Enabled := False;
    Memo1.Lines.Add('自動連線已連上，關閉tmrAutoConnect');
  end;
end;

procedure TFormSendScreen.tmrShotTimer(Sender: TObject);
var
  JpegStream: TMemoryStream;
  pic: TBitmap;
begin

  if not IdTCPClient1.Connected then
    Exit;

  // Memo1.Lines.Insert(0, 'Sending screen shot:    ' + DateTimeToStr(Now));

  pic := TBitmap.Create;
  JpegStream := TMemoryStream.Create;
  MyScreenShot(0, 0, screen.Width, screen.Height, pic);
  BMPtoJPGStream(pic, JpegStream);
  pic.FreeImage;
  pic.DisposeOf;

  // copy file stream to write stream
  IdTCPClient1.IOHandler.Write(JpegStream.Size);
  IdTCPClient1.IOHandler.WriteBufferOpen;
  IdTCPClient1.IOHandler.Write(JpegStream);
  IdTCPClient1.IOHandler.WriteBufferClose;
  JpegStream.DisposeOf;

end;

procedure TFormSendScreen.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if IdTCPClient1.Connected then
  begin
    // Sleep(500);
    try
      IdTCPClient1.Disconnect;
    except
      on E: EIdException do
        ShowMessage('EIdException: ' + E.Message);
    end;
  end;

end;

procedure TFormSendScreen.BtnClearMemoClick(Sender: TObject);
begin
  Memo1.Clear;
end;

procedure TFormSendScreen.btnDisconClick(Sender: TObject);
begin
  IdTCPClient1.Disconnect;
  InitConnectGUI(False);
end;

procedure TFormSendScreen.BtnStartClick(Sender: TObject);
begin
  IdTCPClient1.Host := edtHost.text;
  IdTCPClient1.Port := StrToInt(edtPort.text);

  Memo1.Lines.Add('tmrAutoConnect已啟動，稍待 ' + FloatToStr(tmrAutoConnect.Interval /
    1000) + ' 秒');

  InitConnectGUI(true);
end;

procedure TFormSendScreen.InitConnectGUI(init: Boolean);
begin
  tmrAutoConnect.Enabled := init;
  BtnStart.Enabled := not init;
  BtnStop.Enabled := init;
  btnDiscon.Enabled := init;
end;

procedure TFormSendScreen.BtnStopClick(Sender: TObject);
begin
  InitConnectGUI(False);
end;

procedure TFormSendScreen.ParseCmd(cmd: String);
begin
  Memo1.Lines.Add(cmd);
  if cmd = 'TakeShot' then
  begin
    tmrShot.Enabled := true;

  end;
end;

procedure TFormSendScreen.MyScreenShot(x: integer; y: integer; Width: integer;
  Height: integer; bm: TBitmap);
var
  dc: HDC;
  lpPal: PLOGPALETTE;
begin
  { test width and height }
  if ((Width = 0) OR (Height = 0)) then
    Exit;
  bm.Width := Width;
  bm.Height := Height;
  { get the screen dc }
  dc := GetDc(0);
  if (dc = 0) then
    Exit;
  { do we have a palette device? }
  if (GetDeviceCaps(dc, RASTERCAPS) AND RC_PALETTE = RC_PALETTE) then
  begin
    { allocate memory for a logical palette }
    GetMem(lpPal, SizeOf(TLOGPALETTE) + (255 * SizeOf(TPALETTEENTRY)));
    { zero it out to be neat }
    FillChar(lpPal^, SizeOf(TLOGPALETTE) + (255 * SizeOf(TPALETTEENTRY)), #0);
    { fill in the palette version }
    lpPal^.palVersion := $300;
    { grab the system palette entries }
    lpPal^.palNumEntries := GetSystemPaletteEntries(dc, 0, 256,
      lpPal^.palPalEntry);
    if (lpPal^.palNumEntries <> 0) then
    begin
      { create the palette }
      bm.Palette := CreatePalette(lpPal^);
    end;
    FreeMem(lpPal, SizeOf(TLOGPALETTE) + (255 * SizeOf(TPALETTEENTRY)));
  end;
  { copy from the screen to the bitmap }
  BitBlt(bm.Canvas.Handle, 0, 0, Width, Height, dc, x, y, SRCCOPY);
  { release the screen dc }
  ReleaseDc(0, dc);
end; (* ScreenShot *)

// convert BMP to JPEG
procedure BMPtoJPGStream(const Bitmap: TBitmap; var AStream: TMemoryStream);
var
  JpegImg: TJpegImage;
begin
  JpegImg := TJpegImage.Create;
  try
    // JpegImg.CompressionQuality := 50;
    JpegImg.PixelFormat := jf8Bit;
    JpegImg.Assign(Bitmap);
    JpegImg.SaveToStream(AStream);
  finally
    JpegImg.Free
  end;
end; (* BMPtoJPG *)

end.
