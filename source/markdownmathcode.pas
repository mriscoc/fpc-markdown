unit MarkdownMathCode;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, MarkdownUtils;

function checkMathCode(out_: TStringBuilder; s: String; start: integer): integer;

implementation

const
  equationapi = '<img src="https://latex.codecogs.com/png.image?\dpi{110}';
  //equationapi = '<img src="https://chart.googleapis.com/chart?cht=tx&chl='; // deprecated

 function checkMathCode(out_: TStringBuilder; s: String; start: integer): integer;
var
  temp: TStringBuilder;
  position: integer;
  code: String;
begin
  temp := TStringBuilder.Create();
  try
    // Check for enclosed mathcode ${a^2+b^2=c^2}$ and generate link
    temp.Clear;
    position := TUtils.readRawUntil(temp, s, start + 1, ['$', #10]);
    if     (position <> -1)         // end was found
       and (s[1 + position] = '$')  // closing $ was found
       and (s[position] <> '\')     // is not a \$
       and (s[position] <> ' ')     // is not an space before $
       and not CharInSet(s[1 + position], ['0'..'9'])  // no digit after the closing $
    then
    begin
      code:= temp.ToString();
      out_.append(equationapi);
      TUtils.codeEncode(out_, code, 0);
      out_.append('" alt="');
      TUtils.appendValue(out_, code, 0, Length(code));
      out_.append(' "/>');
      exit(position);
    end;
    result := -1;
  finally
    temp.Free;
  end;
end;

end.

