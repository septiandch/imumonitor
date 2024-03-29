#include "headers.h"
#include <ArduinoJson.h>

void mainEventCheck();
void substract(long *dwVal, int substractor);
void commandCheck(String cmd);
void dataArrayAppend(int roll, int pitch, int yaw);
void dataArrayClear();
void jsonDocCreate();

long dwTickMainCounter = 0;

eNODESTATE eNodeState = eNODE_DISCONNECTED;
bool bDataSent = false;
bool bTickFlag = false;
bool bInitFlag = true;
bool bRetryFlag = true;
byte bRetryCount = 0;

#ifdef ESP32_DEF
byte bAlertCount = 0;
bool bAlertState = 0;
unsigned long ulAlertTimer = millis();
#endif

byte bConnRetry = 0;
int nTickLimit = TICK_DEFAULT;

// Battery Values
int nVolt	= 0;
byte bBatt	= 0;

// Rotation Values
int nPitch		= 0;
int nRoll		= 0;
int nYaw		= 0;
long dwRollMov 	= 0; 
long dwPitchMov	= 0;

// Rotation Value Data Array
const int MAX_DATA = 500;
int nDataMax = MAX_DATA;
int nDataCount = 0;
int nPitchData[MAX_DATA];
int nRollData[MAX_DATA];
int nYawData[MAX_DATA];
String strDataArray;
const unsigned long SAMPLING_TIME = 5000;
unsigned long dwSamplingTimer;

// JSON Document
StaticJsonDocument<30000> jsondoc;
StaticJsonDocument<200> notreadydoc;
bool bJsonDataReady = false;

void setup()
{
	String nodeid = NODEID;
	long startupdelay = 1000;
	
	notreadydoc["status"] = "Not Ready";

	gpio_pinInit();
	
	delay(startupdelay);
	digitalWrite(LED_BUILTIN, HIGH);

	timer_init(mainEventCheck, 10);

	wifi_init();
}

void loop()
{
	eNodeState = wifi_getStatus();
	wifi_checkUpdateRequest();
	webserver_checkClientRequest();

	if(eNodeState == eNODE_CONNECTED)
	{
		if(!bDataSent && bTickFlag)
		{
#if 0
			if(bInitFlag)
			{
				commandCheck(webserver_prePostRequest(NODEID));
				bInitFlag = false;
			}
			else
#endif
			{	
				commandCheck(webserver_getRequest(NODEID, nRoll, nPitch, nYaw, dwRollMov, dwPitchMov, bBatt, strDataArray));
			}
			
			bTickFlag = false;

			if(!bRetryFlag)
			{
				bDataSent = true;
			}
		}

		bConnRetry = 0;
	}
	else
	{
		if(bTickFlag)
		{
			bDataSent = false;
			bTickFlag = false;
			
			wifi_connect();
			
			if(bConnRetry++ > RETRY_TIMEOUT)
			{
				ESP.restart();
			}
		}
	}	

#ifdef ESP32_DEF
	if((bAlertCount > 0) && (millis() - ulAlertTimer > 1000))
	{
		ulAlertTimer = millis();

		if(bAlertState)
		{
			digitalWrite(PIN_BUZZER, HIGH);
			digitalWrite(PIN_VIBRATOR, HIGH);
			digitalWrite(LED_BUILTIN, HIGH);

			bAlertState = false;
		}
		else
		{
			digitalWrite(PIN_BUZZER, LOW);
			digitalWrite(PIN_VIBRATOR, LOW);
			digitalWrite(LED_BUILTIN, LOW);

			bAlertCount--;
			bAlertState = true;
		}
	}
#endif
	
#if 0
	sensor_getData(&nRoll, &nPitch, &nYaw, &dwRollMov, &dwPitchMov);
	
	if(millis() - dwSamplingTimer > SAMPLING_TIME && !bInitFlag)
	{
		dataArrayAppend(nRoll, nPitch, nYaw);
		dwSamplingTimer = millis();
	}
#endif

	timer_update();
	delay(1);
}

void mainEventCheck(void)
{
	gpio_ledBlink(eNodeState);

	sensor_getData(&nRoll, &nPitch, &nYaw, &dwRollMov, &dwPitchMov);
	dataArrayAppend(nRoll, nPitch, nYaw);

	if( dwTickMainCounter++ > nTickLimit )
	{
		nVolt = gpio_battCheck();
		bBatt = volt2percentage(nVolt);
			
		bTickFlag = true;

		dwTickMainCounter = 0;
	}

#if 0
	substract(&dwRollMov, SUBSTRACTOR);
	substract(&dwPitchMov, SUBSTRACTOR);
#endif
}

void commandCheck(String cmd)
{
	bRetryFlag = false;

	if(cmd.indexOf(CMD_OK) > 0)
	{ 
		bRetryCount = 0;

		nTickLimit = TICK_WAIT;

		dataArrayClear();
		wifi_disconnect();
	}
    else if(cmd.indexOf(CMD_WAIT) > 0 )
	{
		/* wait... */

		bRetryCount = 0;
		nTickLimit = TICK_DEFAULT;
	}
	else if (cmd.indexOf(CMD_CALIBRATE) > 0)
	{
		sensor_calibGyro();
		nTickLimit = TICK_DEFAULT;
		wifi_disconnect();

		bRetryCount = 0;
	}
	else if (cmd.indexOf(CMD_RESTART) > 0)
	{
		ESP.restart();
	}
	else if (cmd.indexOf(CMD_DISCONNECT) > 0)
	{	
		wifi_disconnect();

		bRetryCount = 0;
	}
	else
	{
#if 0
		if(bRetryCount++ < 3)
		{
			bRetryFlag = true;
			nTickLimit = TICK_RETRY;
		}
		else
		{
			nTickLimit = TICK_DEFAULT;
			
			wifi_disconnect();
		}
#endif
	}

	if(cmd.indexOf("delay=") >= 0)
	{
		int index[] = {	cmd.indexOf("delay="),
						cmd.indexOf(" seconds</p>"),
						};
		nTickLimit = (cmd.substring(index[0] + 6, index[1] - 1).toInt()) * 100;
	}
}

void dataArrayAppend(int roll, int pitch, int yaw)
{
#if 0
	if(nDataCount < MAX_DATA)
	{
		nRollData[nDataCount] = roll;
		nPitchData[nDataCount] = pitch;
		nYawData[nDataCount] = yaw;

		strDataArray += "&rol" + String(nDataCount ,DEC) + "=" + String(roll, DEC) + 
						"&pit" + String(nDataCount ,DEC) + "=" + String(pitch, DEC) +
						"&yaw" + String(nDataCount ,DEC) + "=" + String(yaw, DEC);

		nDataCount ++;
	}
#else
	nRollData[nDataCount] = roll;
	nPitchData[nDataCount] = pitch;
	nYawData[nDataCount] = yaw;

	nDataCount++;
	if(nDataCount >= MAX_DATA)
	{
		jsonDocCreate();
		nDataCount = 0;
	}
#endif
}

void dataArrayClear()
{
	byte i;

	for(i = 0; i < MAX_DATA; i++)
	{
		nRollData[i] = 0;
		nPitchData[i] = 0;
		nYawData[i] = 0;
	}

	strDataArray = "";
	nDataCount = 0;
}

void substract(long *dwVal, int substractor)
{
	if(*dwVal > 0)
	{
		*dwVal -= substractor;
	}

	if(*dwVal < 0)
	{
		*dwVal = 0;
	}
}

void jsonDocCreate()
{
	int i;

	jsondoc.clear();

	jsondoc["id"] = NODEID;
	jsondoc["batt"] = bBatt;

	JsonArray datar = jsondoc.createNestedArray("roll");
	for(i = nDataCount - 1; i >= 0; i--)
	{
		datar.add(nRollData[i]);
	}
	for(i = MAX_DATA - 1; i > nDataCount; i--)
	{
		datar.add(nRollData[i]);
	}

	JsonArray datap = jsondoc.createNestedArray("pitch");
	for(i = nDataCount - 1; i >= 0; i--)
	{
		datap.add(nPitchData[i]);
	}
	for(i = MAX_DATA - 1; i > nDataCount; i--)
	{
		datap.add(nPitchData[i]);
	}

	JsonArray datay = jsondoc.createNestedArray("yaw");
	for(i = nDataCount - 1; i >= 0; i--)
	{
		datay.add(nYawData[i]);
	}
	for(i = MAX_DATA - 1; i > nDataCount; i--)
	{
		datay.add(nYawData[i]);
	}

	jsondoc["rmov"] = (dwRollMov);
	jsondoc["pmov"] = (dwPitchMov);

	bJsonDataReady = true;
}



void jsonDocPrint(WiFiClient &client)
{
	if(bJsonDataReady)
	{
		serializeJsonPretty(jsondoc, client);

		bJsonDataReady = false;
	}
	else
	{
		serializeJsonPretty(notreadydoc, client);
	}
}