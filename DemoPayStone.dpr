program DemoPayStone;

uses
  System.StartUpCopy,
  FMX.Forms,
  Main.View in 'Main.View.pas' {FormMain},
  StoneApi in 'Classes\StoneApi.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
