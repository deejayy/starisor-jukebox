unit pic;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls;

type
  Tf3 = class(TForm)
    i1: TImage;
    procedure i1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  f3: Tf3;

implementation

{$R *.dfm}

uses main;

procedure Tf3.i1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  form1.Label1MouseDown( sender, button, shift, x, y );
end;

end.
