program musicbox;

uses
  Forms,
  main in 'main.pas' {Form1},
  password in 'password.pas' {Form2},
  pic in 'pic.pas' {f3};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(Tf3, f3);
  Application.Run;
end.
