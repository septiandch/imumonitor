unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, FPCanvas, Dialogs, ComCtrls,
  StdCtrls, ExtCtrls, EditBtn, Grids, TAGraph, TASeries, TARadialSeries, LCLType,
  IniFiles, fpjson, jsonparser, fphttpclient, strutils, dateutils, owas, common;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button_Start: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    
    Edit_Nama: TEdit;
    Edit_Kegiatan: TEdit;
    Edit_Usia: TEdit;
    Edit_Tinggi: TEdit;
    Edit_Berat: TEdit;

    Edit1: TEdit;

    FileNameEdit: TFileNameEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;

    Label_Legend_Owas: TLabel;
    Label_AlarmCheck: TLabel;
    Label_Lv_Shoulder: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    Label_MainTitle: TLabel;
    Label_Date: TLabel;
    Label_Legend_Roll: TLabel;
    Label_Legend_Pitch: TLabel;
    Label_Legend_Yaw: TLabel;
    Label_Owas_Back: TLabel;
    Label_Owas_Arms: TLabel;
    Label_Owas_Legs: TLabel;
    Label_Owas_Load: TLabel;
    Label_Owas_BackNum: TLabel;
    Label_Owas_ArmsNum: TLabel;
    Label_Owas_LegsNum: TLabel;
    Label_Owas_LoadNum: TLabel;
    Label_SensorSelect: TLabel;
    Label_Lv_BackBent: TLabel;
    Label_Lv_BackTwist: TLabel;
    Label_Lv_Load1: TLabel;
    Label_Lv_LegStand: TLabel;
    Label_FileNameEdit: TLabel;
    Label_Lv_LegBent: TLabel;
    Label_Lv_LegSit: TLabel;
    Label_Lv_Load2: TLabel;
    Label_Lv_LegSquat: TLabel;
    Label_Lv_MoveSens: TLabel;
    Label3: TLabel;
    Label_Legend_Legs: TLabel;
    Label_Legend_Load: TLabel;
    Label_Legend_Arms: TLabel;
    Label_Legend_Back: TLabel;
    Label_Owas: TLabel;
    Label_OwasNum: TLabel;

    Chart_Owas: TChart;
    LineSeries_Owas: TLineSeries;
    LineSeries_Legs: TLineSeries;
    LineSeries_Load: TLineSeries;
    LineSeries_Arms: TLineSeries;
    LineSeries_Back: TLineSeries;

    Chart_Sensors: TChart;
    LineSeries_Roll: TLineSeries;
    
    LineSeries_Pitch: TLineSeries;
    
    LineSeries_Yaw: TLineSeries;

    ComboBox_Sensor: TComboBox;
    
    Memo1: TMemo;
    Memo2: TMemo;
    
    PageControl1: TPageControl;
    Shape_StatLamp: TShape;
    StringGrid_SensorOverview: TStringGrid;

    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    Shape5: TShape;
    Shape6: TShape;
    Shape7: TShape;
    Shape8: TShape;

    Timer: TTimer;

    TrackBar_BackBent: TTrackBar;
    TrackBar_BackTwist: TTrackBar;
    TrackBar_LegBent: TTrackBar;
    TrackBar_LegSit: TTrackBar;
    TrackBar_LegSquat: TTrackBar;
    TrackBar_LegStand: TTrackBar;
    TrackBar_Load2: TTrackBar;
    TrackBar_Load1: TTrackBar;
    TrackBar_MoveSens: TTrackBar;
    TrackBar_AlarmCheck: TTrackBar;
    TrackBar_Shoulder: TTrackBar;

    Trackbar1: TTrackBar;
    Trackbar2: TTrackBar;
    Trackbar3: TTrackBar;
    Trackbar4: TTrackBar;
    Trackbar5: TTrackBar;
    Trackbar6: TTrackBar;
    Trackbar7: TTrackBar;
    Trackbar8: TTrackBar;
                                             
    procedure Button9Click(Sender: TObject);
    procedure Edit_BeratKeyPress(Sender: TObject; var Key: char);
    procedure Edit_TinggiKeyPress(Sender: TObject; var Key: char);
    procedure Edit_UsiaKeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure Button_StartClick(Sender: TObject);

    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);

    procedure ComboBox_SensorChange(Sender: TObject);
                                                                             
    procedure FileNameEditAcceptFileName(Sender: TObject; var Value: String);

    procedure LoadCsv;
    procedure OwasCheckSim;
    procedure TrackBar1Change(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
    procedure TrackBar3Change(Sender: TObject);
    procedure TrackBar4Change(Sender: TObject);
    procedure TrackBar5Change(Sender: TObject);
    procedure TrackBar6Change(Sender: TObject);
    procedure TrackBar7Change(Sender: TObject);
    procedure TrackBar8Change(Sender: TObject);
    procedure TrackBar_BackBentChange(Sender: TObject);
    procedure TrackBar_BackTwistChange(Sender: TObject);
    procedure TrackBar_LegBentChange(Sender: TObject);
    procedure TrackBar_LegSitChange(Sender: TObject);
    procedure TrackBar_LegSquatChange(Sender: TObject);
    procedure TrackBar_LegStandChange(Sender: TObject);
    procedure TrackBar_Load1Change(Sender: TObject);
    procedure TrackBar_Load2Change(Sender: TObject);
    procedure TrackBar_MoveSensChange(Sender: TObject);
    procedure TrackBar_ShoulderChange(Sender: TObject);   
    procedure TrackBar_AlarmCheckChange(Sender: TObject);

    procedure UpdateEndTimeCsv(time : String);

    procedure InitializeLineSeries;
    procedure SelectLineSeries(select:integer);  
    Procedure UpdateChart(Data : string);
    Procedure UpdateSensorChart(rowdata : integer; pitchdata : integer; yawdata : integer; index : integer);

    procedure InitializeLevelSettings;

    procedure TimerTimer(Sender: TObject);    
    procedure getData(devindex : integer);
    procedure processData();

    procedure alarmSetup(level : integer);
  private
    FCounter1: PtrInt;
    FCounter2: PtrInt;
    FCounter3: PtrInt;
    FCounter4: PtrInt;
    FCounter5: PtrInt;
    FCounter6: PtrInt;
    FCounter7: PtrInt;
    FCounter8: PtrInt;
    procedure Async1(Data: PtrInt);
    procedure Async2(Data: PtrInt);
    procedure Async3(Data: PtrInt);
    procedure Async4(Data: PtrInt);
    procedure Async5(Data: PtrInt);
    procedure Async6(Data: PtrInt);
    procedure Async7(Data: PtrInt);
    procedure Async8(Data: PtrInt);
  public
  end;

var
  Form1: TForm;
  CsvFileName: string;
  CsvFileDir: string;
  bMonitoringState : boolean;  
  nTime : TDateTime;
  nAlarmTime : array[0..4] of TDateTime;
  deviceindex : integer;
  sDataList : TStringList;
  nValueRoll, nValuePitch, nValueYaw : array of array of integer;
  nSensorData_Count: integer;     
  sData : array[1..8] of string;
  bReady : array[1..8] of boolean;
  bFirstData : boolean;
  bLoadCSV : boolean;
  bRetry : array[1..8] of integer;
  bPrevOwas : integer;
  bCheckOwas : integer;

const
  DEVICE_COUNT : integer = 8;
  DATA_COUNT : integer = 500;
  MAX_DATA : integer = 10000;
  MAX_RETRY : integer = 3;

implementation

{$R *.lfm}

{ TForm1 }     

procedure TForm1.FormCreate(Sender: TObject);
var
  INI: TINIFile; 
  today : TDateTime;
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
    TrackBar_AlarmCheck.Position  := INI.ReadInteger('Config' , 'AlarmChk'  , 5   );
  finally
    INI.Free;
  end;

  TrackBar_ShoulderChange(nil);
  TrackBar_BackBentChange(nil);
  TrackBar_BackTwistChange(nil);
  TrackBar_LegStandChange(nil);
  TrackBar_LegBentChange(nil);
  TrackBar_LegSitChange(nil);
  TrackBar_LegSquatChange(nil);
  TrackBar_Load1Change(nil);
  TrackBar_Load2Change(nil);
  TrackBar_MoveSensChange(nil);
  TrackBar_AlarmCheckChange(nil);

  PageControl1.ActivePage := TabSheet1;
  TabSheet5.TabVisible := false;

  sDataList := TStringList.Create;

  If Not DirectoryExists('csv') then CreateDir ('csv');

  FileNameEdit.InitialDir := GetCurrentDir() + '/csv';

  Setlength(nValueRoll, 8, MAX_DATA);
  Setlength(nValuePitch, 8, MAX_DATA);
  Setlength(nValueYaw, 8, MAX_DATA);

  today := Now;
  Label_date.Caption := FormatDateTime('dd', today) + '-' +
                        FormatDateTime('MM', today) + '-' +
                        FormatDateTime('yyyy', today);

  InitializeLineSeries;
  InitializeLevelSettings;
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
    INI.WriteInteger('Config' , 'AlarmChk',  TrackBar_AlarmCheck.Position );
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

procedure TForm1.Button_StartClick(Sender: TObject);
var                
  today : TDateTime;
  csvFile : text;
  F : longint;
  currentdir, stemp : string;
  stringlist: TStringList;
  i : integer;
begin
  today := Now;

  if bMonitoringState then
  begin
    Timer.Enabled := False;
    bMonitoringState := false;
    Button_Start.Caption := 'Start Monitoring';
    Button_Start.Font.Color := clDefault;
    Button_Start.Font.Bold := false;
    Shape_StatLamp.Brush.Color := clScrollBar;

    UpdateEndTimeCsv(FormatDateTime('hh',nTime)
                     + ':' + FormatDateTime('nn',nTime));

    FileNameEdit.Enabled := True;
  end else
  begin
     if (Edit_Nama.Text <> '') and (Edit_Nama.Text <> '')
       and (Edit_Nama.Text <> '') and (Edit_Nama.Text <> '')
       and (Edit_Kegiatan.Text <> '') then
     begin
       bMonitoringState := true;
       Button_Start.Caption := 'Stop Monitoring';
       Button_Start.Font.Color := clRed;
       Button_Start.Font.Bold := true;      
       Shape_StatLamp.Brush.Color := clLime;

       nTime := Now;
       
       deviceindex := 1;

       FileNameEdit.Enabled := false;

       bFirstData := false;

       InitializeLineSeries;

       sDataList.clear;

       InitializeLevelSettings;

       currentdir := GetCurrentDir;
       CsvFileDir := currentdir + '/csv';
       chdir(csvFileDir);
       csvFileName := Label_Date.Caption + '_' + Edit_Nama.Text + '.csv';

       stemp := '';
       for i := 1 to DEVICE_COUNT do
       begin
         stemp := stemp + 'Roll_'+ inttostr(i)
                        + ',Pitch_' + inttostr(i)
                        + ',Yaw_' + inttostr(i)
                        + ',';

         // reset ready flag
         bReady[i] := false;
       end;

       for i := 0 to 4 do
       begin
           //nAlarmTime[i] := Now;
       end;

       if not FileExists(csvFileName) then
       begin
         {
         FileCreate(csvFileName);

         stringlist := TStringList.Create;
         try
           stringlist.LoadFromFile(csvFileName);

           stringlist.Add('Nama,Usia,Tinggi,Berat,Kegiatan,Start,End');
           stringlist.Add(Edit_Nama.Text
                          + ',' + Edit_Usia.Text
                          + ',' + Edit_Tinggi.Text
                          + ',' + Edit_Berat.Text
                          + ',' + Edit_Kegiatan.Text
                          + ',' + FormatDateTime('hh',Today)
                          + ':' + FormatDateTime('nn',Today)
                          + ',-,' );
           stringlist.Add('Time,OWAS,Back,Arms,Legs,Load,' + stemp);
           stringlist.SaveToFile(csvFileName);
         finally                
           stringlist.free;
         end;
         }

         Assignfile(csvfile, csvFileName);
	 Rewrite(csvFile);

         Writeln(csvFile, 'Nama,Usia,Tinggi,Berat,Kegiatan,Start,End');
	 Writeln(csvFile, Edit_Nama.Text
                          + ',' + Edit_Usia.Text
                          + ',' + Edit_Tinggi.Text
                          + ',' + Edit_Berat.Text
                          + ',' + Edit_Kegiatan.Text
                          + ',' + FormatDateTime('hh',Today)
                          + ':' + FormatDateTime('nn',Today)
                          + ',-,' );      
         Writeln(csvFile, 'Time,OWAS,Back,Arms,Legs,Load,' + stemp);

	 CloseFile(csvFile);
      end;

      chdir(currentdir);   

      Timer.Enabled := True;

    end else
    begin
      ShowMessage('Lengkapi data user terlebih dahulu...');      
      PageControl1.ActivePage := TabSheet4;
    end;
  end;
end;

procedure TForm1.getData(devindex : integer);
begin
  bReady[devindex] := true;

  try
    if(bMonitoringState) then
      sData[devindex] := TFPCustomHTTPClient.SimpleGet('http://192.168.4.11' + inttostr(devindex));
  except
    on E: Exception do
    begin
      if bRetry[devindex] < MAX_RETRY then
      begin
        bRetry[devindex] := bRetry[devindex] + 1;
        getData(devindex);
      end else
      begin
        sData[devindex] := 'ERROR';
        bReady[devindex] := false;

        Button_StartClick(nil);

        ShowMessage('Connection Error!'
                    + sLineBreak
                    + 'Please check if all devices turned on. Then restart the monitoring.');
      end;
    end;
  end;

  if (bReady[1] and bReady[2] and bReady[3] and bReady[4] and bReady[5]
    and bReady[6] and bReady[7] and bReady[8]) then
  begin
    processData();
  end;
end;

procedure TForm1.processData();
var
  currentdir : string;
  sTimeStamp : string;
  csvfile : text;
  Json : TJSONData;
  JarrayRoll : TJSonArray;
  JarrayPitch : TJSonArray;
  JarrayYaw : TJSonArray;
  devindex, index : integer;
  berror : boolean;
begin
  berror := false;

  for devindex := 1 to DEVICE_COUNT do
  begin
    if AnsiContainsStr(sData[devindex], 'Not Ready') then
    begin
      showmessage('Device' + inttostr(devindex) + ' is not ready !');
      berror := true;
    end else if(sData[devindex] = 'ERROR') then
    begin
      ShowMessage('Connection Error!'
                  + sLineBreak
                  + 'Pastikan semua device telah menyala dan terkoneksi.');
      berror := true;
    end else
    begin
      try
        Json := GetJSON(sData[devindex]);  
      except
        on E : Exception do
            berror := true;
      end;

      if not berror then
      begin
        JarrayRoll := TJSONArray(Json.FindPath('roll'));
        JarrayPitch := TJSONArray(Json.FindPath('pitch'));
        JarrayYaw := TJSONArray(Json.FindPath('yaw'));

        for index := 0 to DATA_COUNT do
        begin
          if(devindex = 1) then sDataList.Add(JarrayRoll.Strings[index])
          else sDataList[index] := sDataList[index] + JarrayRoll.Strings[index];
          sDataList[index] := sDataList[index] + ',' + JarrayPitch.Strings[index];
          sDataList[index] := sDataList[index] + ',' + JarrayYaw.Strings[index] + ',';
        end;
      end;
    end;
  end;

  if not berror then
  begin
    currentdir := GetCurrentDir;
    chdir(csvFileDir);
    Assignfile(csvfile, csvFileName);
    Append(csvfile);

    for index := 0 to sDataList.Count - 1 do
    begin
      OwasParseValue(sDataList[index]);

      sDataList[index] := OwasCalc(strtoint(Edit_Berat.Text));

      sTimeStamp := FormatDateTime('hh',nTime)
                    + ':' + FormatDateTime('nn',nTime)
                    + ':' + FormatDateTime('ss',nTime)
                    + ':' + IntToStr((index mod 100) + 1)
                    + ',' ;

      writeln(csvfile, sTimeStamp + sDataList[index]);

      if ave_index = 0 then
      begin
        if not bFirstData then
        begin
          OwasSetBackInitialValue();

          bFirstData := true;
        end;

        UpdateChart(sTimeStamp + OwasCalcAve(strtoint(Edit_Berat.Text)));

        label1.Caption:=inttostr(movesense_value[LEG_RIGHT_RMOVE]);
        label2.Caption:=inttostr(movesense_value[LEG_LEFT_RMOVE]);

        nTime := IncSecond(nTime, 1);
      end;

    end;

    closefile(csvfile);

    chdir(currentDir);
  end;

  for devindex := 1 to DEVICE_COUNT do
  begin
    bReady[devindex] := false;
    bRetry[devindex] := 0;
  end;

  sDataList.clear;
end;

procedure TForm1.ComboBox_SensorChange(Sender: TObject);
begin
  SelectLineSeries(ComboBox_Sensor.ItemIndex);
end;

procedure TForm1.InitializeLevelSettings;
begin
  OwasSetting(
    TrackBar_BackBent.Position,
    TrackBar_BackTwist.Position,
    TrackBar_Shoulder.Position,
    TrackBar_LegStand.Position,
    TrackBar_LegBent.Position,
    TrackBar_LegSit.Position,
    TrackBar_LegSquat.Position,
    TrackBar_Load1.Position,
    TrackBar_Load2.Position,
    TrackBar_MoveSens.Position
  );
end;

procedure TForm1.InitializeLineSeries;
begin
  LineSeries_Owas.clear;
  LineSeries_Back.clear;
  LineSeries_Legs.clear;
  LineSeries_Arms.clear;
  LineSeries_Load.clear;

  LineSeries_Roll.clear;
  LineSeries_Pitch.clear;
  LineSeries_Yaw.clear;

  LineSeries_Roll.LinePen.Color  := clBlue;
  LineSeries_Pitch.LinePen.Color  := clYellow;
  LineSeries_Yaw.LinePen.Color  := clRed;

  LineSeries_Roll.LinePen.Width  := 3;
  LineSeries_Pitch.LinePen.Width  := 3;
  LineSeries_Yaw.LinePen.Width  := 3;

  nSensorData_Count := 0;
end;

procedure TForm1.LoadCsv;
var
  csv: TextFile;
  str, currentdir: String;
  nhundredcount: integer;
begin
  currentdir := getCurrentDir;
  chdir(currentdir + '/csv');

  bLoadCSV := true;

  if FileExists(FileNameEdit.FileName) then
  begin
    InitializeLineSeries;

    nhundredcount := 0;

    AssignFile(csv, FileNameEdit.FileName);
    Reset(csv);
    while not Eof(csv) do
    begin
      ReadLn(csv, str);

      if (nhundredcount > 3) and ((nhundredcount mod 100) = 0) then
      begin
        UpdateChart(str);
      end;

      nhundredcount := nhundredcount + 1;
    end;

    CloseFile(csv);
  end
  else
  begin
    ShowMessage('File is not exist');
  end;

  chdir(currentdir);

  bLoadCSV := false;
end;

procedure TForm1.TrackBar_BackBentChange(Sender: TObject);
begin
  Label_Lv_BackBent.Caption := 'Back Bent Level : ' + inttostr(TrackBar_BackBent.Position);
end;

procedure TForm1.TrackBar_BackTwistChange(Sender: TObject);
begin
  Label_Lv_BackTwist.Caption := 'Back Twist Level : ' + inttostr(TrackBar_BackTwist.Position);
end;

procedure TForm1.TrackBar_LegBentChange(Sender: TObject);
begin            
  Label_Lv_LegBent.Caption := 'Bent Leg Level : ' + inttostr(TrackBar_LegBent.Position);
end;

procedure TForm1.TrackBar_LegSitChange(Sender: TObject);
begin
  Label_Lv_LegSit.Caption := 'Sitting Level : ' + inttostr(TrackBar_LegSit.Position);
end;

procedure TForm1.TrackBar_LegSquatChange(Sender: TObject);
begin
  Label_Lv_LegSquat.Caption := 'Squatting Level : ' + inttostr(TrackBar_LegSquat.Position);
end;

procedure TForm1.TrackBar_LegStandChange(Sender: TObject);
begin
  Label_Lv_LegStand.Caption := 'Standing Level : ' + inttostr(TrackBar_LegStand.Position);
end;

procedure TForm1.TrackBar_Load1Change(Sender: TObject);
begin
  Label_Lv_Load1.Caption := 'Load 1 Level : ' + inttostr(TrackBar_Load1.Position);
end;

procedure TForm1.TrackBar_Load2Change(Sender: TObject);
begin
  Label_Lv_Load2.Caption := 'Load 2 Level : ' + inttostr(TrackBar_Load2.Position);
end;

procedure TForm1.TrackBar_MoveSensChange(Sender: TObject);
begin
  Label_Lv_MoveSens.Caption := 'Move Sensitivity : ' + inttostr(TrackBar_MoveSens.Position);
end;

procedure TForm1.TrackBar_ShoulderChange(Sender: TObject);
begin
  Label_Lv_Shoulder.Caption := 'Shoulder Level : ' + inttostr(TrackBar_Shoulder.Position);
end;

procedure TForm1.TrackBar_AlarmCheckChange(Sender: TObject);
begin
  Label_AlarmCheck.Caption := 'Alarm Check : ' + inttostr(TrackBar_AlarmCheck.Position);
end;

procedure TForm1.UpdateEndTimeCsv(time : String);
var
  strlist : TStringList;                
  currentdir: String;
begin
  currentdir := getCurrentDir;
  chdir(currentdir + '/csv');

  strlist := TStringList.Create;
  strlist.LoadFromFile(CsvFileName);

  strlist.strings[1] := stringreplace(strlist.strings[1], ',-,', ',' + time + ',', []);

  strlist.SaveToFile(CsvFileName);

  chdir(currentdir);
end;

Procedure TForm1.UpdateChart(data : string);
var
  strlist: TStringArray;
  i, index, sel: integer;
begin
  strlist := TStringArray.create;

  strlist := split(data, ',');

  Label_OwasNum.Caption := strlist[1];
  Label_Owas_BackNum.Caption := strlist[2];
  Label_Owas_ArmsNum.Caption := strlist[3];
  Label_Owas_LegsNum.Caption := strlist[4];
  Label_Owas_LoadNum.Caption := strlist[5];

  { ------------------------------------------------------------------- }

   Label10.caption := strlist[4];

   if(strlist[4] = '1') then Label10.caption := Label10.caption + ' : sit'
   else if(strlist[4] = '2') then Label10.caption := Label10.caption + ' : stand'
   else if(strlist[4] = '3') then Label10.caption := Label10.caption + ' : 1 leg stand'
   else if(strlist[4] = '4') then Label10.caption := Label10.caption + ' : stand or squat with legs bent'
   else if(strlist[4] = '5') then Label10.caption := Label10.caption + ' : stand or squat with 1 leg bent'
   else if(strlist[4] = '6') then Label10.caption := Label10.caption + ' : kneeling'
   else if(strlist[4] = '7') then Label10.caption := Label10.caption + ' : moving'
   else Label10.caption := Label10.caption + ' : Not set';

  { ------------------------------------------------------------------- }

  if (not bLoadCSV) then
  begin
    if bPrevOwas = strtoint(strlist[1]) then
    begin
      bCheckOwas := bCheckOwas + 1;
    end else
    begin
      bCheckOwas := 0;
    end;

    label1.Caption := inttostr(bCheckOwas);
    bPrevOwas := strtoint(strlist[1]);

    if bCheckOwas >= TrackBar_AlarmCheck.Position then
    begin
      alarmSetup(strtoint(strlist[1]));
      bCheckOwas := 0;
    end;
  end;

  case strtoint(strlist[1]) of
    0:
      begin
        Label_Owas.Font.Color := clDefault;
        Label_OwasNum.Font.Color := clDefault;
      end;
    1:
      begin
        Label_Owas.Font.Color := clGreen;
        Label_OwasNum.Font.Color := clGreen;
      end;
    2:
      begin
        Label_Owas.Font.Color := clBlue;
        Label_OwasNum.Font.Color := clBlue;
      end;
    3:
      begin
        Label_Owas.Font.Color := TColor($001F65FF);
        Label_OwasNum.Font.Color := TColor($001F65FF);
      end;
    4:
      begin
        Label_Owas.Font.Color := clRed;
        Label_OwasNum.Font.Color := clRed;
      end;
  end;

  LineSeries_Owas.AddXY(nSensorData_Count + 1,   strtoint(strlist[1]));
  LineSeries_Back.AddXY(nSensorData_Count + 1,   strtoint(strlist[2]));
  LineSeries_Arms.AddXY(nSensorData_Count + 1,   strtoint(strlist[3]));
  LineSeries_Legs.AddXY(nSensorData_Count + 1,   strtoint(strlist[4]));
  LineSeries_Load.AddXY(nSensorData_Count + 1,   strtoint(strlist[5]));

  index := 6;
  for i := 0 to DEVICE_COUNT - 1 do
  begin
    nValueRoll[i][nSensorData_Count] := strtoint(strlist[index]);
    index := index + 1;

    nValuePitch[i][nSensorData_Count] := strtoint(strlist[index]);
    index := index + 1;

    nValueYaw[i][nSensorData_Count] := strtoint(strlist[index]);
    index := index + 1;
  end;

  sel := ComboBox_Sensor.ItemIndex;
  index := nSensorData_Count;
  UpdateSensorChart(nValueRoll[sel][index], nValuePitch[sel][index], nValueYaw[sel][index], index);

  // Update Sensor String Grid
  for sel := 1 to DEVICE_COUNT do
  begin
    StringGrid_SensorOverview.Cells[1, sel] := inttostr(nValueRoll[sel-1][index]);
    StringGrid_SensorOverview.Cells[2, sel] := inttostr(nValuePitch[sel-1][index]);
    StringGrid_SensorOverview.Cells[3, sel] := inttostr(nValueYaw[sel-1][index]);
  end;

  if nSensorData_Count < MAX_DATA then nSensorData_Count := nSensorData_Count + 1;
end;

Procedure TForm1.UpdateSensorChart(rowdata : integer; pitchdata : integer; yawdata : integer; index : integer);
begin
  LineSeries_Roll.AddXY(index + 1,  rowdata);
  LineSeries_Pitch.AddXY(index + 1, pitchdata);
  LineSeries_Yaw.AddXY(index + 1,   yawdata);
end;

procedure TForm1.SelectLineSeries(select : integer);
var
  i, sel : integer;
begin
  LineSeries_Roll.Clear;
  LineSeries_Pitch.Clear;
  LineSeries_Yaw.Clear;

  sel := ComboBox_Sensor.ItemIndex;

  for i := 0 to nSensorData_Count - 1 do
  begin
    UpdateSensorChart(nValueRoll[sel][i], nValuePitch[sel][i], nValueYaw[sel][i], i);
  end;
end;

procedure TForm1.alarmSetup(level : integer);
var
  timediff : integer;
  bSetAlarm : boolean;
begin
  timediff := MinutesBetween(Now, nAlarmTime[level]);

  if (level = 1) or
     ((level = 2) and (timediff >= 1440)) or
     ((level = 3) and (timediff >= 10)) or
     ((level = 4) and (timediff >= 1))  then
  begin
    nAlarmTime[level] := Now;
    TFPCustomHTTPClient.SimpleGet('http://192.168.4.118/alert' + inttostr(level));
  end;
end;

procedure TForm1.TimerTimer(Sender: TObject);
begin
     Application.QueueAsyncCall(@ASync1, FCounter1);
     Application.QueueAsyncCall(@ASync2, FCounter2);
     Application.QueueAsyncCall(@ASync3, FCounter3);
     Application.QueueAsyncCall(@ASync4, FCounter4);
     Application.QueueAsyncCall(@ASync5, FCounter5);
     Application.QueueAsyncCall(@ASync6, FCounter6);
     Application.QueueAsyncCall(@ASync7, FCounter7);
     Application.QueueAsyncCall(@ASync8, FCounter8);
end;

procedure TForm1.Async1(Data: PtrInt);
begin
  if not bReady[1] then getData(1);
end;

procedure TForm1.Async2(Data: PtrInt);
begin
  if not bReady[2] then getData(2);
end;

procedure TForm1.Async3(Data: PtrInt);
begin
  if not bReady[3] then getData(3);
end;

procedure TForm1.Async4(Data: PtrInt);
begin
  if not bReady[4] then getData(4);
end;

procedure TForm1.Async5(Data: PtrInt);
begin
  if not bReady[5] then getData(5);
end;

procedure TForm1.Async6(Data: PtrInt);
begin
  if not bReady[6] then getData(6);
end;

procedure TForm1.Async7(Data: PtrInt);
begin
  if not bReady[7] then getData(7);
end;

procedure TForm1.Async8(Data: PtrInt);
begin
  if not bReady[8] then getData(8);
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  res : integer;
begin
  {
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
  }

  UpdateChart('00:32:52:1,1,1,3,1,1,2,-1,3,103,-26,-9,-164,13,0,52,-80,1,-2,0,0,-132,76,20,-69,-2,2,1,0,8,174,endl');
end;    

procedure TForm1.Button2Click(Sender: TObject);
var
  data : string = '-22,-82,-105,143,-86,107,159,-88,59,141,-84,-5,-156,-86,45,82,-87,-146,-119,-88,26,';
begin
  {
  OwasParseValue(data);
  OwasCalc(strtoint(Edit_Berat.Text));
  }

  UpdateChart('00:32:52:1,2,1,3,1,1,2,-1,3,103,-26,-9,-164,13,0,52,-80,1,-2,0,0,-132,76,20,-69,-2,2,1,0,8,174,endl');
end; 

procedure TForm1.Button8Click(Sender: TObject);
begin
  Edit_Nama.Text := 'Budi';
  Edit_Usia.Text := '27';
  Edit_Tinggi.Text := '170';
  Edit_Berat.Text := '15';
  Edit_Kegiatan.Text := 'Mengelas';
end;            

procedure TForm1.Button9Click(Sender: TObject);
begin
  CsvFileName := '21-06-2021_Andri.csv';
  UpdateEndTimeCsv('06:20');
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  Label1.Caption := inttostr(TrackBar1.Position);  
  OwasCheckSim;
end;

procedure TForm1.TrackBar2Change(Sender: TObject);
begin
  Label2.Caption := inttostr(TrackBar2.Position);  
  OwasCheckSim;
end;

procedure TForm1.TrackBar3Change(Sender: TObject);
begin
  Label4.Caption := inttostr(TrackBar3.Position); 
  OwasCheckSim;
end;

procedure TForm1.TrackBar4Change(Sender: TObject);
begin
  Label5.Caption := inttostr(TrackBar4.Position); 
  OwasCheckSim;
end;

procedure TForm1.TrackBar5Change(Sender: TObject);
begin
  Label6.Caption := inttostr(TrackBar5.Position);   
  OwasCheckSim;
end;

procedure TForm1.TrackBar6Change(Sender: TObject);
begin
  Label7.Caption := inttostr(TrackBar6.Position);   
  OwasCheckSim;
end;

procedure TForm1.TrackBar7Change(Sender: TObject);
begin
  Label8.Caption := inttostr(TrackBar7.Position);  
  OwasCheckSim;
end;

procedure TForm1.TrackBar8Change(Sender: TObject);
begin
  Label9.Caption := inttostr(TrackBar8.Position);
  OwasCheckSim;
end;

procedure TForm1.OwasCheckSim;
var
  result : integer;
begin
   result :=
       OwasLegs(TrackBar1.Position, TrackBar2.Position,
                TrackBar3.Position * -1, TrackBar4.Position *-1,
                0, 0,
                0, 0);

   Label30.caption := inttostr(result);

   if(result = 1) then Label30.caption := Label30.caption + ' : sit'
   else if(result = 2) then Label30.caption := Label30.caption + ' : stand'
   else if(result = 3) then Label30.caption := Label30.caption + ' : 1 leg stand'
   else if(result = 4) then Label30.caption := Label30.caption + ' : stand or squat with legs bent'
   else if(result = 5) then Label30.caption := Label30.caption + ' : stand or squat with 1 leg bent'
   else if(result = 6) then Label30.caption := Label30.caption + ' : kneeling'
   else if(result = 7) then Label30.caption := Label30.caption + ' : moving'
   else Label30.caption := Label30.caption + ' : Not set';
end;

procedure TForm1.Edit_BeratKeyPress(Sender: TObject; var Key: char);
begin
  if not (key in ['0'..'9', Chr(VK_BACK), Char(VK_DELETE)]) then Key := #0;
end;

procedure TForm1.Edit_TinggiKeyPress(Sender: TObject; var Key: char);
begin
  if not (key in ['0'..'9', Chr(VK_BACK), Char(VK_DELETE)]) then Key := #0;
end;

procedure TForm1.Edit_UsiaKeyPress(Sender: TObject; var Key: char);
begin
  if not (key in ['0'..'9', Chr(VK_BACK), Char(VK_DELETE)]) then Key := #0;
end;

end.

