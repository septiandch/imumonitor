#ifndef PROTOTYPES_H
#define PROTOTYPES_H

#include <Arduino.h>
#include <ESP8266HTTPClient.h>
#include "constants.h"

/*---------------------------------------*/
/* Common                                */
/*---------------------------------------*/

void	str2ip(const char ipstr[], int ipaddr[]);
int		volt2percentage(int vBatt);
String	i2cScan();
void    jsonDocPrint(WiFiClient &client);


/*---------------------------------------*/
/* GPIO                                  */
/*---------------------------------------*/

void	gpio_pinInit();
void	gpio_i2cInit();
void    gpio_led(byte state);
void	gpio_ledBlink(eNODESTATE mode);
int		gpio_battCheck();


/*---------------------------------------*/
/* Timer                                 */
/*---------------------------------------*/

void	timer_init(void (&callBackFunc)(), int period);
void	timer_update();


/*---------------------------------------*/
/* Sensors                               */
/*---------------------------------------*/

void	sensor_init();
void	sensor_calibGyro();
void	sensor_calibCompass();
void	sensor_getData(int *roll, int *pitch, int *yaw, long *rollMov, long *pitchMov);
bool	sensor_checkForUpdates();
bool	sensor_checkConnection();


/*---------------------------------------*/
/* WiFi                                  */
/*---------------------------------------*/

void	    wifi_init();
void	    wifi_connect();
void        wifi_reconnect();
void	    wifi_disconnect();
void	    wifi_checkUpdateRequest();
eNODESTATE	wifi_getStatus();


/*---------------------------------------*/
/* WebServer                             */
/*---------------------------------------*/

void	webserver_init();
void	webserver_checkClientRequest();
void	webserver_commandCheck(String cmd);
String  webserver_prePostRequest(WiFiClient &client, String sNodeId);
String	webserver_getRequest(String sNodeId, int nRoll, int nPitch, int nYaw, long dwRollMov, long dwPitchMov, byte bBatt, String others);


/*---------------------------------------*/
/* JSON                                  */
/*---------------------------------------*/

void jsonPrintStart(WiFiClient &s);
void jsonPrintEnd(WiFiClient &s);
void jsonPrintItem(WiFiClient &s, String name, int value);
void jsonPrintArray(WiFiClient &s, String name, int* ptr, int size);
void jsonPrintArrayCustom(WiFiClient &s, String name, int* ptr, int start, int size);


#endif  /* PROTOTYPES_H */