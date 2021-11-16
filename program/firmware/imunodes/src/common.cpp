#include <Wire.h>
#include "prototypes.h"
#include "constants.h"

void str2ip(const char ipstr[], int ipaddr[])
{
	int index = 0;
	char str[16];
	char * pChar;

	strcpy(str, ipstr);
	pChar = strtok(str, ".");
	
	while (pChar != NULL)
	{
		ipaddr[index] = atoi(pChar);
		index++;

		pChar = strtok (NULL, ".");
	}
}

String i2cScan()
{
	String sScanResult = "";
	byte error, address;
	int nDevices;

	nDevices = 0;
	for(address = 0; address < 127; address++ )
	{
		// The i2c_scanner uses the return value of
		// the Write.endTransmisstion to see if
		// a device did acknowledge to the address.
		Wire.beginTransmission(address);
		error = Wire.endTransmission();

		if (error == 0)
		{
			sScanResult = sScanResult + String(address, HEX) + ", ";
 
			nDevices++;
		}
	}

	if (nDevices == 0)
	{
	  sScanResult = "No I2C devices found";
	}

	return sScanResult;
}

int volt2percentage(int vBatt)
{
	int i;
	byte len = sizeof(nBattVolt) / 2;

	for(i = 0; i < (len - 1); i++)
	{
		if(vBatt >= nBattVolt[i])
		{
			break;
		}
	}

	return bBattLevel[i];
}