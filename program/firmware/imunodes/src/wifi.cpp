#include <Arduino.h>
#include <ESP8266WiFi.h>
#include "definitions.h"
#include "prototypes.h"
#include "EasyOta.h"

IPAddress IP(DEFAULT_IP);
IPAddress NETMASK(DEFAULT_NETMSK);
IPAddress NETWORK(DEFAULT_NETWRK);
IPAddress DNS(DEFAULT_DNS);

void wifi_init()
{
	wifi_connect();

	webserver_init();

	EasyOta.setup();
}

void wifi_connect()
{
	WiFi.mode(WIFI_STA);
	WiFi.setSleepMode(WIFI_NONE_SLEEP);
	WiFi.begin(WIFI_NAME, WIFI_PW);

	WiFi.waitForConnectResult(WIFI_TIMEOUT);

	delay(1000);

#	ifndef IPADDR
  	WiFi.config(IP, NETWORK, NETMASK, DNS);
#	else
	int ip[4];

	str2ip(IP_ADDR, ip);
	WiFi.config(IPAddress(ip[0], ip[1], ip[2], ip[3]), NETWORK, NETMASK, DNS);
#	endif
}

void wifi_reconnect()
{
	WiFi.reconnect();
}

void wifi_disconnect()
{
	WiFi.disconnect();
}

/*
int nBatt	= 0;
byte bBattPercentage = 0;

unsigned long dwMillis = 0; 
unsigned long dwTrgMillis = 0; 
uint8_t bConnCount = 0;

bool bConnState = false;
bool bLedState = false;
uint8_t	bRetryCount = 0;\

int wifi_getStatus()
{
	if(WiFi.status() == WL_CONNECTED)
	{
		bConnState = true;

		if(millis() - dwMillis > dwTrgMillis)
		{
			if(bLedState)
			{
				digitalWrite(LED_BUILTIN, HIGH);
				dwTrgMillis = 2000;
				bLedState = false;

				bRetryCount = 0;
				bConnCount++;

				if(bConnCount == 2)
				{
					nBatt = gpio_battCheck();
					bBattPercentage = volt2percentage(nBatt);

					//command = webserver_getRequest();
				}

				if(bConnCount > 6)
				{
					bConnCount = 0;

					//dwRollMovement = 0;
					//dwPitchMovement = 0;

					WiFi.disconnect();
				}
			}
			else
			{
				digitalWrite(LED_BUILTIN, LOW);
				dwTrgMillis = 10;
				bLedState = true;
			}

			dwMillis = millis();
		}
	}
	else
	{
		if(millis() - dwMillis > dwTrgMillis)
		{
			if(bLedState)
			{
				digitalWrite(LED_BUILTIN, HIGH);
				dwTrgMillis = 500;
				bLedState = false;

				if(bRetryCount >= 40)
				{
					bRetryCount = 0;
					ESP.restart();
				}
				else if(bRetryCount >= 20)
				{
					if (bConnState) 
					{
						wifi_connect();
					}
					else
					{
						wifi_connect();
					}
				}
				bRetryCount++;
			}
			else
			{
				digitalWrite(LED_BUILTIN, LOW);
				dwTrgMillis = 10;
				bLedState = true;
			}

			dwMillis = millis();
		}		
	}

	return WiFi.status();
}
*/

eNODESTATE wifi_getStatus()
{
	eNODESTATE eRetVal = eNODE_DISCONNECTED;
	byte status =  WiFi.status();
	
	switch(status)
	{
		case WL_CONNECTED :
			eRetVal = eNODE_CONNECTED;
			break;

		default :
			eRetVal = eNODE_DISCONNECTED;
			break;
	}
	 
	return eRetVal;
}

void wifi_checkUpdateRequest()
{
	EasyOta.checkForUpload();
}