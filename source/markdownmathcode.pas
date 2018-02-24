unit MarkdownMathCode;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, MarkdownUtils;

function checkMathCode(out_: TStringBuilder; s: String; start: integer): integer;

implementation

function checkMathCode(out_: TStringBuilder; s: String; start: integer
  ): integer;
var
  temp: TStringBuilder;
  position: integer;
  code: String;
begin
  temp := TStringBuilder.Create();
  try
    // Check for mathcode {a^2+b^2=c^2} and generate link
    temp.Clear;
    position := TUtils.readUntil(temp, s, start + 1, [' ', '$', #10]);
    if (position <> -1) and (s[1 + position] = '$') and
       (s[position] <> '\') then
    begin
      code:= temp.ToString();
      out_.append('<img src="https://chart.googleapis.com/chart?cht=tx&chl=');
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

