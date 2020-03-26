unit MainFormU;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, PairSplitter, MarkdownProcessor, MarkdownUtils;

type

  { TMainForm }

  TMainForm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    PairSplitter1: TPairSplitter;
    PairSplitterSide1: TPairSplitterSide;
    PairSplitterSide2: TPairSplitterSide;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
  private

  public

  end;

var
  MainForm: TMainForm;
  md : TMarkdownProcessor;

implementation

{ TMainForm }

procedure TMainForm.Memo1Change(Sender: TObject);
begin
  Memo2.text := md.process(Memo1.Text);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  md := TMarkdownProcessor.createDialect(mdCommonMark);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  md.free
end;

initialization
  {$I *.lrs}

end.

