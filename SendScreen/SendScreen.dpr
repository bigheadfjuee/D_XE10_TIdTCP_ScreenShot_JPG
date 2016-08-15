program SendScreen;

uses
  Vcl.Forms,
  uSendScreen in 'uSendScreen.pas' {FormSendScreen},
  UnitGlobal in '..\UnitGlobal.pas',
  uThread in 'uThread.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormSendScreen, FormSendScreen);
  Application.Run;
end.
