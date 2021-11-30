unit owas;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

const
  OWAS_TABLE : array[0..11, 0..20] of byte =
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

  ROLL : integer = 0;
  PITCH : integer = 1;
  YAW : integer = 2;

  BACK_U : integer = 1;     
  BACK_L : integer = 8;
  ARM_RIGHT : integer = 2;
  ARM_LEFT : integer = 3;
  LEG_RIGHT_U : integer = 4;
  LEG_RIGHT_L: integer = 5;
  LEG_LEFT_U : integer = 6;
  LEG_LEFT_L : integer = 7;

  LEG_RIGHT_RMOVE : integer = 0;
  LEG_RIGHT_PMOVE : integer = 1;
  LEG_LEFT_RMOVE : integer = 2;
  LEG_LEFT_PMOVE : integer = 3;

  DIR_FRONT : integer = 1;
  DIR_BACK : integer = -1;

  PREVMOVE : integer = 0;
  CALCMOVE : integer = 1;

  BACK_UPPER : integer = 0;
  BACK_LOWER : integer = 1;

  AVE_COUNT : integer = 100;

var
  shoulder_level : integer;
  load1_level, load2_level: integer;
  back_bent_level, back_twist_level : integer;
  leg_stand_level, leg_bent_level, leg_sit_level, leg_squat_level, leg_max_level : integer;
  movesense_level : integer;
  sensor_value: array[1..8, 0..2] of integer;
  sensor_value_ave: array[1..8, 0..2] of integer;
  movesense_value: array[0..3] of integer;
  movesense_sample: array[0..3, 0..1] of integer;
  initial_back_yaw: array[0..1] of integer;
  ave_index : integer;

procedure OwasSetting( back_bent_set : integer;
                       back_twist_set : integer;
                       shoulder_set : integer;
                       leg_stand_set : integer;
                       leg_bent_set : integer;
                       leg_sit_set : integer;
                       leg_squat_set : integer;
                       load1_set : integer;
                       load2_set : integer;
                       movesense_set : integer );

procedure OwasSetBackInitialValue();
procedure OwasMoveSenseSet();

procedure OwasParseValue(data: string);

procedure OwasAverageAdd();
procedure OwasAverageSet();

Procedure OwasMoveSenseAdd(leg_right_r : integer;
                           leg_right_p : integer;
                           leg_left_r : integer;
                           leg_left_p : integer);

function OwasCalc(load : integer): string;    
function OwasCalcAve(load : integer): string;
function OwasBack(bBackRoll:integer; bBackPitch:integer; bBackYaw:integer;
                  bBack2Roll:integer; bBack2Pitch:integer; bBack2Yaw:integer): integer;
function OwasArms(bRightArmRoll:integer; bRightArmPitch:integer; bLeftArmRoll:integer; bLeftArmPitch:integer): integer;
function OwasLegs(bRightUpperLegRaw:integer;
                  bRightLowerLegRaw:integer;
                  bLeftUpperLegRaw:integer;
                  bLeftLowerLegRaw:integer;
                  bRightMoveR:integer;
                  bRightMoveP:integer;
                  bLeftMoveR:integer;
                  bLeftMoveP:integer): integer;
function OwasLoad(nUserLoad:integer): integer;
function CompareInRange(range : integer; limit1 : integer; limit2 : integer) : boolean;
function GetLegVal(degree : integer) : integer;

implementation

uses main, common;

procedure OwasSetting( back_bent_set : integer;
                       back_twist_set : integer;
                       shoulder_set : integer;
                       leg_stand_set : integer;
                       leg_bent_set : integer;
                       leg_sit_set : integer;
                       leg_squat_set : integer;
                       load1_set : integer;
                       load2_set : integer;
                       movesense_set : integer
                     );
begin
  shoulder_level    := shoulder_set    ;
  back_bent_level   := back_bent_set   ;
  back_twist_level  := back_twist_set  ;
  leg_stand_level   := leg_stand_set   ;
  leg_stand_level   := leg_stand_set   ;
  leg_bent_level    := leg_bent_set    ;
  leg_sit_level     := leg_sit_set     ;
  leg_squat_level   := leg_squat_set   ;
  leg_max_level     := 181             ;
  load1_level       := load1_set       ;
  load2_level       := load2_set       ;
  movesense_level   := movesense_set   ;
end;

procedure OwasParseValue(data: string);
var                                      
  datalist   : TStringArray;
  i, index : integer;
begin
  data := data + ',endl';

  datalist := TStringArray.create;
  datalist := split(data, ',');

  for i := 1 to 8 do
  begin
    index := (i - 1) * 3;

    sensor_value[i][ROLL]  := strtoint(datalist[index + 0]);
    sensor_value[i][PITCH] := strtoint(datalist[index + 1]);
    sensor_value[i][YAW]   := strtoint(datalist[index + 2]);
  end;

  OwasAverageAdd;
end;

procedure OwasAverageAdd();
var
  i : integer;
begin
  for i := 1 to 8 do
  begin
    sensor_value_ave[i][ROLL]  := sensor_value_ave[i][ROLL]  + sensor_value[i][ROLL];
    sensor_value_ave[i][PITCH] := sensor_value_ave[i][PITCH] + sensor_value[i][PITCH];
    sensor_value_ave[i][YAW]   := sensor_value_ave[i][YAW]   + sensor_value[i][YAW];
  end;

  OwasMoveSenseAdd( abs(sensor_value[LEG_RIGHT_U][ROLL]),
                    abs(sensor_value[LEG_RIGHT_U][PITCH]),
                    abs(sensor_value[LEG_LEFT_U][ROLL]),
                    abs(sensor_value[LEG_LEFT_U][PITCH]) );

  ave_index := ave_index + 1;

  if ave_index = AVE_COUNT then
  begin
    OwasAverageSet;
    OwasMoveSenseSet;

    ave_index := 0;
  end;
end;

procedure OwasAverageSet();
var
  i : integer;
begin
  for i := 1 to 8 do
  begin
    sensor_value_ave[i][ROLL]  := round(sensor_value_ave[i][ROLL]  / AVE_COUNT);
    sensor_value_ave[i][PITCH] := round(sensor_value_ave[i][PITCH] / AVE_COUNT);
    sensor_value_ave[i][YAW]   := round(sensor_value_ave[i][YAW]   / AVE_COUNT);
  end;
end;

procedure OwasMoveSenseSet();
begin
  movesense_value[LEG_RIGHT_RMOVE] := movesense_sample[LEG_RIGHT_RMOVE][CALCMOVE];
  movesense_value[LEG_RIGHT_PMOVE] := movesense_sample[LEG_RIGHT_PMOVE][CALCMOVE];
  movesense_value[LEG_LEFT_RMOVE]  := movesense_sample[LEG_LEFT_RMOVE][CALCMOVE];
  movesense_value[LEG_LEFT_PMOVE]  := movesense_sample[LEG_LEFT_PMOVE][CALCMOVE];

  movesense_sample[LEG_RIGHT_RMOVE][CALCMOVE] := 0;
  movesense_sample[LEG_RIGHT_PMOVE][CALCMOVE] := 0;
  movesense_sample[LEG_LEFT_RMOVE][CALCMOVE]  := 0;
  movesense_sample[LEG_LEFT_PMOVE][CALCMOVE]  := 0;
end;

procedure OwasSetBackInitialValue();
begin
  initial_back_yaw[BACK_UPPER] := abs(sensor_value_ave[BACK_U][YAW]);
  initial_back_yaw[BACK_LOWER] := abs(sensor_value_ave[BACK_L][YAW]);
end;

function OwasCalc(load : integer): string;
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
begin
  bOwasLegs  := OwasLegs(sensor_value[LEG_RIGHT_U][ROLL],
                         sensor_value[LEG_RIGHT_L][ROLL],
                         sensor_value[LEG_LEFT_U][ROLL],
                         sensor_value[LEG_LEFT_L][ROLL],
                         movesense_value[LEG_RIGHT_RMOVE],
                         movesense_value[LEG_RIGHT_PMOVE],
                         movesense_value[LEG_LEFT_RMOVE] ,
                         movesense_value[LEG_LEFT_PMOVE] );

  bOwasLoad  := OwasLoad(load);

  bOwasBack  := OwasBack(sensor_value[BACK_U][ROLL],
                         sensor_value[BACK_U][PITCH],
                         sensor_value[BACK_U][YAW],
                         sensor_value[BACK_L][ROLL],
                         sensor_value[BACK_L][PITCH],
                         sensor_value[BACK_L][YAW]);

  bOwasArms  := OwasArms(sensor_value[ARM_RIGHT][ROLL],
                         sensor_value[ARM_RIGHT][PITCH],
                         sensor_value[ARM_LEFT][ROLL],
                         sensor_value[ARM_LEFT][PITCH] );

  bColumn    := ((bOwasLegs - 1) * 3) + bOwasLoad;
  bRow	     := ((bOwasBack - 1) * 3) + bOwasArms;
  bOwasValue := OWAS_TABLE[bRow - 1][bColumn - 1];

  sOwasResult :=  IntToStr(bOwasValue)
                  + ',' + IntToStr(bOwasBack)
                  + ',' + IntToStr(bOwasArms)
                  + ',' + IntToStr(bOwasLegs)
                  + ',' + IntToStr(bOwasLoad);

  for index := 1 to DEVICE_COUNT do
  begin
    sOwasResult := sOwasResult + ',' + inttostr(sensor_value[index][ROLL])
                               + ',' + inttostr(sensor_value[index][PITCH])
                               + ',' + inttostr(sensor_value[index][YAW]);
  end;

  result := sOwasResult + ',endl';
end;

function OwasCalcAve(load : integer): string;
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
begin
  bOwasLegs  := OwasLegs(sensor_value_ave[LEG_RIGHT_U][ROLL],
                         sensor_value_ave[LEG_RIGHT_L][ROLL],
                         sensor_value_ave[LEG_LEFT_U][ROLL],
                         sensor_value_ave[LEG_LEFT_L][ROLL],
                         movesense_value[LEG_RIGHT_RMOVE],
                         movesense_value[LEG_RIGHT_PMOVE],
                         movesense_value[LEG_LEFT_RMOVE] ,
                         movesense_value[LEG_LEFT_PMOVE] );

  bOwasLoad  := OwasLoad(load);

  bOwasBack  := OwasBack(sensor_value_ave[BACK_U][ROLL],
                         sensor_value_ave[BACK_U][PITCH],
                         sensor_value_ave[BACK_U][YAW],
                         sensor_value_ave[BACK_L][ROLL],
                         sensor_value_ave[BACK_L][PITCH],
                         sensor_value_ave[BACK_L][YAW]);

  bOwasArms  := OwasArms(sensor_value_ave[ARM_RIGHT][ROLL],
                         sensor_value_ave[ARM_RIGHT][PITCH],
                         sensor_value_ave[ARM_LEFT][ROLL],
                         sensor_value_ave[ARM_LEFT][PITCH] );

  bColumn    := ((bOwasLegs - 1) * 3) + bOwasLoad;
  bRow	     := ((bOwasBack - 1) * 3) + bOwasArms;
  bOwasValue := OWAS_TABLE[bRow - 1][bColumn - 1];

  sOwasResult :=  IntToStr(bOwasValue)
                  + ',' + IntToStr(bOwasBack)
                  + ',' + IntToStr(bOwasArms)
                  + ',' + IntToStr(bOwasLegs)
                  + ',' + IntToStr(bOwasLoad);

  for index := 1 to DEVICE_COUNT do
  begin
    sOwasResult := sOwasResult + ',' + inttostr(sensor_value_ave[index][ROLL])
                               + ',' + inttostr(sensor_value_ave[index][PITCH])
                               + ',' + inttostr(sensor_value_ave[index][YAW]);
  end;

  result := sOwasResult + ',endl';
end;

function OwasBack(bBackRoll:integer; bBackPitch:integer; bBackYaw:integer;
                  bBack2Roll:integer; bBack2Pitch:integer; bBack2Yaw:integer): integer;
var
  bretval, bresult : integer;
  bUpperYaw, bLowerYaw : integer;
begin
  bRetVal := 1;

  bBackRoll := abs(bBackRoll);
  bBackPitch := abs(bBackPitch);

  if (bBackRoll > back_bent_level) or (bBackPitch > back_bent_level) then
  begin
    bRetVal := bRetVal + 1;
  end;                                   

  bUpperYaw := abs(abs(bBackYaw) - initial_back_yaw[BACK_UPPER]);
  bLowerYaw := abs(abs(bBack2Yaw) - initial_back_yaw[BACK_LOWER]);

  if bUpperYaw > bLowerYaw  then
  begin
    bresult := bUpperYaw - bLowerYaw;
  end else
  begin
    bresult := bLowerYaw - bUpperYaw;
  end;

  if bresult > back_twist_level then
  begin
    bRetVal := bRetVal + 2;
  end;

  result := bRetVal;
end;

function OwasArms(bRightArmRoll:integer; bRightArmPitch:integer; bLeftArmRoll:integer; bLeftArmPitch:integer): integer;
var
  bretval : integer;
begin
  bRetVal := 1;

  bLeftArmRoll := abs(bLeftArmRoll);
  bLeftArmPitch := abs(bLeftArmPitch);
  bRightArmRoll := abs(bRightArmRoll);
  bRightArmPitch := abs(bRightArmPitch);

  if((bRightArmRoll > shoulder_level) or (bRightArmPitch > shoulder_level)) then
  begin
    bRetVal := bretval + 1;
  end;

  if((bLeftArmRoll > shoulder_level) or (bLeftArmPitch > shoulder_level)) then
  begin
    bRetVal := bretval + 1;
  end;

  result := bRetVal;
end;

Procedure OwasMoveSenseAdd( leg_right_r : integer;
                            leg_right_p : integer;
                            leg_left_r : integer;
                            leg_left_p : integer);
begin
  if(movesense_sample[LEG_RIGHT_RMOVE][PREVMOVE] > leg_right_r) then
     movesense_sample[LEG_RIGHT_RMOVE][CALCMOVE] := movesense_sample[LEG_RIGHT_RMOVE][CALCMOVE]
                                                  + (movesense_sample[LEG_RIGHT_RMOVE][PREVMOVE] - leg_right_r)
  else
     movesense_sample[LEG_RIGHT_RMOVE][CALCMOVE] := movesense_sample[LEG_RIGHT_RMOVE][CALCMOVE]
                                                  + (leg_right_r - movesense_sample[LEG_RIGHT_RMOVE][PREVMOVE]);
                                                   
  if(movesense_sample[LEG_RIGHT_PMOVE][PREVMOVE] > leg_right_p) then
     movesense_sample[LEG_RIGHT_PMOVE][CALCMOVE] := movesense_sample[LEG_RIGHT_PMOVE][CALCMOVE]
                                                  + (movesense_sample[LEG_RIGHT_PMOVE][PREVMOVE] - leg_right_p)
  else
     movesense_sample[LEG_RIGHT_PMOVE][CALCMOVE] := movesense_sample[LEG_RIGHT_PMOVE][CALCMOVE]
                                                  + (leg_right_p - movesense_sample[LEG_RIGHT_PMOVE][PREVMOVE]);

    if(movesense_sample[LEG_LEFT_RMOVE][PREVMOVE] > leg_left_r) then
     movesense_sample[LEG_LEFT_RMOVE][CALCMOVE] := movesense_sample[LEG_LEFT_RMOVE][CALCMOVE]
                                                 + (movesense_sample[LEG_LEFT_RMOVE][PREVMOVE] - leg_left_r)
  else
     movesense_sample[LEG_LEFT_RMOVE][CALCMOVE] := movesense_sample[LEG_LEFT_RMOVE][CALCMOVE]
                                                 + (leg_left_r - movesense_sample[LEG_LEFT_RMOVE][PREVMOVE]);

  if(movesense_sample[LEG_LEFT_PMOVE][PREVMOVE] > leg_left_p) then
     movesense_sample[LEG_LEFT_PMOVE][CALCMOVE] := movesense_sample[LEG_LEFT_PMOVE][CALCMOVE]
                                                 + (movesense_sample[LEG_LEFT_PMOVE][PREVMOVE] - leg_left_p)
  else
     movesense_sample[LEG_LEFT_PMOVE][CALCMOVE] := movesense_sample[LEG_LEFT_PMOVE][CALCMOVE]
                                                 + (leg_left_p - movesense_sample[LEG_LEFT_PMOVE][PREVMOVE]);

  movesense_sample[LEG_RIGHT_RMOVE][PREVMOVE] := leg_right_r;
  movesense_sample[LEG_RIGHT_PMOVE][PREVMOVE] := leg_right_p;
  movesense_sample[LEG_LEFT_RMOVE][PREVMOVE]  := leg_left_r;
  movesense_sample[LEG_LEFT_pMOVE][PREVMOVE]  := leg_left_p;
end;

function OwasLegs(bRightUpperLegRaw:integer;
                  bRightLowerLegRaw:integer;
                  bLeftUpperLegRaw:integer;
                  bLeftLowerLegRaw:integer;
                  bRightMoveR:integer;
                  bRightMoveP:integer;
                  bLeftMoveR:integer;
                  bLeftMoveP:integer): integer;
var
  bretval          : integer;
  bRightUpperLeg   : integer;
  bRightLowerLeg   : integer;
  bLeftUpperLeg    : integer;
  bLeftLowerLeg    : integer;
  right_upper_val  : integer;
  right_lower_val  : integer;
  left_upper_val   : integer;
  left_lower_val   : integer;
  right_upper_dir  : integer;
  left_upper_dir   : integer;
  right_lower_dir  : integer;
  left_lower_dir   : integer;
  stand_val        : integer = 1;
  bent_val         : integer = 2;
  sit_val          : integer = 3;
  squat_val        : integer = 4;
begin
  bRetVal := 1;

  bRightUpperLeg   := abs(bRightUpperLegRaw );
  bRightLowerLeg   := abs(bRightLowerLegRaw );
  bLeftUpperLeg    := abs(bLeftUpperLegRaw  );
  bLeftLowerLeg    := abs(bLeftLowerLegRaw  );
  bRightMoveR      := abs(bRightMoveR       );
  bRightMoveP      := abs(bRightMoveP       );
  bLeftMoveR       := abs(bLeftMoveR        );
  bLeftMoveP       := abs(bLeftMoveP        );

  right_upper_dir  := DIR_FRONT;
  left_upper_dir   := DIR_FRONT;
  right_lower_dir  := DIR_FRONT;
  left_lower_dir   := DIR_FRONT;

  bRetVal := 0;

  if bRightUpperLegRaw < 0 then right_upper_dir := DIR_BACK; 
  if bRightLowerLegRaw < 0 then right_lower_dir := DIR_BACK;
  if bLeftUpperLegRaw < 0 then left_upper_dir := DIR_BACK;
  if bLeftLowerLegRaw < 0 then left_lower_dir := DIR_BACK;

  right_upper_val := GetLegVal(bRightUpperLeg);
  right_lower_val := GetLegVal(bRightLowerLeg);
  left_upper_val := GetLegVal(bLeftUpperLeg);
  left_lower_val := GetLegVal(bLeftLowerLeg);

  {
  TForm1.Label6.caption := int2str(right_upper_val);
  TForm1.Label7.caption := int2str(right_lower_val);
  TForm1.Label8.caption := int2str(left_upper_val);
  TForm1.Label9.caption := int2str(left_lower_val);
  }

  { Moving }
  if ((bRightMoveR > movesense_level) or (bRightMoveP > movesense_level))
    and ((bLeftMoveR > movesense_level) or (bLeftMoveP > movesense_level))

    then bRetVal := 7

  { Sit }
  else if ((right_upper_val = sit_val) and (left_upper_val = sit_val))
      and (((right_lower_val < sit_val) and (left_lower_val < sit_val))
          or ((right_lower_dir = DIR_FRONT) and (left_lower_dir = DIR_FRONT)))

     then bretval := 1       

  { Standing }
  else if ((right_upper_val = stand_val) and (left_upper_val = stand_val))
      and ((right_lower_val = stand_val) and (left_lower_val = stand_val))

     then bretval := 2

  { Stand with 1 leg }
  else if  ((right_upper_val = stand_val) and (right_lower_val = stand_val))
       xor ((left_upper_val = stand_val) and (left_lower_val = stand_val))

       then bretval := 3

  { Squat or Stand with both legs bent }
  else if (((right_upper_val > stand_val) and (left_upper_val > stand_val))
          and ((right_upper_val <= squat_val) and (left_upper_val <= squat_val)))

     then begin
       if ((right_lower_val < sit_val) and (left_lower_val < sit_val))
            then bretval := 4

       { Sit }
       else if((right_lower_val >= sit_val) and (left_lower_val >= sit_val))
            then bretval := 1

       { 1 leg squat }
       else
           bretval := 5;

     end

  { standing with 1 bent leg }
  else if ((right_lower_val < sit_val) or (left_lower_val < sit_val))

       then bretval := 5

  { Kneeling }   
  else if ((right_lower_val >= sit_val) and (left_lower_val >= sit_val))
      and ((right_lower_dir = DIR_BACK) and (left_lower_dir = DIR_BACK))

     then bretval := 6;


  result := bRetVal;

end;

function GetLegVal(degree : integer) : integer;
begin
  if CompareInRange(degree, leg_stand_level, leg_bent_level) then
    result := 1
  else if CompareInRange(degree, leg_bent_level, leg_sit_level) then
    result := 2
  else if CompareInRange(degree, leg_sit_level, leg_squat_level) then
    result := 3
  else if CompareInRange(degree, leg_squat_level, leg_max_level) then
    result := 4
  else
    result := 0;
end;

function OwasLoad(nUserLoad:integer): integer;
var
  bretval : integer;
begin
  bRetVal := 1;

  if((nUserLoad >= load1_level) and (nUserLoad < load2_level)) then
  begin
    bRetVal := 2;
  end
  else if (nUserLoad >= load2_level) then
  begin
    bRetVal := 3;
  end;

  result := bRetVal;

end;

function CompareInRange(range : integer; limit1 : integer; limit2 : integer) : boolean;
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

end.

