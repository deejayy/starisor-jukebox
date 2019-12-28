unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, MPlayer, OleCtrls, ioplug, inifiles;

type
  TForm1 = class(TForm)
    l2: TLabel;
    l1: TLabel;
    i1: TImage;
    ls1: TListBox;
    ls2: TListBox;
    Label2: TLabel;
    i2: TImage;
    ls4: TListBox;
    ls3: TListBox;
    bg1: TImage;
    i3: TImage;
    up1: TImage;
    up2: TImage;
    dn2: TImage;
    dn1: TImage;
    ls5: TListBox;
    up3: TImage;
    dn3: TImage;
    up4: TImage;
    dn4: TImage;
    Timer1: TTimer;
    m1: TMemo;
    ltitle: TLabel;
    i4: TImage;
    i6: TImage;
    i8: TImage;
    i9: TImage;
    i10: TImage;
    i11: TImage;
    i12: TImage;
    i13: TImage;
    procedure FormCreate(Sender: TObject);
    procedure i1Click(Sender: TObject);
    procedure ls1Click(Sender: TObject);
    procedure i2Click(Sender: TObject);
    procedure i3Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Label1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure playrandom;
    procedure up2Click(Sender: TObject);
    procedure dn2Click(Sender: TObject);
    procedure up4Click(Sender: TObject);
    procedure dn4Click(Sender: TObject);
    procedure dn5Click(Sender: TObject);
    procedure up5Click(Sender: TObject);
    procedure up3Click(Sender: TObject);
    procedure dn3Click(Sender: TObject);
    procedure dn1Click(Sender: TObject);
    procedure up1Click(Sender: TObject);
    procedure i6Click(Sender: TObject);
    procedure i8Click(Sender: TObject);
    procedure i9Click(Sender: TObject);
    procedure i10Click(Sender: TObject);
    procedure i11Click(Sender: TObject);
    procedure i12Click(Sender: TObject);
    procedure ls5Click(Sender: TObject);
    procedure i13Click(Sender: TObject);
  private
    { Private declarations }
  public
    procedure queue( s: string );
  end;

  procedure Delay( MS: longword );

var
  Form1: TForm1;
  wd, musicpath, videopath: string;
  idlecounter, counter: integer;
  noclick: boolean;
  imod:^TIn_module;
  omod:^TOut_module;
  str: tstringlist;

implementation

uses password, pic;

{$R *.dfm}

procedure SetInfo1(bitrate,srate,stereo,synched:integer);cdecl; // if -1, changes ignored? :)
begin
end;

function dsp_isactive1:integer;cdecl;
begin
  result:=0;
end;

function dsp_dosamples1(samples:pointer; numsamples, bps,  nch, srate:integer):integer;cdecl;
begin
 result:=numsamples;

end;


procedure SAVSAInit1(maxlatency_in_ms:integer;srate:integer);cdecl;
begin
end;

procedure SAVSADeInit1;cdecl;   // call in Stop()
begin
end;
procedure SAAddPCMData1(PCMData:pointer;nch:integer;bps:integer;timestamp:integer);cdecl;
begin
end;
function SAGetMode1:integer;cdecl;              // gets csa (the current type (4=ws,2=osc,1=spec))
begin
result:=0;
end;
procedure SAAdd1(data:pointer; timestamp:integer;csa:integer);cdecl; // sets the spec data, filled in by winamp
begin
end;
procedure VSAAddPCMData1(PCMData:pointer;nch: integer ; bps:integer;timestamp:integer);cdecl; // sets the vis data directly from PCM data
begin
end;
function VSAGetMode1(var specNch:integer; var waveNch:integer):integer;cdecl; // use to figure out what to give to VSAAdd
begin
result:=0;
end;
procedure VSAAdd1(data:pointer; timestamp:integer);cdecl; // filled in by winamp, called by plug-in
begin
end;
procedure VSASetInfo1(nch:integer;srate:integer);cdecl;
begin
end;

procedure savetolog( fn, s: string );
var

  f: textfile;
begin
  assignfile( f, fn );
  {$I-} append( f ); if IOResult <> 0 then rewrite( f ); {$I+}
    writeln( f, s );
  closefile( f );
end;

procedure Delay( MS: longword );
  var

     FirstTickCount:longword;

  begin
    FirstTickCount := GetTickCount;
    repeat until GetTickCount - FirstTickCount >= MS;
  end;

procedure TForm1.FormCreate(Sender: TObject);
var

  ts: tsearchrec;
  i : integer;
  f: textfile;
  s: string;
  ini: tinifile;

begin
  getdir( 0, wd );

  str := tstringlist.create;
  if fileexists( wd + '\top.txt' ) then str.LoadFromFile( wd + '\top.txt' )
  else str.SaveToFile( wd + '\top.txt' );
  str.sort;

  counter := 1;

  s := lowercase( copy( paramstr( 0 ), 1, pos( '.exe', lowercase( paramstr( 0 ) ) ) ) );
  ini := tinifile.create( s + 'ini' );
  musicpath := ini.ReadString( 'main', 'musicpath', wd + '\songs' );
  videopath := ini.ReadString( 'main', 'videopath', wd + '\clips');
  ini.writeString( 'main', 'musicpath', musicpath );
  ini.writeString( 'main', 'videopath', videopath );
  ini.Destroy;

  form1.Left := 0;
  form1.Top := 0;

  s := '0';
  if fileexists( 'money' ) then begin assignfile( f, 'money' ); reset( f ); readln( f, s ); closefile( f );
  l1.caption := s; end;
  if fileexists( 'list.txt' ) then m1.lines.LoadFromFile( 'list.txt' );
  if fileexists( 'pics\bg1.bmp' ) then bg1.Picture.LoadFromFile( 'pics\bg1.bmp' );

  i := findfirst( musicpath + '\*.*', $3F, ts );
  while i <> 18 do begin
    if ( ts.name <> '.' ) and ( ts.name <> '..' ) then ls1.items.add( ts.Name );
    i := findnext( ts );
  end;

  initInputDll( '.\plugz\input.dll');

  imod:=getinmodule;
  imod.hMainWindow:=application.Handle;
  imod.hDllInstance:=InputDllHandle;
  imod.init;
  imod.SetInfo:=SetInfo1;
  imod.dsp_IsActive:=dsp_isactive1;
  imod.dsp_dosamples:=dsp_dosamples1;
  imod.SAVSAInit:=SAVSAInit1;
  imod.SAVSADeInit:=SAVSADeinit1;
  imod.SAAddPCMData:=SAAddPCMData1;
  imod.SAGetMode:=SAGetMode1;
  imod.SAAdd:=SAADD1;
  imod.VSASetInfo:=VSASetInfo1;
  imod.VSAAddPCMData:=VSAAddPCMData1;
  imod.VSAGetMode:=VSAGetMode1;
  imod.VSAAdd:=VSAAdd1;

  initOutputDll('.\plugz\output.dll');

  omod:=getoutmodule;
  omod.hMainWindow:=application.Handle;
  omod.hDllInstance:=OutputDllHandle;
  omod.init;
  omod.setvolume( 255 );

  imod.outMod:=omod;
end;

procedure TForm1.i1Click(Sender: TObject);
var
  ts: tsearchrec;
  i : integer;
begin
  i1.Picture.Bitmap.LoadFromFile( 'pics\bg1_zene.bmp' );
  i1.Refresh;
  delay( 500 );
  i1.Picture.Bitmap := nil;
  
  ls1.clear;
  ls2.clear;
  i := findfirst( musicpath + '\*.*', $3F, ts );
  while i <> 18 do begin
    if ( ts.name <> '.' ) and ( ts.name <> '..' ) then ls1.items.add( ts.Name );
    i := findnext( ts );
  end;

  i1.hide;  i2.hide;  i3.hide;  i4.show;  i8.show; i6.hide; i9.show;
  ls1.show;  ls2.show;  dn1.show;  up1.show;  dn2.show;  up2.show; i11.show;
  if fileexists( 'pics\bg2.bmp' ) then bg1.Picture.LoadFromFile( 'pics\bg2.bmp' );
end;

procedure TForm1.i2Click(Sender: TObject);
begin
  i2.Picture.LoadFromFile( 'pics\bg1_video.bmp' );
  i2.Refresh;
  delay( 500 );
  i2.Picture.Bitmap := nil;

  i1.hide;  i2.hide;  i3.hide;  i4.hide; i8.show;  ls3.show;  ls4.show;
  dn3.show;  up3.show;  dn4.show;  up4.show; i6.hide; i11.show;
  if fileexists( 'pics\bg2.bmp' ) then bg1.Picture.LoadFromFile( 'pics\bg2.bmp' );
end;

procedure TForm1.i3Click(Sender: TObject);
var

  i, j: integer;
  s, g: string;
begin
  i3.Picture.LoadFromFile( 'pics\bg1_top20.bmp' );
  i3.Refresh;
  delay( 500 );
  i3.Picture.Bitmap := nil;

  i1.hide;  i2.hide;  i3.hide; ls5.show; i6.hide;
  i10.show; i12.show;

  str.sort;

  ls5.clear;
  if str.count - 20 < 0 then j := 0 else j := str.count - 20;
  for i := j to str.count - 1 do begin
    s := str[ i ];
    delete( s, 1, length( musicpath ) + 6 );
    delete( s, pos( '.mp3', s ), 666 );
    s[ pos( '\', s ) ] := '-';
    ls5.Items.Insert( 0, s );
  end;

  if fileexists( 'pics\bg3.bmp' ) then bg1.Picture.LoadFromFile( 'pics\bg3.bmp' );
end;

procedure TForm1.i6Click(Sender: TObject);
begin
  i6.Picture.LoadFromFile( 'pics\bg1_over.bmp' );
  i6.Refresh;
  delay( 500 );
  i6.Picture.Bitmap := nil;

  f3.i1.Picture.LoadFromFile( 'pics\bg_sort.bmp' );
  f3.show;
//
end;

procedure TForm1.ls1Click(Sender: TObject);
var

  ts: tsearchrec;
  i : integer;

begin
  i := findfirst( musicpath + '\' + ls1.items[ls1.itemindex] + '\*.mp3', $3F, ts );
  ls2.clear;
  while i <> 18 do begin
    if ( ts.name <> '.' ) and ( ts.name <> '..' ) then
      begin
        ls2.items.add( copy( ts.Name, 1, pos ( '.MP3', uppercase( ts.name ) ) - 1 ) );
        if fileexists( musicpath + '\' + ls1.items[ls1.itemindex] + '\eloado.bmp' )
        then i4.Picture.LoadFromFile( musicpath + '\' + ls1.items[ls1.itemindex] + '\eloado.bmp' )
        else i4.Picture := nil;
      end;
    i := findnext( ts );
  end;
end;

function  padding( value: integer ): string;
  var

    i: integer;
  begin
    result := inttostr( value );
    for i := 1 to 5 - length( result ) do result := '0' + result;
  end;

procedure TForm1.queue( s: string );
var

  f: textfile;
  i: integer;
  match: boolean;

begin
  if strtoint( l1. caption ) = 0 then begin
    f3.i1.Picture.LoadFromFile( 'pics\bg_nem.bmp' );
    f3.show;
    exit;
  end;

  match := false;
  for i := 0 to str.Count - 1 do
    if copy( str.Strings[ i ], 6, 255 ) = s then begin
      match := true;
      str.Strings[ i ] := padding( strtoint( copy( str.Strings[ i ], 1, 5 ) ) + 1 ) + s;
      str.sort;
    end;
  if not match then str.Add( '00001' + s );
  str.SaveToFile( wd + '\top.txt' );

  m1.lines.add( s );
  m1.lines.SaveToFile( 'list.txt' );
  l1.caption := inttostr( strtoint( l1.caption ) - 50 );
  assignfile( f, 'money' ); rewrite( f ); writeln( f, l1.caption ); closefile( f );
  if l1.caption = '0' then i8click( nil );
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  form2.showmodal;
  if form2.edit1.text <> '123456' then action := caNone
  else begin
    savetolog( 'log.txt', datetimetostr( now ) + ':: closing modules' );
    str.SaveToFile( wd + '\top.txt' );
    str.Free;
    imod.Stop;
    CloseOutputDLL;
    CloseInputDLL;
    savetolog( 'log.txt', datetimetostr( now ) + ':: exit.' );
  end;
  form2.edit1.text := '';
end;

procedure TForm1.Label1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var

  f: textfile;

begin
  if button = mbRight then l1.caption := inttostr( strtoint( l1.caption ) + 100 );
  assignfile( f, 'money' ); rewrite( f ); writeln( f, l1.caption ); closefile( f );
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var s, p: string;
begin
  if f3.visible then
  if counter mod 5 = 0 then begin f3.close; inc( counter ); end else inc( counter );

  if omod.IsPlaying <> 0 then begin
    idlecounter := 0;
  end
  else begin
    if idlecounter = 0 then savetolog( 'log.txt', datetimetostr( now ) + ':: stopped  ' + s );
    imod.Stop;
    s := m1.lines.strings[0];
    imod.play( pchar( s ) );
    p := extractfilepath( s );
    if s <> '' then savetolog( 'log.txt', datetimetostr( now ) + ':: started:  ' + s );
    ltitle.caption := extractfilename( copy( p, 1, length( p ) - 1 ) ) + ' - ' + extractfilename( copy( s, 1, pos( '.mp3', s ) - 1 ) );
    m1.lines.delete(0);
    m1.lines.SaveToFile( 'list.txt' );
    inc( idlecounter );
    if idlecounter = 1200 then begin playrandom; idlecounter := 0; end;
  end;
end;

procedure TForm1.playrandom;
var

  rnd: string;
  i, j, r: integer;
  ts: tsearchrec;

begin
  randomize;

  l1.caption := inttostr( strtoint( l1.caption ) + 50 );
  rnd := musicpath + '\' + ls1.items[ random( ls1.items.count ) ] + '\';
  j := 1;

  i := findfirst( rnd + '*.mp3', $3F, ts );
  while i <> 18 do
    begin
      if ( ts.name <> '.' ) and ( ts.name <> '..' ) then inc( j );
      i := findnext( ts );
    end;
  findclose( ts );
  r := random( j ) + 1;
  j := 1;
  while j <> r do
    begin
      if ( ts.name <> '.' ) and ( ts.name <> '..' ) then
      inc( j );
      findnext( ts );
    end;

  rnd := rnd + ts.name;

  queue( rnd );
end;

procedure TForm1.up2Click(Sender: TObject);
begin
  noclick := true;
  sendmessage( ls2.Handle, WM_KEYDOWN, VK_PRIOR, 0 );
end;

procedure TForm1.dn2Click(Sender: TObject);
begin
  noclick := true;
  sendmessage( ls2.Handle, WM_KEYDOWN, VK_NEXT, 0 );
end;

procedure TForm1.up4Click(Sender: TObject);
begin
  noclick := true;
  sendmessage( ls4.Handle, WM_KEYDOWN, VK_PRIOR, 0 );
end;

procedure TForm1.dn4Click(Sender: TObject);
begin
  noclick := true;
  sendmessage( ls4.Handle, WM_KEYDOWN, VK_NEXT, 0 );
end;

procedure TForm1.dn5Click(Sender: TObject);
begin
  noclick := true;
  sendmessage( ls5.Handle, WM_KEYDOWN, VK_NEXT, 0 );
end;

procedure TForm1.up5Click(Sender: TObject);
begin
  noclick := true;
  sendmessage( ls5.Handle, WM_KEYDOWN, VK_PRIOR, 0 );
end;

procedure TForm1.up3Click(Sender: TObject);
begin
  noclick := true;
  sendmessage( ls3.Handle, WM_KEYDOWN, VK_PRIOR, 0 );
end;

procedure TForm1.dn3Click(Sender: TObject);
begin
  noclick := true;
  sendmessage( ls3.Handle, WM_KEYDOWN, VK_NEXT, 0 );
end;

procedure TForm1.dn1Click(Sender: TObject);
begin
  noclick := true;
  sendmessage( ls1.Handle, WM_KEYDOWN, VK_NEXT, 0 );
end;

procedure TForm1.up1Click(Sender: TObject);
begin
  noclick := true;
  sendmessage( ls1.Handle, WM_KEYDOWN, VK_PRIOR, 0 );
end;

procedure TForm1.i8Click(Sender: TObject);
begin
  ls1.hide;  ls2.hide;  ls3.hide;  ls4.hide;  ls5.hide;  i4.hide; i8.hide;
  i1.show;  i2.show;  i3.show;  dn1.hide;  up1.hide;  dn2.hide;  up2.hide;
  dn3.hide;  up3.hide;  dn4.hide;  up4.hide;  
  i6.show; i9.hide; i10.hide; i11.hide; i12.hide;
  if fileexists( 'pics\bg1.bmp' ) then bg1.Picture.LoadFromFile( 'pics\bg1.bmp' );
end;

procedure TForm1.i9Click(Sender: TObject);
begin
//  if noclick then begin noclick := not noclick; exit; end;
  if ls2.itemindex = -1 then exit;

  f3.i1.Picture.LoadFromFile( 'pics\bg_select.bmp' );
  f3.show;

  queue( musicpath + '\' + ls1.items[ ls1.itemindex ] + '\' + ls2.items[ ls2.itemindex ] + '.mp3' );
end;

procedure TForm1.i10Click(Sender: TObject);
begin
  i8Click(Sender);
end;

procedure TForm1.i11Click(Sender: TObject);
begin
  i11.Picture.LoadFromFile( 'pics\bg2_over.bmp' );
  i11.Refresh;
  delay( 500 );
  i11.Picture.Bitmap := nil;

  f3.i1.Picture.LoadFromFile( 'pics\bg_sort.bmp' );
  f3.show;
end;

procedure TForm1.i12Click(Sender: TObject);
begin
  i12.Picture.LoadFromFile( 'pics\bg3_over.bmp' );
  i12.Refresh;
  delay( 500 );
  i12.Picture.Bitmap := nil;

  f3.i1.Picture.LoadFromFile( 'pics\bg_sort.bmp' );
  f3.show;
end;

procedure TForm1.ls5Click(Sender: TObject);
begin
  //
end;

procedure TForm1.i13Click(Sender: TObject);
var

  i, j: integer;
  s: string;
begin
  //
  if ls5.itemindex >= 0 then
    queue( copy( str[ str.count - ls5.itemindex - 1 ], 6, 255 ) );

  str.sort;

  ls5.clear;
  if str.count - 20 < 0 then j := 0 else j := str.count - 20;
  for i := j to str.count - 1 do begin
    s := str[ i ];
    delete( s, 1, length( musicpath ) + 6 );
    delete( s, pos( '.mp3', s ), 666 );
    s[ pos( '\', s ) ] := '-';
    ls5.Items.Insert( 0, s );
  end;

end;

end.
