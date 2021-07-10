unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, FPCanvas, Dialogs, ComCtrls,
  StdCtrls, ExtCtrls, EditBtn, TAGraph, TASeries, TARadialSeries, IniFiles,
  fpjson, jsonparser, fphttpclient, strutils, dateutils;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Chart_Sensors: TChart;
    Chart_Owas: TChart;
    Edit1: TEdit;
    Edit_Nama: TEdit;
    Edit_Kegiatan: TEdit;
    Edit_Usia: TEdit;
    Edit_Tinggi: TEdit;
    Edit_Berat: TEdit;
    Label15: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    LineSeries_Owas: TLineSeries;
    LineSeries_Roll6: TLineSeries;
    LineSeries_Roll2: TLineSeries;
    LineSeries_Roll5: TLineSeries;
    LineSeries_Pitch5: TLineSeries;
    LineSeries_Yaw5: TLineSeries;
    LineSeries_Pitch6: TLineSeries;
    LineSeries_Yaw6: TLineSeries;
    LineSeries_Roll7: TLineSeries;
    LineSeries_Pitch7: TLineSeries;
    LineSeries_Yaw7: TLineSeries;
    LineSeries_Pitch2: TLineSeries;
    LineSeries_Yaw2: TLineSeries;
    LineSeries_Roll3: TLineSeries;
    LineSeries_Pitch3: TLineSeries;
    LineSeries_Yaw3: TLineSeries;
    LineSeries_Roll4: TLineSeries;
    LineSeries_Pitch4: TLineSeries;
    LineSeries_Yaw4: TLineSeries;
    FileNameEdit: TFileNameEdit;
    Label24: TLabel;
    LineSeries_Load: TLineSeries;
    LineSeries_Arms: TLineSeries;
    LineSeries_Back: TLineSeries;
    LineSeries_Yaw1: TLineSeries;
    LineSeries_Roll1: TLineSeries;
    LineSeries_Pitch1: TLineSeries;
    ComboBox_Sensor: TComboBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label25: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    LineSeries_Legs: TLineSeries;
    Memo1: TMemo;
    Memo2: TMemo;
    PageControl1: TPageControl;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    Shape5: TShape;
    Shape6: TShape;
    Shape7: TShape;
    Shape8: TShape;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    Timer: TTimer;
    TrackBar1: TTrackBar;
    TrackBar11: TTrackBar;
    TrackBar2: TTrackBar;
    TrackBar3: TTrackBar;
    TrackBar4: TTrackBar;
    TrackBar5: TTrackBar;
    TrackBar6: TTrackBar;
    TrackBar7: TTrackBar;
    TrackBar8: TTrackBar;
    TrackBar9: TTrackBar;
    TrackBar_BackBent: TTrackBar;
    TrackBar_BackTwist: TTrackBar;
    TrackBar_LegBent: TTrackBar;
    TrackBar_LegSit: TTrackBar;
    TrackBar_LegSquat: TTrackBar;
    TrackBar_LegStand: TTrackBar;
    TrackBar_Load2: TTrackBar;
    TrackBar_Load1: TTrackBar;
    TrackBar_MoveSens: TTrackBar;
    TrackBar_Shoulder: TTrackBar;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure ComboBox_SensorChange(Sender: TObject);
    procedure FileNameEditAcceptFileName(Sender: TObject; var Value: String);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
                                        
    procedure LoadCsv;
    procedure InitializeLineSeries;
    procedure SelectLineSeries(select:integer);
    function Split(Expression:string; Delimiter:string): TStringArray; 

    function OwasCalc(data : string): string;
    function OwasBack(bBackRoll:integer; bBackPitch:integer): integer;
    function OwasArms(bLeftArmRoll:integer; bLeftArmPitch:integer; bRightArmRoll:integer; bRightArmPitch:integer): integer;
    function OwasLegs(bRightUpperLeg:integer;
                      bRightLowerLeg:integer;
                      bLeftUpperLeg:integer;
                      bLeftLowerLeg:integer;
                      bRightMoveR:integer;
                      bRightMoveP:integer;
                      bLeftMoveR:integer;
                      bLeftMoveP:integer): integer;
    function OwasLoad(nUserLoad:integer): integer;
    function CompareInRange(range : integer; limit1 : integer; limit2 : integer) : boolean;
    procedure TimerTimer(Sender: TObject);
    Procedure UpdateChart(Data : string);
  private

  public

  end;

var
  Form1: TForm1;
  LineSeriesSensor_Count: integer;
  CsvFileName: string;
  CsvFileDir: string;
  bMonitoringState : boolean;  
  nTime : TDateTime;

const
  bOwasTable : array[0..11, 0..20] of byte =
    (
        (	1, 1, 1,	1, 1, 1,	1, 1, 1,	2, 2, 2,	2, 2, 2,	1, 1, 1,	1, 1, 1	),
        (	1, 1, 1,	1, 1, 1,	1, 1, 1,	2, 2, 2,	2, 2, 2,	1, 1, 1,	1, 1, 1	),
        (	1, 1, 1,	1, 1, 1,	1, 1, 1,	2, 2, 2,	2, 2, 2,	1, 1, 1,	1, 1, 1	),

        (	2, 2, 3,	2, 2, 3,	2, 2, 3,	3, 3, 3,	3, 3, 3,	2, 2, 2,	2, 3, 3	),
        (	2, 2, 3,	2, 2, 3,	2, 3, 3,	3, 4, 4,	3, 4, 4,	3, 3, 4,	2, 3, 4	),
        (	3, 3, 4,	2, 2, 3,	3, 3, 3,	3, 4, 4,	4, 4, 4,	4, 4, 4,	2, 3, 4	),

        (	1, 1, 1,	1, 1, 1,	1, 1, 2,	3, 3, 3,	4, 4, 4,	1, 1, 1,	1, 1, 1	),
        (	2, 2, 3,	1, 1, 1,	1, 1, 2, 	4, 4, 4,	4, 4, 4,	3, 3, 3,	1, 1, 1	),
        (	2, 2, 3,	1, 1, 1,	2, 3, 3,	4, 4, 4,	4, 4, 4,	4, 4, 4,	1, 1, 1	),

        (	2, 3, 3,	2, 2, 3,	2, 2, 3,	4, 4, 4,	4, 4, 4,	4, 4, 4,	2, 3, 4	),
        (	3, 3, 4,	2, 3, 4,	3, 3, 4,	4, 4, 4,	4, 4, 4,	4, 4, 4,	2, 3, 4	),
        (	4, 4, 4,	2, 3, 4,	3, 3, 4,	4, 4, 4,	4, 4, 4,	4, 4, 4,	2, 3, 4	)
    );


implementation

{$R *.lfm}

{ TForm1 }     

procedure TForm1.FormCreate(Sender: TObject);
var
  INI: TINIFile;
begin
  INI := TINIFile.Create('conf.ini');
  try
    TrackBar_Shoulder.Position  := INI.ReadInteger('Config' , 'Shoulder'  , 80  );
    TrackBar_BackBent.Position  := INI.ReadInteger('Config' , 'BackBent'  , 15  );
    TrackBar_BackTwist.Position := INI.ReadInteger('Config' , 'BackTwist' , 15  );
    TrackBar_LegStand.Position  := INI.ReadInteger('Config' , 'LegStand'  , 0   );
    TrackBar_LegBent.Position   := INI.ReadInteger('Config' , 'LegBent'   , 11  );
    TrackBar_LegSit.Position    := INI.ReadInteger('Config' , 'LegSit'    , 70  );
    TrackBar_LegSquat.Position  := INI.ReadInteger('Config' , 'LegSquat'  , 101 );
    TrackBar_Load1.Position     := INI.ReadInteger('Config' , 'Load1'     , 5   );
    TrackBar_Load2.Position     := INI.ReadInteger('Config' , 'Load2'     , 16  );
    TrackBar_MoveSens.Position  := INI.ReadInteger('Config' , 'MoveSens'  , 100 );
  finally
    INI.Free;
  end;

  PageControl1.ActivePage := TabSheet1;
  //TabSheet5.TabVisible := True;

  If Not DirectoryExists('csv') then CreateDir ('csv');

  InitializeLineSeries;
end;

procedure TForm1.FormDestroy(Sender: TObject);
var
  INI: TINIFile;
begin
  INI := TINIFile.Create('conf.ini');
  try
    INI.WriteInteger('Config' , 'Shoulder',  TrackBar_Shoulder.Position );
    INI.WriteInteger('Config' , 'BackBent',  TrackBar_BackBent.Position );
    INI.WriteInteger('Config' , 'BackTwist', TrackBar_BackTwist.Position);
    INI.WriteInteger('Config' , 'LegStand',  TrackBar_LegStand.Position );
    INI.WriteInteger('Config' , 'LegBent',   TrackBar_LegBent.Position  );
    INI.WriteInteger('Config' , 'LegSit',    TrackBar_LegSit.Position   );
    INI.WriteInteger('Config' , 'LegSquat',  TrackBar_LegSquat.Position );
    INI.WriteInteger('Config' , 'Load1',     TrackBar_Load1.Position    );
    INI.WriteInteger('Config' , 'Load2',     TrackBar_Load2.Position    );
    INI.WriteInteger('Config' , 'MoveSens',  TrackBar_MoveSens.Position );
  finally
    INI.free;
  end;
end;        

procedure TForm1.FileNameEditAcceptFileName(Sender: TObject; var Value: String);
var
  pos : integer;
begin
  pos := LastDelimiter('/', Value);
  Delete(Value, 1, pos);
  FileNameEdit.Text := Value;
  FileNameEdit.FileName:= Value;

  LoadCsv;
end;    

procedure TForm1.LoadCsv;
var
  csv: TextFile;
  str, currentdir: String;
  strlist: TStringArray;
  nheadercount, nhundredcount: integer;
begin
  currentdir := getCurrentDir;
  chdir(currentdir + '/csv');

  if FileExists(FileNameEdit.FileName) then
  begin
    InitializeLineSeries;

    strlist := TStringArray.create;
    nheadercount := 0;
    nhundredcount := 0;

    AssignFile(csv, FileNameEdit.FileName);
    Reset(csv);
    while not Eof(csv) do
    begin
      ReadLn(csv, str);

      if(nheadercount < 3) then
      begin
        nheadercount := nheadercount + 1;
        nhundredcount := 100;
      end
      else if nhundredcount = 100 then
      begin
        UpdateChart(str);
      end else
      begin
        nhundredcount := nhundredcount + 1;
      end;
    end;

    CloseFile(csv);
  end
  else
  begin
    ShowMessage('File is not exist');
  end;

  chdir(currentdir);
end;

procedure TForm1.Button6Click(Sender: TObject);
var
  today : TDateTime;
  filename, stemp : string;
  stringlist: TStringList;
  i : integer;
  valueowas,valueback,valuearms,valuelegs,valueload : integer;
  valuerow,valuepitch,valueyaw : array[1..7] of integer;
begin
  Today := Now;

  for i := 1 to 7 do
  begin
    valuerow[i] := Random(180);
    valuepitch[i] := Random(180);
    valueyaw[i] := Random(180);
  end;

  valueowas := Random(4);
  valueback := Random(4);
  valuearms := Random(3);
  valuelegs := Random(7);
  valueload := Random(3);

  LineSeries_Roll1.AddXY(LineSeriesSensor_Count, valuerow[1]);
  LineSeries_Pitch1.AddXY(LineSeriesSensor_Count, valuepitch[1]);
  LineSeries_Yaw1.AddXY(LineSeriesSensor_Count, valueyaw[1]);

  LineSeries_Roll2.AddXY(LineSeriesSensor_Count, valuerow[2]);
  LineSeries_Pitch2.AddXY(LineSeriesSensor_Count, valuepitch[2]);
  LineSeries_Yaw2.AddXY(LineSeriesSensor_Count, valueyaw[2]);

  LineSeries_Roll3.AddXY(LineSeriesSensor_Count, valuerow[3]);
  LineSeries_Pitch3.AddXY(LineSeriesSensor_Count, valuepitch[3]);
  LineSeries_Yaw3.AddXY(LineSeriesSensor_Count, valueyaw[3]);

  LineSeries_Roll4.AddXY(LineSeriesSensor_Count, valuerow[4]);
  LineSeries_Pitch4.AddXY(LineSeriesSensor_Count, valuepitch[4]);
  LineSeries_Yaw4.AddXY(LineSeriesSensor_Count, valueyaw[4]);

  LineSeries_Roll5.AddXY(LineSeriesSensor_Count, valuerow[5]);
  LineSeries_Pitch5.AddXY(LineSeriesSensor_Count, valuepitch[5]);
  LineSeries_Yaw5.AddXY(LineSeriesSensor_Count, valueyaw[5]);

  LineSeries_Roll6.AddXY(LineSeriesSensor_Count, valuerow[6]);
  LineSeries_Pitch6.AddXY(LineSeriesSensor_Count, valuepitch[6]);
  LineSeries_Yaw6.AddXY(LineSeriesSensor_Count, valueyaw[6]);

  LineSeries_Roll7.AddXY(LineSeriesSensor_Count, valuerow[7]);
  LineSeries_Pitch7.AddXY(LineSeriesSensor_Count, valuepitch[7]);
  LineSeries_Yaw7.AddXY(LineSeriesSensor_Count, valueyaw[7]);

  LineSeries_Owas.AddXY(LineSeriesSensor_Count, valueowas);
  LineSeries_Back.AddXY(LineSeriesSensor_Count, valueback);
  LineSeries_Arms.AddXY(LineSeriesSensor_Count, valuearms);
  LineSeries_Legs.AddXY(LineSeriesSensor_Count, valuelegs);
  LineSeries_Load.AddXY(LineSeriesSensor_Count, valueload);

  LineSeriesSensor_Count := LineSeriesSensor_Count + 1;

  filename := FormatDateTime('dd',Today) + '-' +
              FormatDateTime('mmmm',Today) + '-' +
              FormatDateTime('yyyy',Today) + '.csv';

  stringlist := TStringList.Create;

  stemp := '';
  for i := 1 to 7 do
  begin
    stemp := stemp + 'Roll_'+ inttostr(i)
                   + ',Pitch_' + inttostr(i)
                   + ',Yaw_' + inttostr(i)
                   + ',';
  end;

  if not FileExists(filename) then
  begin
     FileCreate(filename);
     stringlist.LoadFromFile(filename);  
     stringlist.Add('OWAS,Back,Arms,Legs,Load,' + stemp);
     stringlist.SaveToFile(filename);
  end;

  stemp := inttostr(valueowas)
           + ',' + inttostr(valueback)
           + ',' + inttostr(valuearms)
           + ',' + inttostr(valuelegs)
           + ',' + inttostr(valueload)
           + ',' ;

  for i := 1 to 7 do
  begin
    stemp := stemp + inttostr(valuerow[i])
                   + ',' + inttostr(valuepitch[i])
                   + ',' + inttostr(valueyaw[i])
                   + ',' ;
  end;

  stringlist.LoadFromFile(filename);
  stringlist.Add(stemp + ',endl');
  stringlist.SaveToFile(filename);
  stringlist.Free;
end;

procedure TForm1.Button3Click(Sender: TObject);
var                
  today : TDateTime;
  currentdir, stemp : string;
  stringlist: TStringList;
  i : integer;
begin
  today := Now;

  if bMonitoringState then
  begin
    Timer.Enabled := False;
    bMonitoringState := false;
    Button3.Caption := 'Start Monitoring';
    Button3.Font.Color := clDefault;
    Button3.Font.Bold := false;

    Edit_Nama.Text := '';
    Edit_Usia.Text := '';
    Edit_Tinggi.Text := '';
    Edit_Berat.Text := '';

    FileNameEdit.Enabled := True;
  end else
  begin
     if (Edit_Nama.Text <> '') and (Edit_Nama.Text <> '')
       and (Edit_Nama.Text <> '') and (Edit_Nama.Text <> '') then
       begin
       bMonitoringState := true;
       Button3.Caption := 'Stop Monitoring';
       Button3.Font.Color := clRed;
       Button3.Font.Bold := true;

       nTime := Now;

       FileNameEdit.Enabled := false;

       InitializeLineSeries;

       Timer.Enabled := True;

       currentdir := GetCurrentDir;
       CsvFileDir := currentdir + '/csv';
       chdir(csvFileDir);
       csvFileName := Label10.Caption + '_' + Edit_Nama.Text + '.csv';

       stringlist := TStringList.Create;

       stemp := '';
       for i := 1 to 7 do
       begin
         stemp := stemp + 'Roll_'+ inttostr(i)
                        + ',Pitch_' + inttostr(i)
                        + ',Yaw_' + inttostr(i)
                        + ',';
       end;

       if not FileExists(csvFileName) then
       begin
         FileCreate(csvFileName);
         stringlist.LoadFromFile(csvFileName);
         stringlist.Add('Nama,Usia,Tinggi,Berat,Kegiatan,Start,End');
         stringlist.Add(Edit_Nama.Text
                        + ',' + Edit_Usia.Text
                        + ',' + Edit_Tinggi.Text
                        + ',' + Edit_Berat.Text
                        + ',' + Edit_Kegiatan.Text
                        + ',' + FormatDateTime('hh',Today)
                        + ':' + FormatDateTime('nn',Today)
                        + ':' + FormatDateTime('ss',Today)
                        + ',' + '-' );
         stringlist.Add('Time,OWAS,Back,Arms,Legs,Load,' + stemp);
         stringlist.SaveToFile(csvFileName);
      end;

      chdir(currentdir);

    end else
    begin
      ShowMessage('Lengkapi data user terlebih dahulu...');
    end;
  end;
end;

procedure TForm1.Button7Click(Sender: TObject);
var
  nTime : TDateTime;
  sData : string;     
  currentdir : string;
  sTimeStamp : string;
  csvfile : text;
  sDataList : TStringList;
  Json : TJSONData;
  JarrayRoll : TJSonArray;
  JarrayPitch : TJSonArray;
  JarrayYaw : TJSonArray;
  index, deviceindex : integer;
  bretry, bcancel : boolean;
  nretrycount : integer;
  sMoveCountRoll : array[1..7] of string;
  sMoveCountPitch : array[1..7] of string;
begin
  sDataList := TStringList.Create;
  bretry := true;
  bcancel := true;
  nretrycount := 0;

  while bretry do
  begin
    for deviceindex := 1 to 7 do
    begin
      try
        sData := TFPCustomHTTPClient.SimpleGet('http://192.168.4.11' + inttostr(deviceindex));
      except
        on E: Exception do
        begin
          sData := 'ERROR'
        end;
      end;

      //Memo1.Text := sData;

      if AnsiContainsStr(sData, 'Not Ready') then
      begin
        //showmessage('Device' + inttostr(deviceindex) + ' is not ready !');
        bretry := false;
        break;
      end else if(sData = 'ERROR') then
      begin
        ShowMessage('Connection Error!'
                    + sLineBreak
                    + 'Please check if all devices turned on. Then restart the monitoring.');
        bretry := false;
        break;
      end else
      begin
        Json := GetJSON(sData);

        JarrayRoll := TJSONArray(Json.FindPath('roll'));
        JarrayPitch := TJSONArray(Json.FindPath('pitch'));
        JarrayYaw := TJSONArray(Json.FindPath('yaw'));

        for index := 0 to JarrayRoll.Count - 1 do
        begin
          if(deviceindex = 1) then sDataList.Add(JarrayRoll.Strings[index])
          else sDataList[index] := sDataList[index] + JarrayRoll.Strings[index];
          sDataList[index] := sDataList[index] + ',' + JarrayPitch.Strings[index];
          sDataList[index] := sDataList[index] + ',' + JarrayYaw.Strings[index] + ',';
        end;

        sMoveCountRoll[deviceindex]  := Json.FindPath('rmov').AsString;
        sMoveCountPitch[deviceindex] := Json.FindPath('pmov').AsString;
      end;

      if(deviceindex = 7) then
      begin
        bretry := false;
        bcancel := false;
      end;
    end;

    nretrycount := nretrycount + 1;
    if(nretrycount > 3) then
    begin
      ShowMessage('Connection Error!'
                  + sLineBreak
                  + 'Please check if all devices turned on. Then restart the monitoring.');
      bretry := false;

      break;
    end;
  end;

  if(bcancel = false) then
  begin
    currentdir := GetCurrentDir;
    chdir(csvFileDir);
    Assignfile(csvfile, csvFileName);
    Append(csvfile);

    //Memo2.Text := '';
    for index := 0 to sDataList.Count - 1 do
    begin
      sDataList[index] := OwasCalc(sDataList[index]
                                   + sMoveCountRoll[4]
                                   + ',' + sMoveCountPitch[4]
                                   + ',' + sMoveCountRoll[6]
                                   + ',' + sMoveCountPitch[6]);
      sTimeStamp := FormatDateTime('hh',nTime)
                    + ':' + FormatDateTime('nn',nTime)
                    + ':' + FormatDateTime('ss',nTime)
                    + ':' + IntToStr((index mod 100) + 1)
                    + ',' ;

      writeln(csvfile, sDataList[index]);
      //Memo2.Text := Memo2.Text + sDataList[index] + sLineBreak;

      if ((index + 1) mod 100) = 0 then
      begin
        UpdateChart(sDataList[index]);

        nTime := IncSecond(nTime, 1);
      end;

    end;

    closefile(csvfile);
    chdir(currentDir);
  end;
end;

Procedure TForm1.UpdateChart(data : string);
var
  strlist: TStringArray;
  bheader: Boolean;
begin
  strlist := TStringArray.create;
  bheader := false;

  strlist := split(data, ',');

  Label9.Caption := strlist[0];
  case strtoint(strlist[0]) of
    0:
      begin
        Label8.Font.Color := clDefault;
        Label9.Font.Color := clDefault;
      end;
    1:
      begin
        Label8.Font.Color := clGreen;
        Label9.Font.Color := clGreen;
      end;
    2:
      begin
        Label8.Font.Color := clBlue;
        Label9.Font.Color := clBlue;
      end;
    3:
      begin
        Label8.Font.Color := TColor($001F65FF);
        Label9.Font.Color := TColor($001F65FF);
      end;
    4:
      begin
        Label8.Font.Color := clRed;
        Label9.Font.Color := clRed;
      end;
  end;

  LineSeries_Owas.AddXY(LineSeriesSensor_Count,   strtoint(strlist[0]));
  LineSeries_Back.AddXY(LineSeriesSensor_Count,   strtoint(strlist[1]));
  LineSeries_Arms.AddXY(LineSeriesSensor_Count,   strtoint(strlist[2]));
  LineSeries_Legs.AddXY(LineSeriesSensor_Count,   strtoint(strlist[3]));
  LineSeries_Load.AddXY(LineSeriesSensor_Count,   strtoint(strlist[4]));

  LineSeries_Roll1.AddXY(LineSeriesSensor_Count,  strtoint(strlist[5]));
  LineSeries_Pitch1.AddXY(LineSeriesSensor_Count, strtoint(strlist[6]));
  LineSeries_Yaw1.AddXY(LineSeriesSensor_Count,   strtoint(strlist[7]));

  LineSeries_Roll2.AddXY(LineSeriesSensor_Count,  strtoint(strlist[8]));
  LineSeries_Pitch2.AddXY(LineSeriesSensor_Count, strtoint(strlist[9]));
  LineSeries_Yaw2.AddXY(LineSeriesSensor_Count,   strtoint(strlist[10]));

  LineSeries_Roll3.AddXY(LineSeriesSensor_Count,  strtoint(strlist[11]));
  LineSeries_Pitch3.AddXY(LineSeriesSensor_Count, strtoint(strlist[12]));
  LineSeries_Yaw3.AddXY(LineSeriesSensor_Count,   strtoint(strlist[13]));

  LineSeries_Roll4.AddXY(LineSeriesSensor_Count,  strtoint(strlist[14]));
  LineSeries_Pitch4.AddXY(LineSeriesSensor_Count, strtoint(strlist[15]));
  LineSeries_Yaw4.AddXY(LineSeriesSensor_Count,   strtoint(strlist[16]));

  LineSeries_Roll5.AddXY(LineSeriesSensor_Count,  strtoint(strlist[17]));
  LineSeries_Pitch5.AddXY(LineSeriesSensor_Count, strtoint(strlist[18]));
  LineSeries_Yaw5.AddXY(LineSeriesSensor_Count,   strtoint(strlist[19]));

  LineSeries_Roll6.AddXY(LineSeriesSensor_Count,  strtoint(strlist[20]));
  LineSeries_Pitch6.AddXY(LineSeriesSensor_Count, strtoint(strlist[21]));
  LineSeries_Yaw6.AddXY(LineSeriesSensor_Count,   strtoint(strlist[22]));

  LineSeries_Roll7.AddXY(LineSeriesSensor_Count,  strtoint(strlist[23]));
  LineSeries_Pitch7.AddXY(LineSeriesSensor_Count, strtoint(strlist[24]));
  LineSeries_Yaw7.AddXY(LineSeriesSensor_Count,   strtoint(strlist[25]));

  LineSeriesSensor_Count := LineSeriesSensor_Count + 1;
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
  Edit_Nama.Text := 'Budi';   
  Edit_Usia.Text := '27';
  Edit_Tinggi.Text := '170';
  Edit_Berat.Text := '15';
end;

procedure TForm1.Button9Click(Sender: TObject);
begin
  UpdateChart(edit1.text);
end;

procedure TForm1.ComboBox_SensorChange(Sender: TObject);
begin
  SelectLineSeries(ComboBox_Sensor.ItemIndex);
end;

function TForm1.Split(Expression:string; Delimiter:string): TStringArray;
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

procedure TForm1.SelectLineSeries(select : integer);
var
  i : integer;
  pstyles : array[0..6] of TFPPenStyle;
begin
  for i := 0 to 6 do
  begin
    if(i = select) then pstyles[i] := psSolid
    else pstyles[i] := psClear;
  end;

  LineSeries_Roll1.LinePen.Style  := pstyles[0];
  LineSeries_Pitch1.LinePen.Style := pstyles[0];
  LineSeries_Yaw1.LinePen.Style   := pstyles[0];

  LineSeries_Roll2.LinePen.Style  := pstyles[1];
  LineSeries_Pitch2.LinePen.Style := pstyles[1];
  LineSeries_Yaw2.LinePen.Style   := pstyles[1];

  LineSeries_Roll3.LinePen.Style  := pstyles[2];
  LineSeries_Pitch3.LinePen.Style := pstyles[2];
  LineSeries_Yaw3.LinePen.Style   := pstyles[2];

  LineSeries_Roll4.LinePen.Style  := pstyles[3];
  LineSeries_Pitch4.LinePen.Style := pstyles[3];
  LineSeries_Yaw4.LinePen.Style   := pstyles[3];

  LineSeries_Roll5.LinePen.Style  := pstyles[4];
  LineSeries_Pitch5.LinePen.Style := pstyles[4];
  LineSeries_Yaw5.LinePen.Style   := pstyles[4];

  LineSeries_Roll6.LinePen.Style  := pstyles[5];
  LineSeries_Pitch6.LinePen.Style := pstyles[5];
  LineSeries_Yaw6.LinePen.Style   := pstyles[5];

  LineSeries_Roll7.LinePen.Style  := pstyles[6];
  LineSeries_Pitch7.LinePen.Style := pstyles[6];
  LineSeries_Yaw7.LinePen.Style   := pstyles[6];
end;  

procedure TForm1.InitializeLineSeries;
begin
  SelectLineSeries(0);

  LineSeriesSensor_Count := 0;

  LineSeries_Roll1.clear;
  LineSeries_Roll2.clear;
  LineSeries_Roll3.clear;
  LineSeries_Roll4.clear;
  LineSeries_Roll5.clear;
  LineSeries_Roll6.clear;
  LineSeries_Roll7.clear;

  LineSeries_Pitch1.clear;
  LineSeries_Pitch2.clear;
  LineSeries_Pitch3.clear;
  LineSeries_Pitch4.clear;
  LineSeries_Pitch5.clear;
  LineSeries_Pitch6.clear;
  LineSeries_Pitch7.clear;

  LineSeries_Yaw1.clear;
  LineSeries_Yaw2.clear;
  LineSeries_Yaw3.clear;
  LineSeries_Yaw4.clear;
  LineSeries_Yaw5.clear;
  LineSeries_Yaw6.clear;
  LineSeries_Yaw7.clear;

  LineSeries_Roll1.LinePen.Color  := clBlue;
  LineSeries_Roll2.LinePen.Color  := clBlue;
  LineSeries_Roll3.LinePen.Color  := clBlue;
  LineSeries_Roll4.LinePen.Color  := clBlue;
  LineSeries_Roll5.LinePen.Color  := clBlue;
  LineSeries_Roll6.LinePen.Color  := clBlue;
  LineSeries_Roll7.LinePen.Color  := clBlue;

  LineSeries_Pitch1.LinePen.Color  := clYellow;
  LineSeries_Pitch2.LinePen.Color  := clYellow;
  LineSeries_Pitch3.LinePen.Color  := clYellow;
  LineSeries_Pitch4.LinePen.Color  := clYellow;
  LineSeries_Pitch5.LinePen.Color  := clYellow;
  LineSeries_Pitch6.LinePen.Color  := clYellow;
  LineSeries_Pitch7.LinePen.Color  := clYellow;

  LineSeries_Yaw1.LinePen.Color  := clRed;
  LineSeries_Yaw2.LinePen.Color  := clRed;
  LineSeries_Yaw3.LinePen.Color  := clRed;
  LineSeries_Yaw4.LinePen.Color  := clRed;
  LineSeries_Yaw5.LinePen.Color  := clRed;
  LineSeries_Yaw6.LinePen.Color  := clRed;
  LineSeries_Yaw7.LinePen.Color  := clRed;

  LineSeries_Roll1.LinePen.Width  := 3;
  LineSeries_Roll2.LinePen.Width  := 3;
  LineSeries_Roll3.LinePen.Width  := 3;
  LineSeries_Roll4.LinePen.Width  := 3;
  LineSeries_Roll5.LinePen.Width  := 3;
  LineSeries_Roll6.LinePen.Width  := 3;
  LineSeries_Roll7.LinePen.Width  := 3;

  LineSeries_Pitch1.LinePen.Width  := 3;
  LineSeries_Pitch2.LinePen.Width  := 3;
  LineSeries_Pitch3.LinePen.Width  := 3;
  LineSeries_Pitch4.LinePen.Width  := 3;
  LineSeries_Pitch5.LinePen.Width  := 3;
  LineSeries_Pitch6.LinePen.Width  := 3;
  LineSeries_Pitch7.LinePen.Width  := 3;

  LineSeries_Yaw1.LinePen.Width  := 3;
  LineSeries_Yaw2.LinePen.Width  := 3;
  LineSeries_Yaw3.LinePen.Width  := 3;
  LineSeries_Yaw4.LinePen.Width  := 3;
  LineSeries_Yaw5.LinePen.Width  := 3;
  LineSeries_Yaw6.LinePen.Width  := 3;
  LineSeries_Yaw7.LinePen.Width  := 3;
end;

function TForm1.OwasCalc(data : string): string;
var
  sOwasResult : string;
  datalist   : TStringArray;
  bOwasLegs  : integer;
  bOwasLoad  : integer;
  bOwasBack  : integer;
  bOwasArms  : integer;
  bColumn    : integer;
  bRow       : integer;
  bOwasValue : integer;
  index      : integer;     
  valuelist  : array[0..24] of integer;
begin
  data := data + ',endl';
  datalist := TStringArray.create;

  datalist := split(data, ',');

  for index := 0 to 24 do
  begin
    valuelist[index] := strtoint(datalist[index]);
  end;

  bOwasLegs  := OwasLegs(valuelist[9], valuelist[12], valuelist[15], valuelist[18],
                         valuelist[21], valuelist[22], valuelist[23], valuelist[24]);
  bOwasLoad  := OwasLoad(strtoint(Edit_Berat.Text));
  bOwasBack  := OwasBack(valuelist[0], valuelist[1]);
  bOwasArms  := OwasArms(valuelist[6], valuelist[7], valuelist[3], valuelist[4]);

  bColumn    := ((bOwasLegs - 1) * 3) + bOwasLoad;
  bRow	     := ((bOwasBack - 1) * 3) + bOwasArms;
  bOwasValue := bOwasTable[bRow - 1][bColumn - 1];

  sOwasResult :=  IntToStr(bOwasValue)
                  + ',' + IntToStr(bOwasBack)
                  + ',' + IntToStr(bOwasArms)
                  + ',' + IntToStr(bOwasLegs)
                  + ',' + IntToStr(bOwasLoad);

  for index := 0 to 20 do
  begin
    sOwasResult := sOwasResult + ',' + datalist[index];
  end;

  result := sOwasResult + ',endl';
end;         

function TForm1.OwasBack(bBackRoll:integer; bBackPitch:integer): integer;
var
  bretval : integer;
begin
  bRetVal := 1;

  bBackRoll := abs(bBackRoll);
  bBackPitch := abs(bBackPitch);

  if (bBackRoll > TrackBar_BackBent.Position) then
  begin
    bRetVal := 2;
  end;

  if (bBackPitch > TrackBar_BackTwist.Position) then
  begin
    bRetVal := 3;
  end;

  if ((bBackRoll > TrackBar_BackBent.Position)
     and (bBackPitch > TrackBar_BackTwist.Position)) then
  begin
    bRetVal := 4;
  end;

  result := bRetVal;
end;

function TForm1.OwasArms(bLeftArmRoll:integer; bLeftArmPitch:integer; bRightArmRoll:integer; bRightArmPitch:integer): integer;
var
  bretval : integer;
begin
  bRetVal := 1;

  bLeftArmRoll := abs(bLeftArmRoll);
  bLeftArmPitch := abs(bLeftArmPitch);
  bRightArmRoll := abs(bRightArmRoll);
  bRightArmPitch := abs(bRightArmPitch);

  if((bRightArmRoll > TrackBar_Shoulder.Position) or (bRightArmPitch > TrackBar_Shoulder.Position)) then
  begin
    bRetVal := bretval + 1;
  end;

  if((bLeftArmRoll > TrackBar_Shoulder.Position) or (bLeftArmPitch > TrackBar_Shoulder.Position)) then
  begin
    bRetVal := bretval + 1;
  end;

  result := bRetVal;
end;


procedure TForm1.Button1Click(Sender: TObject);
var
  res : integer;
begin
  res := OwasLegs(Trackbar1.Position,
                  Trackbar2.Position,
                  Trackbar3.Position,
                  Trackbar4.Position,
                  Trackbar5.Position,
                  Trackbar6.Position,
                  Trackbar7.Position,
                  Trackbar8.Position);
  case res of
    1: showmessage('Sitting');
    2: showmessage('Standing');
    3: showmessage('Standing One Leg');
    4: showmessage('Standing with both legs bent');
    5: showmessage('Standing with one leg bent');
    6: showmessage('Squatting');
    7: showmessage('Moving or Walking');
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  data : string = '-22,-82,-105,143,-86,107,159,-88,59,141,-84,-5,-156,-86,45,82,-87,-146,-119,-88,26,';
begin
  OwasCalc(data);
end;

function TForm1.OwasLegs(bRightUpperLeg:integer;
                         bRightLowerLeg:integer;
                         bLeftUpperLeg:integer;
                         bLeftLowerLeg:integer;
                         bRightMoveR:integer;
                         bRightMoveP:integer;
                         bLeftMoveR:integer;
                         bLeftMoveP:integer): integer;
var
  bretval : integer;
begin
  bRetVal := 1;

  bRightUpperLeg   := abs(bRightUpperLeg);
  bRightLowerLeg   := abs(bRightLowerLeg);
  bLeftUpperLeg    := abs(bLeftUpperLeg );
  bLeftLowerLeg    := abs(bLeftLowerLeg );
  bRightMoveR      := abs(bRightMoveR   );
  bRightMoveP      := abs(bRightMoveP   );
  bLeftMoveR       := abs(bLeftMoveR    );
  bLeftMoveP       := abs(bLeftMoveP    );

  { Moving or Walking }
  if ((bRightMoveR > TrackBar_MoveSens.Position) or (bRightMoveP > TrackBar_MoveSens.Position))
    and ((bLeftMoveR > TrackBar_MoveSens.Position) or (bLeftMoveP > TrackBar_MoveSens.Position)) then
  begin
    bRetVal := 7;
  end

  { Standing with one leg }
  else if ((compareInRange(bRightUpperLeg, TrackBar_LegStand.Position, TrackBar_LegBent.Position)
        and compareInRange(bLeftUpperLeg, TrackBar_LegBent.Position, 180))
          or ((compareInRange(bRightUpperLeg, TrackBar_LegBent.Position, 180)
            and compareInRange(bLeftUpperLeg, TrackBar_LegStand.Position, TrackBar_LegBent.Position)))) then
  begin
    bRetVal := 3;
  end

  { Stand }
  else if(compareInRange(bRightUpperLeg, TrackBar_LegStand.Position, TrackBar_LegBent.Position)
      and compareInRange(bLeftUpperLeg, TrackBar_LegStand.Position, TrackBar_LegBent.Position)) then
  begin
    bRetVal := 2;
  end

  { Standing with one leg bent }
  else if((compareInRange(bRightUpperLeg, TrackBar_LegBent.Position, TrackBar_LegSit.Position)
      and compareInRange(bLeftUpperLeg, TrackBar_LegSit.Position, 180))
        or ((compareInRange(bRightUpperLeg, TrackBar_LegSit.Position, 180)
          and compareInRange(bLeftUpperLeg, TrackBar_LegBent.Position, TrackBar_LegSit.Position)))) then
  begin
    bRetVal := 5;
  end

  { Standing with both legs bent }
  else if((compareInRange(bRightUpperLeg, TrackBar_LegBent.Position, TrackBar_LegSit.Position)
        and compareInRange(bLeftUpperLeg, TrackBar_LegBent.Position, TrackBar_LegSit.Position))) then
  begin
    bRetVal := 4;
  end

  { Sit }
  else if((compareInRange(bRightUpperLeg, TrackBar_LegSit.Position, TrackBar_LegSquat.Position)
      and compareInRange(bLeftUpperLeg, TrackBar_LegSit.Position, TrackBar_LegSquat.Position))) then
  begin
    bRetVal := 1;
  end

  { Squatting }
  else if((compareInRange(bRightUpperLeg, TrackBar_LegSquat.Position, 180)
      and compareInRange(bLeftUpperLeg, TrackBar_LegSquat.Position, 180))) then
  begin
    bRetVal := 6;
  end

  { Default: Sitting }
  else
  begin
    bRetVal := 1;
  end;

  result := bRetVal;

end;

function TForm1.OwasLoad(nUserLoad:integer): integer;
var
  bretval : integer;
begin 
  bRetVal := 1;

  if((nUserLoad >= TrackBar_Load1.Position) and (nUserLoad < TrackBar_Load2.Position)) then
  begin
    bRetVal := 2;
  end
  else if (nUserLoad >= TrackBar_Load2.Position) then
  begin
    bRetVal := 3;
  end;

  result := bRetVal;

end;

function TForm1.CompareInRange(range : integer; limit1 : integer; limit2 : integer) : boolean;
var
  bretval : boolean;
begin
  bRetVal := false;

  if (limit1 <= range ) and (range < limit2) then
  begin
    bRetVal := true;
  end;

  result := bRetVal;
end;

procedure TForm1.TimerTimer(Sender: TObject);
begin
  Button7Click(sender);
end;

end.

