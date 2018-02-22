unit MarkDownHtmlU;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LazFileUtils, SynEdit, SynHighlighterHTML, Forms, Controls,
  Graphics, Dialogs, StdCtrls, ExtCtrls, Clipbrd, MarkdownProcessor, MarkdownUtils,
  LCLIntf, ComCtrls, Buttons, StrUtils, HtmlView, HtmlGlobals, HTMLUn2;

type

  { TMainForm }

  TMainForm = class(TForm)
    B_Save: TBitBtn;
    B_Copy: TButton;
    B_Paste: TButton;
    B_ViewBrowser: TButton;
    B_OpenFile: TButton;
    B_Convert: TButton;
    HtmlViewer: THtmlViewer;
    OpenDialog1: TOpenDialog;
    PageControl1: TPageControl;
    Panel1: TPanel;
    SaveDialog1: TSaveDialog;
    SE_MarkDown: TSynEdit;
    SE_HTML: TSynEdit;
    Splitter1: TSplitter;
    SynHTMLSyn1: TSynHTMLSyn;
    TS_MarkDown: TTabSheet;
    TS_HTML: TTabSheet;
    procedure B_CopyClick(Sender: TObject);
    procedure B_PasteClick(Sender: TObject);
    procedure B_ViewBrowserClick(Sender: TObject);
    procedure B_OpenFileClick(Sender: TObject);
    procedure B_ConvertClick(Sender: TObject);
    procedure B_SaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure HtmlViewerHotSpotClick(Sender: TObject; const SRC: ThtString;
      var Handled: Boolean);
    procedure HtmlViewerHotSpotTargetClick(Sender: TObject; const Target,
      URL: ThtString; var Handled: boolean);
    procedure HtmlViewerImageRequest(Sender: TObject; const SRC: ThtString;
      var Stream: TStream);
    procedure SE_HTMLChange(Sender: TObject);
  private
    procedure OpenInBrowser;
    procedure SetPreview;

  public

  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

var
  RootPath,f:string;
  md:TMarkdownProcessor=nil;
  MStream: TMemoryStream = nil;

const
  CSSDecoration = '<style type="text/css">'+
                  'code{'+
                  '  color: #A00;'+
                  '}'+
                  'pre{'+
                  '  background: #f4f4f4;'+
                  '  border: 1px solid #ddd;'+
                  '  border-left: 3px solid #f36d33;'+
                  '  color: #555;'+
                  '  overflow: auto;'+
                  '  padding: 1em 1.5em;'+
                  '  display: block;'+
                  '}'+
                  'pre code{'+
                  '  color: inherit;'+
                  '}'+
                  '</style>';


(*
More decoration:

<style type="text/css">
pre {
  background-color: #eee;
  border: 1px solid #999;
  display: block;
  padding: 10px;
}

Blockquote{
  border-left: 3px solid #d0d0d0;
  padding-left: 0.5em;
  margin-left:1em;
}
Blockquote p{
  margin: 0;
}
</style>
*)


{ TMainForm }

procedure TMainForm.SetPreview;
begin
  if SE_HTML.Modified then
  begin
    HtmlViewer.LoadFromString(CSSDecoration+SE_HTML.Text);
    SE_HTML.Modified:=false;
  end;
end;

procedure TMainForm.B_ConvertClick(Sender: TObject);
begin
  SE_HTML.Text:=md.process(SE_MarkDown.Text);
  SE_HTML.Modified:=true;
  SetPreview;
end;

procedure TMainForm.B_SaveClick(Sender: TObject);
begin
  PageControl1.ActivePageIndex:=0;
  if savedialog1.Execute then
  begin
    SE_MarkDown.Lines.SaveToFile(savedialog1.FileName);
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  i:integer;
begin
  md := TMarkdownProcessor.createDialect(mdCommonMark);
  md.UnSafe := false;
  RootPath:=GetTempDir;
  I:=0;
  Repeat
    f:=Format('%s%.3d.html',['markdown',I]);
    Inc(I);
  Until not FileExists(RootPath+f);
  PageControl1.ActivePageIndex:=0;
  HtmlViewer.DefBackground:=clWhite;
  HtmlViewer.DefFontColor:=clBlack;
  HtmlViewer.DefFontName:='Helvetica';
  HtmlViewer.DefFontSize:=10;
//  HtmlViewer.DefPreFontName:='Lucida Console';
  HtmlViewer.DefPreFontName:='Courier';
  HtmlViewer.ServerRoot:=RootPath;
//  HtmlViewer.OnHotSpotTargetClick:=@HtmlViewerHotSpotTargetClick;
  HtmlViewer.OnHotSpotClick:=@HtmlViewerHotSpotClick;
  HtmlViewer.OnImageRequest:=@HtmlViewerImageRequest;
  MStream := TMemoryStream.Create;
  B_ConvertClick(Self);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  if FileExists(RootPath+f) then DeleteFile(RootPath+f);
  if Assigned(MStream) then freeandnil(MStream);
  if assigned(md) then md.Free;
end;

procedure TMainForm.HtmlViewerHotSpotClick(Sender: TObject;
  const SRC: ThtString; var Handled: Boolean);
begin
  Handled:=OpenUrl(SRC);
end;

procedure TMainForm.HtmlViewerHotSpotTargetClick(Sender: TObject;
  const Target, URL: ThtString; var Handled: boolean);
begin
  Handled:=OpenUrl(URL);
end;

procedure TMainForm.HtmlViewerImageRequest(Sender: TObject;
  const SRC: ThtString; var Stream: TStream);

var
  Filename: string;
begin
  Stream:=nil;
  FileName:=IfThen(FileExists(SRC),SRC,RootPath+SRC);
  if FileExists(FileName) then
  begin
    MStream.LoadFromFile(FileName);
    Stream := MStream;
  end;
end;

procedure TMainForm.SE_HTMLChange(Sender: TObject);
begin
  SetPreview;
end;

procedure TMainForm.B_CopyClick(Sender: TObject);
begin
  Clipboard.AsText:=SE_MarkDown.text;
end;

procedure TMainForm.B_PasteClick(Sender: TObject);
begin
  SE_MarkDown.Clear;
  SE_MarkDown.PasteFromClipboard;
  PageControl1.ActivePageIndex:=0;
end;

procedure TMainForm.B_ViewBrowserClick(Sender: TObject);
begin
  OpenInBrowser;
end;

procedure TMainForm.B_OpenFileClick(Sender: TObject);
var NewPath:string;
begin
  if OpenDialog1.Execute then
  begin
    SE_MarkDown.Lines.LoadFromFile(OpenDialog1.FileName);
    NewPath:=ExtractFilePath(OpenDialog1.FileName);
    if NewPath<>RootPath then
    begin
      SE_HTML.Clear;
      HtmlViewer.Clear;
      if FileExists(RootPath+f) then DeleteFile(RootPath+f);
      HtmlViewer.ServerRoot:=NewPath;
      RootPath:=NewPath;
    end;
    SaveDialog1.FileName:=OpenDialog1.FileName;
    PageControl1.ActivePageIndex:=0;
  end;
end;

procedure TMainForm.OpenInBrowser;
var p:string;
begin
  p:=IfThen(DirectoryIsWritable(RootPath),RootPath+f,GetTempDir+f);
  try
    SE_HTML.Lines.SaveToFile(p);
    OpenURL('file://'+p);
  except
    ShowMessage('Can not create and open the temp file');
  end;
end;

end.

