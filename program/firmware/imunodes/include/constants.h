#ifndef CONSTANTS_H
#define CONSTANTS_H

#include <Arduino.h>

#ifdef WIFINAME
const char WIFI_NAME[] = WIFINAME;
const char WIFI_PW[] = WIFIPASS;
#else
const char WIFI_NAME[] = "ESP32 BLE";
const char WIFI_PW[] = "12345678";
#endif

#ifdef IPADDR
const char IP_ADDR[] = IPADDR;
#endif

const long timeoutTime = 2000;

const uint8_t bBattLevel[] =  {100, 95,  90,  85,  80,  75,  70,  65,  60,  55,  50,  45,  40,  35,  30,  25,  20,  15,  10,  5,   0  };
const uint16_t nBattVolt[]  = {420, 415, 411, 408, 402, 398, 395, 391, 387, 385, 384, 382, 380, 379, 377, 375, 373, 371, 369, 361, 327};

//								Disonnected,	Connected,		Low Power
const int nDelayPatternOn[]		= {	1, 			1,				20};
const int nDelayPatternOff[]	= {	50,			200,			10};

enum eNODESTATE
{
    eNODE_DISCONNECTED = 0,
    eNODE_CONNECTED,
    eNODE_BATTERYLOW,
};

#endif  /* CONSTANTS_H */