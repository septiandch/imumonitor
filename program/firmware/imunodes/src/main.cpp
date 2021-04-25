#include "headers.h"

void mainEventCheck();
void substract(long *dwVal, int substractor);
void commandCheck(String cmd);
void dataArrayAppend(int roll, int pitch, int yaw);
void dataArrayClear();

long dwTickMainCounter = 0;

eNODESTATE eNodeState = eNODE_DISCONNECTED;
bool bDataSent = false;
bool bTickFlag = false;
bool bInitFlag = true;
bool bRetryFlag = true;
byte bRetryCount = 0;

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
const byte MAX_DATA = 10;
byte nDataCount = 0;
int nPitchData[MAX_DATA];
int nRollData[MAX_DATA];
int nYawData[MAX_DATA];
String strDataArray;
const unsigned long SAMPLING_TIME = 5000;
unsigned long dwSamplingTimer;

void setup()
{
	String nodeid = NODEID;
	long startupdelay = nodeid.toInt() * 5000;
	delay(startupdelay);

	gpio_pinInit();
	
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
			if(bInitFlag)
			{
				commandCheck(webserver_prePostRequest(NODEID));
				bInitFlag = false;
			}
			else
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
	
	sensor_getData(&nRoll, &nPitch, &nYaw, &dwRollMov, &dwPitchMov);
	
	if(millis() - dwSamplingTimer > SAMPLING_TIME && !bInitFlag)
	{
		dataArrayAppend(nRoll, nPitch, nYaw);
		dwSamplingTimer = millis();
	}

	timer_update();
	delay(1);
}

void mainEventCheck(void)
{
	gpio_ledBlink(eNodeState);

	if( dwTickMainCounter++ > nTickLimit )
	{
		nVolt = gpio_battCheck();
		bBatt = volt2percentage(nVolt);
			
		bTickFlag = true;

		dwTickMainCounter = 0;
	}

	substract(&dwRollMov, SUBSTRACTOR);
	substract(&dwPitchMov, SUBSTRACTOR);
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
}

void dataArrayClear()
{
	byte i;

	for(i = 0; i < MAX_DATA; i++)
	{
		nRollData[nDataCount] = 0;
		nPitchData[nDataCount] = 0;
		nYawData[nDataCount] = 0;
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