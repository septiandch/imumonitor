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

enum nodeIdEnum
{
	ID_OWAS = 0,
	ID_BACK,
	ID_RARM,
	ID_LARM,
	ID_RULEG,
	ID_RLLEG,
	ID_LULEG,
	ID_LLLEG,
	ID_END
};

bool bNodeFlag[ID_END];
bool bDebugState = false;


enum nodeEnum
{
	DATA_ID = 0,
	DATA_ROL,
	DATA_PIT,
	DATA_YAW,
	DATA_MVR,
	DATA_MVP,
	DATA_BAT,
	DATA_END
};

enum owasEnum
{
	OWAS_ID = 0,
	OWAS_BACK,
	OWAS_ARMS,
	OWAS_LEGS,
	OWAS_LOAD,
	OWAS_LEVEL,
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

int nUserLoad		= 15;
int nLimitArms		= 90;
int nLimitBackRoll	= 20;
int nLimitBackPitch	= 20;
int nLimitLoad1		= 10;
int nLimitLoad2		= 20;
int nLimitMov		= 1000;

// Replace with your network credentials
const char ssid[]     = "ESP32 BLE";
const char password[] = "12345678";

// BLE Update Timer
const unsigned long ulNodeDelay = 200;
unsigned long ulMillis = 0;
int nodeIndex = 0;

bool bDataReadyFlag = false;

// Set web server port number to 80
WiFiServer server(80);

BLECharacteristic *pCharacteristic;
bool bleDeviceConnected = false;

String nodeData[8][8];

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

		if (rxValue.length() > 0)
		{
			Serial.println("*********");
			Serial.print("Received Value: ");

			for (int i = 0; i < rxValue.length(); i++) {
			Serial.print(rxValue[i]);
			}

			pCharacteristic->setValue(rxValue); // Sending a test message
		
			pCharacteristic->notify(); // Send the value to the app!
			Serial.print("*** Sent Value: ");
			
			for (int i = 0; i < rxValue.length(); i++)
			{
				Serial.print(rxValue[i]);
			}
			Serial.println(" ***");

			Serial.println();
			Serial.println("*********");
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

	for(i = 0; i < ID_END; i++)
	{
		bNodeFlag[i] = false;
	}

	bNodeFlag[ID_OWAS] = true;
}

void nodeFlagSet(byte id)
{
	bNodeFlag[id] = true;
}

bool nodeFlagCheck()
{
	bool retval = true;
	byte i;

	for(i = 0; i < ID_END; i++)
	{
		if(bNodeFlag[i] == false)
		{
			retval = false;
			break;
		}
	}

	return retval;
}

void clientCheck(WiFiClient client)
{
	String header = "";

	if (client)											// If a new client connects,
	{
		String currentLine = "";                // make a String to hold incoming data from the client

		while (client.connected()) 
		{
			if (client.available())
			{
				char c = client.read();
				// Serial.write(c);
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
						
						client.println("<style>html { font-family: Helvetica; display: inline-block; margin: 0px auto; text-align: center;}");          
						client.println(".button { background-color: #195B6A; border: none; color: white; padding: 16px 40px;");
            			client.println("text-decoration: none; font-size: 30px; margin: 2px; cursor: pointer;}");
            			client.println(".button2 {background-color: #77878A;}</style></head>");

            			client.println("<body>");

						if (header.indexOf("connect?") >= 0)
						{
							client.println("<p>cmd=disconnect</p>");

							int index[] = {	header.indexOf("nod="),
											header.indexOf("HTTP/1.1"),
										};

							int nodeId = header.substring(index[0] + 4, index[1] - 1).toInt();
							Serial.print("Node: ");
							Serial.print(nodeId);
							Serial.println("  Conected !");
						}
						else if (header.indexOf("update?") >= 0)
						{
							if(!bDebugState) 
							{
								client.println("<p>cmd=disconnect</p>");
							}
							else
							{
								client.println("<p>cmd=wait</p>");
							}

							// Process client get request
							int index[] = {	header.indexOf("nod="),
											header.indexOf("rol="),
											header.indexOf("pit="),
											header.indexOf("yaw="),
											header.indexOf("mro="),
											header.indexOf("mpi="),
											header.indexOf("bat="),
											header.indexOf("HTTP/1.1"),
										};
							
							int nodeId = header.substring(index[0] + 4, index[1] - 1).toInt();

							nodeData[nodeId][DATA_ID] = String((nodeId + 1), DEC);
							nodeData[nodeId][DATA_ROL] = header.substring(index[1] + 4, index[2] - 1);
							nodeData[nodeId][DATA_PIT] = header.substring(index[2] + 4, index[3] - 1);
							nodeData[nodeId][DATA_YAW] = header.substring(index[3] + 4, index[4] - 1);
							nodeData[nodeId][DATA_MVR] = header.substring(index[4] + 4, index[5] - 1);
							nodeData[nodeId][DATA_MVP] = header.substring(index[5] + 4, index[6] - 1);
							nodeData[nodeId][DATA_BAT] = header.substring(index[6] + 4, index[7] - 1);
							nodeData[nodeId][DATA_END] = "0";
							
							// Serial.println();
							Serial.print("Node = ");
							Serial.println(nodeId);
							// Serial.print("Roll = ");
							// Serial.println(nodeData[nodeId][DATA_ROL]);
							// Serial.print("Pitch = ");
							// Serial.println(nodeData[nodeId][DATA_PIT]);
							// Serial.print("Yaw = ");
							// Serial.println(nodeData[nodeId][DATA_YAW]);
							// Serial.print("Roll Movement = ");
							// Serial.println(nodeData[nodeId][DATA_MVR]);
							// Serial.print("Pitch Movement = ");
							// Serial.println(nodeData[nodeId][DATA_MVP]);
							// Serial.print("Batt = ");
							// Serial.println(nodeData[nodeId][DATA_BAT]);
							// Serial.println("------------------------");

							nodeFlagSet(nodeId);
						}
						else
						{
							if (header.indexOf("GET /state/on") >= 0)
							{
								bDebugState = true;
							}
							else if (header.indexOf("GET /state/off") >= 0)
							{
								bDebugState = false;
							}

							if(bDebugState)
							{								
								client.println("<p>Debug State : ON</p>");
								client.println("<p><a href=\"/state/off\"><button class=\"button\">Turn OFF</button></a></p>");
							}
							else
							{
								client.println("<p>Debug State : OFF</p>");
								client.println("<p><a href=\"/state/on\"><button class=\"button button2\">Turn ON</button></a></p>");
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
	}
}

byte owasBackCheck()
{
	byte bBackRoll	= abs(nodeData[ID_BACK][DATA_ROL].toInt());
	byte bBackPitch	= abs(nodeData[ID_BACK][DATA_PIT].toInt());
	byte bRetVal = 1;

	if(bBackRoll > nLimitBackRoll)
	{
		bRetVal = 2;
	}

	if(bBackPitch > nLimitBackPitch)
	{
		bRetVal = 3;
	}

	if((bBackRoll > nLimitBackRoll)
		 && (bBackPitch > nLimitBackPitch))
	{
		bRetVal = 4;
	}

	return bRetVal;
}

byte owasArmsCheck()
{
	byte bLeftArmRoll	= abs(nodeData[ID_LARM][DATA_ROL].toInt());
	byte bLeftArmPitch	= abs(nodeData[ID_LARM][DATA_PIT].toInt());
	byte bRightArmRoll	= abs(nodeData[ID_RARM][DATA_ROL].toInt());
	byte bRightArmPitch	= abs(nodeData[ID_RARM][DATA_PIT].toInt());
	byte bRetVal = 1;

	if((bRightArmRoll > nLimitArms) || (bRightArmPitch > nLimitArms))
	{
		bRetVal++;
	}

	if((bLeftArmRoll > nLimitArms) || (bLeftArmPitch > nLimitArms))
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

int nLimitLegStand	= 0;
int nLimitLegBent	= 30;
int nLimitLegSit	= 60;
int nLimitLegSquat	= 120;
int nLimitDegMax	= 180;
int nLimitWalking	= 800;

byte owasLegsCheck()
{
	byte bRightUpperLeg	= abs(nodeData[ID_RULEG][DATA_ROL].toInt());
	// byte bRightLowerLeg	= abs(nodeData[ID_RLLEG][DATA_ROL].toInt());
	byte bLeftUpperLeg	= abs(nodeData[ID_LULEG][DATA_ROL].toInt());
	// byte bLeftLowerLeg	= abs(nodeData[ID_LLLEG][DATA_ROL].toInt());
	byte bRightMoveR	= abs(nodeData[ID_LLLEG][DATA_MVR].toInt());
	byte bRightMoveP	= abs(nodeData[ID_LLLEG][DATA_MVP].toInt());
	byte bLeftMoveR		= abs(nodeData[ID_LLLEG][DATA_MVR].toInt());
	byte bLeftMoveP		= abs(nodeData[ID_LLLEG][DATA_MVP].toInt());
	byte bRetVal = 1;


	/*-- Moving or Walking --*/
	if((bRightMoveR > nLimitWalking || bRightMoveP > nLimitWalking)
		&& (bLeftMoveR > nLimitWalking || bLeftMoveP > nLimitWalking))
	{
		bRetVal = 7;
	}

	/*-- Standing with one leg --*/
	else if((compareInRange(bRightUpperLeg, nLimitLegStand, nLimitLegBent)
				&& compareInRange(bLeftUpperLeg, nLimitLegBent, nLimitDegMax))
					|| ((compareInRange(bRightUpperLeg, nLimitLegBent, nLimitDegMax)
						&& compareInRange(bLeftUpperLeg, nLimitLegStand, nLimitLegBent))))
	{
		bRetVal = 3;
	}

	/*-- Stand --*/
	else if(compareInRange(bRightUpperLeg, nLimitLegStand, nLimitLegBent)
			&& compareInRange(bLeftUpperLeg, nLimitLegStand, nLimitLegBent))
	{
		bRetVal = 2;
	}
	
	/*-- Standing with both legs bent --*/
	else if((compareInRange(bRightUpperLeg, nLimitLegBent, nLimitLegSit)
				&& compareInRange(bLeftUpperLeg, nLimitLegBent, nLimitLegSit)))
	{
		bRetVal = 4;
	}

	/*-- Standing with one leg bent --*/
	else if((compareInRange(bRightUpperLeg, nLimitLegBent, nLimitLegSit)
			&& compareInRange(bLeftUpperLeg, nLimitLegSit, nLimitLegSquat))
				|| ((compareInRange(bRightUpperLeg, nLimitLegSit, nLimitLegSquat)
					&& compareInRange(bLeftUpperLeg, nLimitLegBent, nLimitLegSit))))
	{
		bRetVal = 5;
	}

	/*-- Sit --*/
	else if((compareInRange(bRightUpperLeg, nLimitLegSit, nLimitLegSquat)
			&& compareInRange(bLeftUpperLeg, nLimitLegSit, nLimitLegSquat)))
	{
		bRetVal = 1;
	}

	/*-- Squatting --*/
	else if((compareInRange(bRightUpperLeg, nLimitLegSquat, nLimitDegMax)
			&& compareInRange(bLeftUpperLeg, nLimitLegSquat, nLimitDegMax)))
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

	if(nUserLoad >= nLimitLoad1 && nUserLoad < nLimitLoad2)
	{
		bRetVal = 2;
	}
	else if(nUserLoad >= nLimitLoad2)
	{
		bRetVal = 3;
	}

	return bRetVal;
}

void owasJudgement()
{
	byte bOwasLeg	= owasLegsCheck();
	byte bOwasLoad	= owasLoadCheck();
	byte bOwasBack	= owasBackCheck();
	byte bOwasArms	= owasArmsCheck();

	byte bColumn	= ((bOwasLeg - 1) * 3) + bOwasLoad;
	byte bRow		= ((bOwasBack - 1) * 3) + bOwasArms;
	byte bOwasValue	= bOwasTable[bRow - 1][bColumn - 1];
	
	nodeData[ID_OWAS][OWAS_ID]		= "1";
	nodeData[ID_OWAS][OWAS_BACK]	= String(bOwasBack,		DEC);
	nodeData[ID_OWAS][OWAS_ARMS]	= String(bOwasArms,		DEC);
	nodeData[ID_OWAS][OWAS_LEGS]	= String(bOwasLeg,		DEC);
	nodeData[ID_OWAS][OWAS_LOAD]	= String(bOwasLoad,		DEC);
	nodeData[ID_OWAS][OWAS_LEVEL]	= String(bOwasValue,	DEC);
}

/*
void unitTest_Leg()
{
	int patternsize = 5;
	int pattern[] = {nLimitLegStand, nLimitLegBent - 2, nLimitLegSit - 2, nLimitLegSquat - 2, nLimitLegSquat + 2};


	Serial.println();
	Serial.println();
	Serial.println("Right Leg ----------------------------------");

	for(int i = 0; i < patternsize; i++)
	{
		nodeData[ID_RULEG][DATA_ROL] = String(pattern[i], DEC);
		nodeData[ID_LULEG][DATA_ROL] = String(35, DEC);

		Serial.print("RL : ");
		Serial.print(nodeData[ID_RULEG][DATA_ROL]);
		Serial.print("  | LL : ");
		Serial.print(nodeData[ID_LULEG][DATA_ROL]);
		Serial.print(" | OWAS : ");
		Serial.println(owasLegsCheck());
		Serial.println("----------------------------------");
		Serial.println();
	}

	
	Serial.println();
	Serial.println();
	Serial.println("Left Leg ----------------------------------");

	for(int i = 0; i < patternsize; i++)
	{
		nodeData[ID_RULEG][DATA_ROL] = String(35, DEC);
		nodeData[ID_LULEG][DATA_ROL] = String(pattern[i], DEC);

		Serial.print("RL : ");
		Serial.print(nodeData[ID_RULEG][DATA_ROL]);
		Serial.print(" | LL : ");
		Serial.print(nodeData[ID_LULEG][DATA_ROL]);
		Serial.print(" | OWAS : ");
		Serial.println(owasLegsCheck());
		Serial.println("----------------------------------");
	}

	Serial.println();
	Serial.println();
	Serial.println("Both Leg ----------------------------------");

	for(int i = 0; i < patternsize; i++)
	{
		nodeData[ID_RULEG][DATA_ROL] = String(pattern[i], DEC);
		nodeData[ID_LULEG][DATA_ROL] = String(pattern[i], DEC);

		Serial.print("RL Roll : ");
		Serial.print(nodeData[ID_RULEG][DATA_ROL]);
		Serial.print(" | LL Roll : ");
		Serial.print(nodeData[ID_LULEG][DATA_ROL]);
		Serial.print(" | OWAS : ");
		Serial.println(owasLegsCheck());
		Serial.println("----------------------------------");
	}
}
*/

void setup()
{
	Serial.begin(115200);

	pinMode(LED_BUILTIN, OUTPUT);

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

	nodeFlagReset();
}

void loop() 
{
	int i = 0;
	String sNodeData;
	char txString[20] = "";

	// Listen for incoming clients
	clientCheck(server.available());

	if( nodeFlagCheck() == true)
	{
		owasJudgement();
		nodeFlagReset();

		bDataReadyFlag = true;
	}
	
	if(bDataReadyFlag && bleDeviceConnected)
	{
		if((millis() - ulMillis) > ulNodeDelay)
		{
			sNodeData =	nodeData[nodeIndex][0] + "," +
						nodeData[nodeIndex][1] + "," +
						nodeData[nodeIndex][2] + "," +
						nodeData[nodeIndex][3] + "," +
						nodeData[nodeIndex][4] + "," +
						nodeData[nodeIndex][5] + "\0" ;
				
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
			if(nodeIndex > ID_END - 1)
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