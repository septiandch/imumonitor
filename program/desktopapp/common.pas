unit common;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

function Split(Expression:string; Delimiter:string): TStringArray;

implementation

function Split(Expression:string; Delimiter:string): TStringArray;
var
  Res:        TStringArray;
  ResCount:   DWORD;
  dLength:    DWORD;
  StartIndex: DWORD;
  sTemp:      string;
begin
  Res := TStringArray.create;

  dLength := Length(Expression);
  StartIndex := 1;
  ResCount := 0;
  repeat
    sTemp := Copy(Expression, StartIndex, Pos(Delimiter, Copy(Expression, StartIndex, Length(Expression))) - 1);
    SetLength(Res, Length(Res) + 1);
    SetLength(Res[ResCount], Length(sTemp));
    Res[ResCount] := sTemp;
    StartIndex := StartIndex + Length(sTemp) + Length(Delimiter);
    ResCount := ResCount + 1;
  until StartIndex > dLength;
  Result := Res;
end;

end.

