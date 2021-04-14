#include "headers.h"

void mainEventCheck();
void substract(long *dwVal, int substractor);

long dwTickMainCounter = 0;

eNODESTATE eNodeState = eNODE_DISCONNECTED;
bool bDataSent = false;
bool bConnFlag = false;
bool bInitFlag = false;
byte bConnRetry = 0;

// Battery Values
int nVolt	= 0;
byte bBatt	= 0;

// Rotation Values
int nPitch		= 0;
int nRoll		= 0;
int nYaw		= 0;
long dwRollMov 	= 0; 
long dwPitchMov	= 0;

void setup()
{
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
		if(!bDataSent)
		{
			if(bInitFlag)
			{
				webserver_postRequest(NODEID, nRoll, nPitch, nYaw, dwRollMov, dwPitchMov, bBatt);

			}
			else
			{	
				webserver_prePostRequest(NODEID);

				bInitFlag = true;
			}
			
			bDataSent = true;
		}

		if(bConnFlag)
		{
			wifi_disconnect();
			bConnFlag = false;
			bConnRetry = 0;
		}
	}
	else
	{
		bDataSent = false;

		if(bConnFlag)
		{
			wifi_connect();
			bConnFlag = false;
			
			if(bConnRetry++ > RETRY_TIMEOUT)
			{
				ESP.restart();
			}
		}
	}	
	
	sensor_getData(&nRoll, &nPitch, &nYaw, &dwRollMov, &dwPitchMov);

	timer_update();
	delay(1);
}

void mainEventCheck(void)
{
	gpio_ledBlink(eNodeState);

	if( dwTickMainCounter++ > TICK_TIMEOUT )
	{
		nVolt = gpio_battCheck();
		bBatt = volt2percentage(nVolt);
			
		bConnFlag = true;

		dwTickMainCounter = 0;
	}

	substract(&dwRollMov, SUBSTRACTOR);
	substract(&dwPitchMov, SUBSTRACTOR);
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