program RecvScreen;

uses
  Vcl.Forms,
  uRecvScreen in 'uRecvScreen.pas' {FormRecvScreen},
  UnitGlobal in '..\UnitGlobal.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormRecvScreen, FormRecvScreen);
  Application.Run;
end.
