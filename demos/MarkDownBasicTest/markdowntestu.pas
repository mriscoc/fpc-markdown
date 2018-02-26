unit MarkDownTestU;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  MarkdownUtils,
  MarkdownProcessor;

type

  { TMainForm }

  TMainForm = class(TForm)
    B_Convert: TButton;
    Memo1: TMemo;
    procedure B_ConvertClick(Sender: TObject);
  private

  public

  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.B_ConvertClick(Sender: TObject);
var
  md:TMarkdownProcessor;
begin
  md := TMarkdownProcessor.createDialect(mdDaringFireball);
  md.UnSafe := true;
  Memo1.Text:=md.process(Memo1.Text);
  md.free;
end;

end.

