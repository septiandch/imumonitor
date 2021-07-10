#ifndef VARIABLES_H
#define VARIABLES_H

// Battery Values
extern int nVolt;
extern byte bBatt;

// Data Parameters
extern int nDataCount;
extern int nDataMax;

// Rotation values
extern int nPitch;
extern int nRoll;
extern int nYaw;
extern int nPitchData[];
extern int nRollData[];
extern int nYawData[];
extern long dwRollMov; 
extern long dwPitchMov;

#ifdef ESP32_DEF
extern byte bAlertCount;
extern bool bAlertState;
extern unsigned long ulAlertTimer;
#endif

#endif  /* VARIABLES_H */