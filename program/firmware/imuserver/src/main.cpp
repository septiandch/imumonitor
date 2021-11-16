#include <Arduino.h>
#include <WiFi.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// See the following for generating UUIDs:
// https://www.uuidgenerator.net/
#define SERVICE_UUID           "6E400001-B5A3-F393-E0A9-E50E24DCCA9E" // UART service UUID
#define CHARACTERISTIC_UUID_RX "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
#define CHARACTERISTIC_UUID_TX "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"

#define PIN_BUZZER		12
#define PIN_VIBRATOR	13

enum eNodeIdEnum
{
	eID_OWAS = 0,
	eID_BACK,
	eID_RARM,
	eID_LARM,
	eID_RULEG,
	eID_RLLEG,
	eID_LULEG,
	eID_LLLEG,
	eID_SIZE
};

bool bNodeFlag[eID_SIZE];
long dwNodeTimeGap[eID_SIZE];
bool bDebugState = false;

enum eNodeEnum
{
	eDATA_ID = 0,
	eDATA_ROL,
	eDATA_PIT,
	eDATA_YAW,
	eDATA_BAT,
	eDATA_MVR,
	eDATA_MVP,
	eDATA_SIZE
};

enum eOwasEnum
{
	eOWAS_ID = 0,
	eOWAS_BACK,
	eOWAS_ARMS,
	eOWAS_LEGS,
	eOWAS_LOAD,
	eOWAS_LEVEL,
	eOWAS_SIZE
};

const byte bOwasTable[12][21] =
{
	{	1, 1, 1,	1, 1, 1,	1, 1, 1,	2, 2, 2,	2, 2, 2,	1, 1, 1,	1, 1, 1	},
	{	1, 1, 1,	1, 1, 1,	1, 1, 1,	2, 2, 2,	2, 2, 2,	1, 1, 1,	1, 1, 1	},
	{	1, 1, 1,	1, 1, 1,	1, 1, 1,	2, 2, 2,	2, 2, 2,	1, 1, 1,	1, 1, 1	},

	{	2, 2, 3,	2, 2, 3,	2, 2, 3,	3, 3, 3,	3, 3, 3,	2, 2, 2,	2, 3, 3	},
	{	2, 2, 3,	2, 2, 3,	2, 3, 3,	3, 4, 4,	3, 4, 4,	3, 3, 4,	2, 3, 4	},
	{	3, 3, 4,	2, 2, 3,	3, 3, 3,	3, 4, 4,	4, 4, 4,	4, 4, 4,	2, 3, 4	},

	{	1, 1, 1,	1, 1, 1,	1, 1, 2,	3, 3, 3,	4, 4, 4,	1, 1, 1,	1, 1, 1	},
	{	2, 2, 3,	1, 1, 1,	1, 1, 2, 	4, 4, 4,	4, 4, 4,	3, 3, 3,	1, 1, 1	},
	{	2, 2, 3,	1, 1, 1,	2, 3, 3,	4, 4, 4,	4, 4, 4,	4, 4, 4,	1, 1, 1	},

	{	2, 3, 3,	2, 2, 3,	2, 2, 3,	4, 4, 4,	4, 4, 4,	4, 4, 4,	2, 3, 4	},
	{	3, 3, 4,	2, 3, 4,	3, 3, 4,	4, 4, 4,	4, 4, 4,	4, 4, 4,	2, 3, 4	},
	{	4, 4, 4,	2, 3, 4,	3, 3, 4,	4, 4, 4,	4, 4, 4,	4, 4, 4,	2, 3, 4	},
};

enum eLimitSettingEnum
{
	eLIM_ARMS = 0,
	eLIM_BACK_ROLL,
	eLIM_BACK_PITCH,
	eLIM_LOAD_1,
	eLIM_LOAD_2,
	eLIM_LEG_STAND,
	eLIM_LEG_BENT,
	eLIM_LEG_SIT,
	eLIM_LEG_SQUAT,
	eLIM_LEG_MOVE,
	eLIM_LEG_MAX,
	eLIM_SIZE
};

// Replace with your network credentials
const char ssid[]     = "ESP32 BLE";
const char password[] = "12345678";

// BLE Update Timer
const unsigned long ulNodeDelay = 200;
const unsigned long ulWarningDelay = 3000;
unsigned long ulMillis = 0;
unsigned long ulWarningMillis = 0;
int nodeIndex = 0;

bool bDataReadyFlag = false;
bool bWarningFlag = false;
String sNodeData;

int nLimitSettings[eLIM_SIZE];

int nLimitDefaults[] = 
{
	90,		/* eLIM_ARMS		*/
	20,		/* eLIM_BACK_ROLL	*/
	20,		/* eLIM_BACK_PITCH	*/
	10,		/* eLIM_LOAD_1		*/
	20,		/* eLIM_LOAD_2		*/
	0,		/* eLIM_LEG_STAND	*/
	20,		/* eLIM_LEG_BENT	*/
	60,		/* eLIM_LEG_SIT		*/
	120,	/* eLIM_LEG_SQUAT	*/
	130,	/* eLIM_LEG_MOVE	*/
	180,	/* eLIM_LEG_MAX		*/
};

/*
String strLimitSetting[]
{
	"eLIM_ARMS",
	"eLIM_BACK_ROLL",
	"eLIM_BACK_PITCH",
	"eLIM_LOAD_1",
	"eLIM_LOAD_2",
	"eLIM_LEG_STAND",
	"eLIM_LEG_BENT",
	"eLIM_LEG_SIT",
	"eLIM_LEG_SQUAT",
	"eLIM_LEG_MOVE",
	"eLIM_LEG_MAX",
	"eLIM_SIZE"
};
*/

bool bInitialFlag = true;
int queue_num = 1;
unsigned long queue_last_gap = 0;
const int queue_initial_delay = 60;
const int delay_pattern[] = {0, 5, 10, 15, 20, 25, 30, 35};

const int initial_delay = 60;
const int normal_delay = 20;

int queueGetDelayTime(int id)
{
	int gap = 0;
	int retval = 0;

	gap = ((int)((millis() - queue_last_gap) / 1000)) - delay_pattern[id];

	retval = delay_pattern[queue_num] + gap;

	if(bInitialFlag)
	{
		retval += queue_initial_delay;
	}

	Serial.println("------------ >>>>>>>");
	Serial.print("Delay Time : ");
	Serial.println(retval);
	Serial.println("------------ >>>>>>>");
	
	if(queue_num++ >= 7)
	{
		queue_num = 1;
	}

	queue_last_gap = millis();

	return retval;
}

String stringParse(String data, char separator, int index)
{
	int i = 0;
	int found = 0;
	int strIndex[] = {0, -1};
	int maxIndex = data.length()-1;
 
 	for(i = 0; i <= maxIndex && found <= index; i++)
	{
		if(data.charAt(i) == separator || i == maxIndex)
		{
			found++;
			strIndex[0] = strIndex[1]+1;
			strIndex[1] = (i == maxIndex) ? i+1 : i;
		}
	}

	return found>index ? data.substring(strIndex[0], strIndex[1]) : "";
}

// Set web server port number to 80
WiFiServer server(80);

BLECharacteristic *pCharacteristic;
bool bleDeviceConnected = false;

int nUserLoad = 5;
String nodeData[eID_SIZE][eDATA_SIZE];
String nodeDataArray[eID_SIZE][3 * 10];

void limitSettingInit()
{
	int i;

	for(i = 0; i < eLIM_SIZE; i++)
	{
		nLimitSettings[i] = nLimitDefaults[i];
	}
}

void limitSettingCheck()
{
	/*
	int i;

	for(i = 0; i < eLIM_SIZE; i++)
	{
		Serial.print(strLimitSetting[i]);
		Serial.print(" : ");
		Serial.println(nLimitSettings[i]);
	}
	*/
}

class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      bleDeviceConnected = true;
    };

    void onDisconnect(BLEServer* pServer) {
      bleDeviceConnected = false;
    }
};

class MyCallbacks: public BLECharacteristicCallbacks {
	void onWrite(BLECharacteristic *pCharacteristic) {
		std::string rxValue = pCharacteristic->getValue();

		String strRxData;

		if (rxValue.length() > 0)
		{
			for (int i = 0; i < rxValue.length(); i++)
			{
				strRxData += rxValue[i];
			}
			
			/*
			Serial.println("\n\r\n\r*********");

			Serial.print("Received Value: ");
			Serial.println(strRxData);

			Serial.println("*********\n\r\n\r");
			*/
			
			if(strRxData.indexOf("user") >= 0)
			{
				strRxData = strRxData.substring(5, strRxData.length());

				nUserLoad = stringParse(strRxData, ',', 3).toInt();
				
				/*
				Serial.print("\n\rUser Load : ");
				Serial.println(nUserLoad);
				*/
			}
			else if(strRxData.indexOf("setting") >= 0)
			{
				strRxData = strRxData.substring(8, strRxData.length());

				nLimitSettings[eLIM_ARMS] = stringParse(strRxData, ',', eLIM_ARMS).toInt();
				nLimitSettings[eLIM_BACK_ROLL] = stringParse(strRxData, ',', eLIM_BACK_ROLL).toInt();
				nLimitSettings[eLIM_BACK_PITCH] = stringParse(strRxData, ',', eLIM_BACK_PITCH).toInt();
				nLimitSettings[eLIM_BACK_PITCH] = stringParse(strRxData, ',', eLIM_BACK_PITCH).toInt();
				nLimitSettings[eLIM_BACK_PITCH] = stringParse(strRxData, ',', eLIM_BACK_PITCH).toInt();
				nLimitSettings[eLIM_LOAD_1] = stringParse(strRxData, ',', eLIM_LOAD_1).toInt();
				nLimitSettings[eLIM_LOAD_2] = stringParse(strRxData, ',', eLIM_LOAD_2).toInt();
				nLimitSettings[eLIM_LEG_STAND] = stringParse(strRxData, ',', eLIM_LEG_STAND).toInt();
				nLimitSettings[eLIM_LEG_BENT] = stringParse(strRxData, ',', eLIM_LEG_BENT).toInt();
				nLimitSettings[eLIM_LEG_SIT] = stringParse(strRxData, ',', eLIM_LEG_SIT).toInt();
				nLimitSettings[eLIM_LEG_SQUAT] = stringParse(strRxData, ',', eLIM_LEG_SQUAT).toInt();
				nLimitSettings[eLIM_LEG_MOVE] = stringParse(strRxData, ',', eLIM_LEG_MOVE).toInt();
				nLimitSettings[eLIM_LEG_MAX] = nLimitDefaults[eLIM_LEG_MAX];

				limitSettingCheck();

				digitalWrite(PIN_BUZZER, HIGH);
				delay(100);
				digitalWrite(PIN_BUZZER, LOW);
			}
		}
    }
};

void intToChar(int value, char * str)
{
	str[0] = '0' + (int)(value/100);
	str[1] = '0' + ((int)(value/10) % 10);
	str[2] = '0' + ((int)(value) % 10);
	str[3] = ',';
}

void nodeFlagReset()
{
	byte i;

	for(i = 0; i < eID_SIZE; i++)
	{
		bNodeFlag[i] = false;
	}

	bNodeFlag[eID_OWAS] = true;
}

void nodeFlagSet(byte id)
{
	bNodeFlag[id] = true;
}

bool nodeFlagCheck()
{
	bool retval = true;
	byte i;

	for(i = 0; i < eID_SIZE; i++)
	{
		if(bNodeFlag[i] == false)
		{
			retval = false;
			break;
		}
	}

	return retval;
}

byte owasBackCheck()
{
	byte bBackRoll	= abs(nodeData[eID_BACK][eDATA_ROL].toInt());
	byte bBackPitch	= abs(nodeData[eID_BACK][eDATA_PIT].toInt());
	byte bRetVal = 1;

	if(bBackRoll > nLimitSettings[eLIM_BACK_ROLL])
	{
		bRetVal = 2;
	}

	if(bBackPitch > nLimitSettings[eLIM_BACK_PITCH])
	{
		bRetVal = 3;
	}

	if((bBackRoll > nLimitSettings[eLIM_BACK_ROLL])
		 && (bBackPitch > nLimitSettings[eLIM_BACK_PITCH]))
	{
		bRetVal = 4;
	}

	return bRetVal;
}

byte owasArmsCheck()
{
	byte bLeftArmRoll	= abs(nodeData[eID_LARM][eDATA_ROL].toInt());
	byte bLeftArmPitch	= abs(nodeData[eID_LARM][eDATA_PIT].toInt());
	byte bRightArmRoll	= abs(nodeData[eID_RARM][eDATA_ROL].toInt());
	byte bRightArmPitch	= abs(nodeData[eID_RARM][eDATA_PIT].toInt());
	byte bRetVal = 1;

	if((bRightArmRoll > nLimitSettings[eLIM_ARMS]) || (bRightArmPitch > nLimitSettings[eLIM_ARMS]))
	{
		bRetVal++;
	}

	if((bLeftArmRoll > nLimitSettings[eLIM_ARMS]) || (bLeftArmPitch > nLimitSettings[eLIM_ARMS]))
	{
		bRetVal++;
	}

	return bRetVal;
}

bool compareInRange(int value, int limit1, int limit2)
{
	bool bRetVal = false;

	if((limit1 <= value ) && (value < limit2))
	{
		bRetVal = true;
	}

	return bRetVal;
}

byte owasLegsCheck()
{
	byte bRightUpperLeg	= abs(nodeData[eID_RULEG][eDATA_ROL].toInt());
	// byte bRightLowerLeg	= abs(nodeData[eID_RLLEG][eDATA_ROL].toInt());
	byte bLeftUpperLeg	= abs(nodeData[eID_LULEG][eDATA_ROL].toInt());
	// byte bLeftLowerLeg	= abs(nodeData[eID_LLLEG][eDATA_ROL].toInt());
	byte bRightMoveR	= abs(nodeData[eID_RULEG][eDATA_MVR].toInt());
	byte bRightMoveP	= abs(nodeData[eID_RULEG][eDATA_MVP].toInt());
	byte bLeftMoveR		= abs(nodeData[eID_LULEG][eDATA_MVR].toInt());
	byte bLeftMoveP		= abs(nodeData[eID_LULEG][eDATA_MVP].toInt());
	byte bRetVal = 1;

	/*-- Moving or Walking --*/
	if((bRightMoveR > nLimitSettings[eLIM_LEG_MOVE] || bRightMoveP > nLimitSettings[eLIM_LEG_MOVE])
		&& (bLeftMoveR > nLimitSettings[eLIM_LEG_MOVE] || bLeftMoveP > nLimitSettings[eLIM_LEG_MOVE]))
	{
		bRetVal = 7;
	}

	/*-- Standing with one leg --*/
	else if((compareInRange(bRightUpperLeg, nLimitSettings[eLIM_LEG_STAND], nLimitSettings[eLIM_LEG_BENT])
				&& compareInRange(bLeftUpperLeg, nLimitSettings[eLIM_LEG_BENT], nLimitSettings[eLIM_LEG_MAX]))
					|| ((compareInRange(bRightUpperLeg, nLimitSettings[eLIM_LEG_BENT], nLimitSettings[eLIM_LEG_MAX])
						&& compareInRange(bLeftUpperLeg, nLimitSettings[eLIM_LEG_STAND], nLimitSettings[eLIM_LEG_BENT]))))
	{
		bRetVal = 3;
	}

	/*-- Stand --*/
	else if(compareInRange(bRightUpperLeg, nLimitSettings[eLIM_LEG_STAND], nLimitSettings[eLIM_LEG_BENT])
			&& compareInRange(bLeftUpperLeg, nLimitSettings[eLIM_LEG_STAND], nLimitSettings[eLIM_LEG_BENT]))
	{
		bRetVal = 2;
	}

	/*-- Standing with one leg bent --*/
	else if((compareInRange(bRightUpperLeg, nLimitSettings[eLIM_LEG_BENT], nLimitSettings[eLIM_LEG_SIT])
			&& compareInRange(bLeftUpperLeg, nLimitSettings[eLIM_LEG_SIT], nLimitSettings[eLIM_LEG_MAX]))
				|| ((compareInRange(bRightUpperLeg, nLimitSettings[eLIM_LEG_SIT], nLimitSettings[eLIM_LEG_MAX])
					&& compareInRange(bLeftUpperLeg, nLimitSettings[eLIM_LEG_BENT], nLimitSettings[eLIM_LEG_SIT]))))
	{
		bRetVal = 5;
	}
	
	/*-- Standing with both legs bent --*/
	else if((compareInRange(bRightUpperLeg, nLimitSettings[eLIM_LEG_BENT], nLimitSettings[eLIM_LEG_SIT])
				&& compareInRange(bLeftUpperLeg, nLimitSettings[eLIM_LEG_BENT], nLimitSettings[eLIM_LEG_SIT])))
	{
		bRetVal = 4;
	}

	/*-- Sit --*/
	else if((compareInRange(bRightUpperLeg, nLimitSettings[eLIM_LEG_SIT], nLimitSettings[eLIM_LEG_SQUAT])
			&& compareInRange(bLeftUpperLeg, nLimitSettings[eLIM_LEG_SIT], nLimitSettings[eLIM_LEG_SQUAT])))
	{
		bRetVal = 1;
	}

	/*-- Squatting --*/
	else if((compareInRange(bRightUpperLeg, nLimitSettings[eLIM_LEG_SQUAT], nLimitSettings[eLIM_LEG_MAX])
			&& compareInRange(bLeftUpperLeg, nLimitSettings[eLIM_LEG_SQUAT], nLimitSettings[eLIM_LEG_MAX])))
	{
		bRetVal = 6;
	}

	/*-- Default: Sitting --*/
	else
	{
		bRetVal = 1;
	}

	return bRetVal;
}

byte owasLoadCheck()
{
	byte bRetVal = 1;

	if(nUserLoad >= nLimitSettings[eLIM_LOAD_1] && nUserLoad < nLimitSettings[eLIM_LOAD_2])
	{
		bRetVal = 2;
	}
	else if(nUserLoad >= nLimitSettings[eLIM_LOAD_2])
	{
		bRetVal = 3;
	}

	return bRetVal;
}

byte owasJudgement()
{
	byte bOwasLeg	= owasLegsCheck();
	byte bOwasLoad	= owasLoadCheck();
	byte bOwasBack	= owasBackCheck();
	byte bOwasArms	= owasArmsCheck();

	byte bColumn	= ((bOwasLeg - 1) * 3) + bOwasLoad;
	byte bRow		= ((bOwasBack - 1) * 3) + bOwasArms;
	byte bOwasValue	= bOwasTable[bRow - 1][bColumn - 1];
	
	nodeData[eID_OWAS][eOWAS_ID]	= "1";
	nodeData[eID_OWAS][eOWAS_BACK]	= String(bOwasBack,		DEC);
	nodeData[eID_OWAS][eOWAS_ARMS]	= String(bOwasArms,		DEC);
	nodeData[eID_OWAS][eOWAS_LEGS]	= String(bOwasLeg,		DEC);
	nodeData[eID_OWAS][eOWAS_LOAD]	= String(bOwasLoad,		DEC);
	nodeData[eID_OWAS][eOWAS_LEVEL]	= String(bOwasValue,	DEC);

	return bOwasValue;
}

void nodeTimeGapCheck(int id)
{
	Serial.print("Elapsed Time : ");
	Serial.println((millis() - dwNodeTimeGap[id])/1000);

	dwNodeTimeGap[id] = millis();
}

void clientCheck(WiFiClient client)
{
	String header = "";
	int delaytime = 0;
	bool bUpdateFlag = false;

	if (client.available())											// If a new client connects,
	{
		digitalWrite(LED_BUILTIN, HIGH);
		String currentLine = "";                // make a String to hold incoming data from the client

		while (client.connected()) 
		{
			if (client.available())
			{
				char c = client.read();
				Serial.write(c);
				header += c;

				if (c == '\n') 
				{
					// if the current line is blank, you got two newline characters in a row.
					// that's the end of the client HTTP request, so send a response:
					if (currentLine.length() == 0)
					{
						// HTTP headers always start with a response code (e.g. HTTP/1.1 200 OK)
						// and a content-type so the client knows what's coming, then a blank line:
						client.println("HTTP/1.1 200 OK");
						client.println("Content-type:text/html");
						client.println("Connection: close");
						client.println();
						
						// Display the HTML web page
						client.println("<!DOCTYPE html><html>");
						client.println("<head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">");
						client.println("<link rel=\"icon\" href=\"data:,\"></head>");
						
						//client.println("<style>html { font-family: Helvetica; display: inline-block; margin: 0px auto; text-align: center;}");          
						//client.println(".button { background-color: #195B6A; border: none; color: white; padding: 16px 40px;");
            			//client.println("text-decoration: none; font-size: 30px; margin: 2px; cursor: pointer;}");
            			//client.println(".button2 {background-color: #77878A;}</style>");
						//client.println("</head>");

            			client.println("<body>");

						if (header.indexOf("form") >= 0)
						{
							if(header.indexOf("rightleg=") >= 0)
							{
								int index[] = {	header.indexOf("rightleg="),
												header.indexOf("leftleg="),
												header.indexOf("HTTP/1.1"),
											};

								nodeData[eID_RULEG][eDATA_ROL] = header.substring(index[0] + 9, index[1] - 1);
								nodeData[eID_LULEG][eDATA_ROL] = header.substring(index[1] + 8, index[2] - 1);

								owasLegsCheck();
							}

							client.println("<form action='form'>");

							client.println("<label for='rightleg'>Right Leg :</label><br>");
							client.println("<input type='text' id='rightleg' name='rightleg' value='");
							client.println(nodeData[eID_RULEG][eDATA_ROL]);
							client.println("'><br>");

							client.println("<label for='leftleg'>Left Leg :</label><br>");
							client.println("<input type='text' id='left_leg' name='leftleg' value='");
							client.println(nodeData[eID_LULEG][eDATA_ROL]);
							client.println("'><br><br>");
							client.println("<input type='submit' value='Submit'>");

							client.println("</form>");
						}
						else if (header.indexOf("connect?") >= 0)
						{
							if(!bDebugState) 
							{
								client.println("<p>cmd=disconnect</p>");
							}
							else
							{
								client.println("<p>cmd=wait</p>");
							}

							int index[] = {	header.indexOf("nod="),
											header.indexOf("HTTP/1.1"),
										};

							int nodeId = header.substring(index[0] + 4, index[1] - 1).toInt();
							
							Serial.println();
							Serial.println("------------------------");
							Serial.print("Node: ");
							Serial.print(nodeId);
							Serial.println("  Connected !");

							nodeTimeGapCheck(nodeId);

							//delaytime = queueGetDelayTime(nodeId);
							//client.println("<br/><p>delay=20 seconds</p>");
						}
						else if (header.indexOf("update?") >= 0)
						{
							if(!bDebugState) 
							{
								client.println("<p>cmd=ok</p>");
							}
							else
							{
								client.println("<p>cmd=wait</p>");
							}

							bUpdateFlag = true;
							
							int index[] = {	header.indexOf("nod="),
											header.indexOf("rol=")
										};

							int nodeId = header.substring(index[0] + 4, index[1] - 1).toInt();
			
							Serial.println();
							Serial.println("------------------------");
							Serial.print("Node = ");
							Serial.print(nodeId);
							Serial.println("  --> Data received !");
							
							//Serial.print("Roll = ");
							//Serial.println(nodeData[nodeId][eDATA_ROL]);
							//Serial.print("Pitch = ");
							//Serial.println(nodeData[nodeId][eDATA_PIT]);
							//Serial.print("Yaw = ");
							//Serial.println(nodeData[nodeId][eDATA_YAW]);
							//Serial.print("Roll Movement = ");
							//Serial.println(nodeData[nodeId][eDATA_MVR]);
							//Serial.print("Pitch Movement = ");
							//Serial.println(nodeData[nodeId][eDATA_MVP]);
							//Serial.print("Batt = ");
							//Serial.println(nodeData[nodeId][eDATA_BAT]);

							//delaytime = queueGetDelayTime(nodeId);
							//client.print("<br/><p>delay=40 seconds</p>");
							
							nodeTimeGapCheck(nodeId);

							nodeFlagSet(nodeId);
						}
						else if (header.indexOf("debug") >= 0)
						{
							if (header.indexOf("GET /debug/state/on") >= 0)
							{
								bDebugState = true;
							}
							else if (header.indexOf("GET /debug/state/off") >= 0)
							{
								bDebugState = false;
							}

							if(bDebugState)
							{								
								client.println("<p>Debug State : ON</p>");
								client.println("<p><a href=\"/debug/state/off\"><button class=\"button\">Turn OFF</button></a></p>");
							}
							else
							{
								client.println("<p>Debug State : OFF</p>");
								client.println("<p><a href=\"/debug/state/on\"><button class=\"button button2\">Turn ON</button></a></p>");
							}
						}
						else
						{
							int i, j;
							for(i = 0; i < 7; i++)
							{
								client.println("<h2>Sensor " + String((i + 1), DEC) + " Table</h2>");
								client.println("<table border='1' cellpadding='8'>");
								client.println("<tr><th>Sec.</th><th>Roll</th><th>Pitch</th><th>Yaw</th></tr>");

								for(j = 0; j < 30; j+=3)
								{
									client.println("<tr>");

									client.println("<td>" + String((((j / 3) + 1) * 5), DEC) + "</td>");
									client.println("<td>" + nodeDataArray[i][j + 0] + "</td>");
									client.println("<td>" + nodeDataArray[i][j + 1] + "</td>");
									client.println("<td>" + nodeDataArray[i][j + 2] + "</td>");

									client.println("</tr>");
								}

								client.println("</table>");
								client.println("<br/><br/>");
							}
						}

						client.println("</body></html>");

						// The HTTP response ends with another blank line
						client.println();
						// Serial.println(header);

						break;
					}
					else
					{
						currentLine = "";
					}
				}
				else if (c != '\r')
				{
					currentLine += c;
				}
			}
		}
		
		// Close the connection
		client.stop();
		// Serial.println("Client disconnected.");
		// Serial.println("");

		if(bUpdateFlag)
		{
			// Process client get request
			int index[] = {	header.indexOf("nod="),
							header.indexOf("rol="),
							header.indexOf("pit="),
							header.indexOf("yaw="),
							header.indexOf("mro="),
							header.indexOf("mpi="),
							header.indexOf("bat="),

							header.indexOf("rol0="),
							header.indexOf("pit0="),
							header.indexOf("yaw0="),

							header.indexOf("rol1="),
							header.indexOf("pit1="),
							header.indexOf("yaw1="),

							header.indexOf("rol2="),
							header.indexOf("pit2="),
							header.indexOf("yaw2="),

							header.indexOf("rol3="),
							header.indexOf("pit3="),
							header.indexOf("yaw3="),

							header.indexOf("rol4="),
							header.indexOf("pit4="),
							header.indexOf("yaw4="),

							header.indexOf("rol5="),
							header.indexOf("pit5="),
							header.indexOf("yaw5="),

							header.indexOf("rol6="),
							header.indexOf("pit6="),
							header.indexOf("yaw6="),

							header.indexOf("rol7="),
							header.indexOf("pit7="),
							header.indexOf("yaw7="),

							header.indexOf("rol8="),
							header.indexOf("pit8="),
							header.indexOf("yaw8="),

							header.indexOf("rol9="),
							header.indexOf("pit9="),
							header.indexOf("yaw9="),

							header.indexOf("HTTP/1.1"),
						};
						
			int nodeId = header.substring(index[0] + 4, index[1] - 1).toInt();

			nodeData[nodeId][eDATA_ID]	= String((nodeId + 1), DEC);
			nodeData[nodeId][eDATA_ROL] = header.substring(index[1] + 4, index[2] - 1);
			nodeData[nodeId][eDATA_PIT] = header.substring(index[2] + 4, index[3] - 1);
			nodeData[nodeId][eDATA_YAW] = header.substring(index[3] + 4, index[4] - 1);
			nodeData[nodeId][eDATA_MVR] = header.substring(index[4] + 4, index[5] - 1);
			nodeData[nodeId][eDATA_MVP] = header.substring(index[5] + 4, index[6] - 1);
			nodeData[nodeId][eDATA_BAT] = header.substring(index[6] + 4, index[7] - 1);

			if(index[7] > 0)
			{
				nodeId -= 1;

				nodeDataArray[nodeId][0]  = header.substring(index[7] + 5, index[8] - 1);
				nodeDataArray[nodeId][1]  = header.substring(index[8] + 5, index[9] - 1);
				nodeDataArray[nodeId][2]  = header.substring(index[9] + 5, index[10] - 1);

				nodeDataArray[nodeId][3]  = header.substring(index[10] + 5, index[11] - 1);
				nodeDataArray[nodeId][4]  = header.substring(index[11] + 5, index[12] - 1);
				nodeDataArray[nodeId][5]  = header.substring(index[12] + 5, index[13] - 1);

				nodeDataArray[nodeId][6]  = header.substring(index[13] + 5, index[14] - 1);
				nodeDataArray[nodeId][7]  = header.substring(index[14] + 5, index[15] - 1);
				nodeDataArray[nodeId][8]  = header.substring(index[15] + 5, index[16] - 1);

				nodeDataArray[nodeId][9]  = header.substring(index[16] + 5, index[17] - 1);
				nodeDataArray[nodeId][10] = header.substring(index[17] + 5, index[18] - 1);
				nodeDataArray[nodeId][11] = header.substring(index[18] + 5, index[19] - 1);

				nodeDataArray[nodeId][12] = header.substring(index[19] + 5, index[20] - 1);
				nodeDataArray[nodeId][13] = header.substring(index[20] + 5, index[21] - 1);
				nodeDataArray[nodeId][14] = header.substring(index[21] + 5, index[22] - 1);

				nodeDataArray[nodeId][15] = header.substring(index[22] + 5, index[23] - 1);
				nodeDataArray[nodeId][16] = header.substring(index[23] + 5, index[24] - 1);
				nodeDataArray[nodeId][17] = header.substring(index[24] + 5, index[25] - 1);

				nodeDataArray[nodeId][18] = header.substring(index[25] + 5, index[26] - 1);
				nodeDataArray[nodeId][19] = header.substring(index[26] + 5, index[27] - 1);
				nodeDataArray[nodeId][20] = header.substring(index[27] + 5, index[28] - 1);

				nodeDataArray[nodeId][21] = header.substring(index[28] + 5, index[29] - 1);
				nodeDataArray[nodeId][22] = header.substring(index[29] + 5, index[30] - 1);
				nodeDataArray[nodeId][23] = header.substring(index[30] + 5, index[31] - 1);

				nodeDataArray[nodeId][24] = header.substring(index[31] + 5, index[32] - 1);
				nodeDataArray[nodeId][25] = header.substring(index[32] + 5, index[33] - 1);
				nodeDataArray[nodeId][26] = header.substring(index[33] + 5, index[34] - 1);

				nodeDataArray[nodeId][27] = header.substring(index[34] + 5, index[35] - 1);
				nodeDataArray[nodeId][28] = header.substring(index[35] + 5, index[36] - 1);
				nodeDataArray[nodeId][29] = header.substring(index[36] + 5, index[37] - 1);

				//Serial.println("\n\n------------------------------------");
				//int x;
				//for(x = 0; x < 30; x+=3)
				//{
				//	Serial.println("Rol" + String(x ,DEC) + "= " + nodeDataArray[nodeId][x + 0]);
				//	Serial.println("Pit" + String(x ,DEC) + "= " + nodeDataArray[nodeId][x + 1]);
				//	Serial.println("Yaw" + String(x ,DEC) + "= " + nodeDataArray[nodeId][x + 2]);
				//
				//	Serial.println();
				//}
				//Serial.println("------------------------------------\n\n");
			}
		}

		digitalWrite(LED_BUILTIN, LOW);
	}
}

void setup()
{
	Serial.begin(115200);

	pinMode(LED_BUILTIN, OUTPUT);
	pinMode(PIN_BUZZER, OUTPUT);
	pinMode(PIN_VIBRATOR, OUTPUT);

	WiFi.mode(WIFI_AP);
	delay(2000);
	if (!WiFi.softAP(ssid, password, 1, 0, 8))
	{
		Serial.println("WiFi.softAP failed.(Password too short?)");
		return;
	}

	Serial.println();
	Serial.print("AP IP address: ");
	Serial.println(WiFi.softAPIP());

	server.begin();

	// Create the BLE Device
	BLEDevice::init("ESP32 BLE"); // Give it a name

	// Create the BLE Server
	BLEServer *pServer = BLEDevice::createServer();
	pServer->setCallbacks(new MyServerCallbacks());

	// Create the BLE Service
	BLEService *pService = pServer->createService(SERVICE_UUID);

	// Create a BLE Characteristic
	pCharacteristic = 	pService->createCharacteristic(
                		CHARACTERISTIC_UUID_TX,
                		BLECharacteristic::PROPERTY_NOTIFY
                    	);
                      
	pCharacteristic->addDescriptor(new BLE2902());

	BLECharacteristic *pCharacteristic = 	pService->createCharacteristic(
											CHARACTERISTIC_UUID_RX,
											BLECharacteristic::PROPERTY_WRITE
    										);

	pCharacteristic->setCallbacks(new MyCallbacks());

	// Start the service
	pService->start();

	// Start advertising
	pServer->getAdvertising()->start();
	Serial.println("Waiting a client connection to notify...");

	sNodeData.reserve(200);

	nodeFlagReset();
	limitSettingInit();
}

void loop() 
{
	int i = 0;
	char txString[60] = "";

	sNodeData = "";

	// Listen for incoming clients
	clientCheck(server.available());

	if( nodeFlagCheck() == true)
	{
		if(owasJudgement() == 4)
		{
			digitalWrite(PIN_BUZZER, HIGH);
			digitalWrite(PIN_VIBRATOR, HIGH);
			digitalWrite(LED_BUILTIN, HIGH);

			bWarningFlag = true;

			ulWarningMillis = millis();
		}
		else
		{
			digitalWrite(PIN_BUZZER, HIGH);
			delay(50);
			digitalWrite(PIN_BUZZER, LOW);
		}	

		nodeFlagReset();

		bInitialFlag = false;
		bDataReadyFlag = true;
	}

	if(bWarningFlag)
	{	
		if((millis() - ulWarningMillis) > ulWarningDelay)
		{
			digitalWrite(PIN_BUZZER, LOW);
			digitalWrite(PIN_VIBRATOR, LOW);
			digitalWrite(LED_BUILTIN, LOW);
		
			bWarningFlag = false;
		}
	}
	
	if(bDataReadyFlag && bleDeviceConnected)
	{
		if((millis() - ulMillis) > ulNodeDelay)
		{
			if(nodeIndex == 0)
			{
				sNodeData =	String(nodeIndex + 1, DEC) + "," +
								nodeData[nodeIndex][eOWAS_BACK] + "," +
								nodeData[nodeIndex][eOWAS_ARMS] + "," +
								nodeData[nodeIndex][eOWAS_LEGS] + "," +
								nodeData[nodeIndex][eOWAS_LOAD] + "," +
								nodeData[nodeIndex][eOWAS_LEVEL] + "\0" ;
			}
			else
			{
				sNodeData =	String(nodeIndex + 1, DEC) + "," +
								nodeData[nodeIndex][eDATA_ROL] + "," +
								nodeData[nodeIndex][eDATA_PIT] + "," +
								nodeData[nodeIndex][eDATA_YAW] + "," +
								nodeData[nodeIndex][eDATA_BAT] + "\0" ;
			}

			i = 0;
			do
			{
				txString[i] = sNodeData[i];
				i++;
			}
			while(sNodeData[i] != '\0');

			pCharacteristic->setValue(txString);
			pCharacteristic->notify();

			Serial.print("nodeIndex : ");
			Serial.print(nodeIndex);
			Serial.print(" | Data Sent : ");
			Serial.println(txString);
		
			nodeIndex++;
			if(nodeIndex == eID_SIZE)
			{
				nodeIndex = 0;
				bDataReadyFlag = false;
			
				Serial.println();
				Serial.println();
			}

			ulMillis = millis();
		}
	}
}