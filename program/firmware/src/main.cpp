/*
  Calibrate HMC5883L. Output for HMC5883L_calibrate_processing.pde
  Read more: http://www.jarzebski.pl/arduino/czujniki-i-sensory/3-osiowy-magnetometr-hmc5883l.html
  GIT: https://github.com/jarzebski/Arduino-HMC5883L
  Web: http://www.jarzebski.pl
  (c) 2014 by Korneliusz Jarzebski
*/

#ifndef ESPRESSIF32

#include <Arduino.h>
#include <Wire.h>
#include <ESP8266HTTPClient.h>
#include "EasyOta.h"
#include "MPU9250.h"

//#define CALIBRATE_COMPASS

#define VIN_MAX		6		
#define ADC_RESO	1023		

#define LED01		D3		//GPIO00
#define LED02		D4		//GPIO02
#define BTN01		D0		//GPIO16
#define BTN02		D5		//GPIO14
#define BAT_EN		D6		//GPIO12
#define BAT_CH		A0		//ADC

#ifndef NODEID
#	define NODEID	"-"
#endif

#ifdef WIFINAME
const char WIFI_NAME[] = WIFINAME;
const char WIFI_PW[] = WIFIPASS;
#else
const char WIFI_NAME[] = "ESP32 BLE";
const char WIFI_PW[] = "12345678";
#endif

#ifdef IPADDR
const char IP_ADDR[] = IPADDR;

int ip[4];
#endif

WiFiServer server(80);

IPAddress IP(192,168,4,111);
IPAddress NETMASK(255,255,255,0);
#ifndef DUMMY_FLG
IPAddress NETWORK(192,168,4,1);
IPAddress DNS(192,168,4,1);
#else
IPAddress NETWORK(192,168,0,1);
IPAddress DNS(192,168,0,1);
#endif

String header;
String LED_BUILTIN_State = "off";

const long timeoutTime = 2000;

unsigned long currentTime = millis();
unsigned long previousTime = 0; 
unsigned long dwMillis = 0; 
unsigned long dwTrgMillis = 0; 
uint8_t bConnCount = 0;

bool bConnState = false;
bool bLedState = false;
uint8_t	bRetryCount = 0;

uint8_t bBattLevel[] =  {100, 95,  90,  85,  80,  75,  70,  65,  60,  55,  50,  45,  40,  35,  30,  25,  20,  15,  10,  5,   0  };
uint16_t nBattVolt[]  = {420, 415, 411, 408, 402, 398, 395, 391, 387, 385, 384, 382, 380, 379, 377, 375, 373, 371, 369, 361, 327};

MPU6500 mpu;

// Pitch, Roll and Yaw values
int16_t nPitch	= 0;
int16_t nRoll	= 0;
int16_t nYaw	= 0;

int16_t nSampleRoll		= 0;
int16_t nSamplePitch	= 0;
int16_t nSampleYaw		= 0;
int16_t nSample			= 0;

QMC5883L compass;

int nBatt	= 0;
uint8_t bBattPercentage	= 0;

int calibrationData[3][2];
bool changed = false;
bool done = false;
int t = 0;
int c = 0;

String sScanResult = "";

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

void i2cScan()
{
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
}

void ledBlink()
{
	if(WiFi.status() != WL_CONNECTED)
	{
		if(millis() - dwMillis > dwTrgMillis)
		{
			if(bLedState)
			{
				digitalWrite(LED_BUILTIN, HIGH);
				dwTrgMillis = 500;
				bLedState = false;
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
				dwTrgMillis = 2000;
				bLedState = false;
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
}

void wifiConnect()
{	
	WiFi.mode(WIFI_STA);
	WiFi.setSleepMode(WIFI_NONE_SLEEP);
	WiFi.begin(WIFI_NAME, WIFI_PW);

	while (WiFi.waitForConnectResult() != WL_CONNECTED)
	{
		ledBlink();
	};

	delay(1000);

#	ifndef IPADDR
  	WiFi.config(IP, NETWORK, NETMASK, DNS);
#	else
	str2ip(IP_ADDR, ip);
  	
	WiFi.config(IPAddress(ip[0], ip[1], ip[2], ip[3]), NETWORK, NETMASK, DNS);
#	endif
}

void setup()
{
	pinMode(LED_BUILTIN, OUTPUT);
	pinMode(BAT_EN, OUTPUT);

	digitalWrite(LED_BUILTIN, HIGH);
	digitalWrite(BAT_EN, LOW);

	Wire.begin();
	delay(2000);

	i2cScan();

	mpu.setup(0x68);  // change to your own address

	//mpu.calibrateAccelGyro();
	//mpu.calibrateMag();

	mpu.setupMag();

	delay(500);

	wifiConnect();

	server.begin();

	EasyOta.setup();
}

int battCheck()
{
	int value = 0;

	digitalWrite(BAT_EN, HIGH);

	value = (int)(((float)(analogRead(BAT_CH) * VIN_MAX) / ADC_RESO) * 100);

	digitalWrite(BAT_EN, LOW);

	return value;
}

int battLevel(int vBatt)
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

void checkUpdateRequest()
{
	EasyOta.checkForUpload();
}

void checkClientRequest()
{
	WiFiClient client = server.available();   // Listen for incoming clients

	if(client)  // If a new client connects,
	{
		digitalWrite(LED_BUILTIN, LOW);
		//Serial.println("New Client.");          // print a message out in the serial port
		String currentLine = "";                // make a String to hold incoming data from the client
		
		currentTime = millis();
		previousTime = currentTime;
		
		while (client.connected() && currentTime - previousTime <= timeoutTime)
		{ // loop while the client's connected
			currentTime = millis();         
			
			if (client.available())
			{             // if there's bytes to read from the client,
				char c = client.read();             // read a byte, then
				//Serial.write(c);                    // print it out the serial monitor
				header += c;
				
				if (c == '\n') // if the byte is a newline character
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
						client.println("<link rel=\"icon\" href=\"data:,\">");
						
						// CSS to style the on/off buttons 
						// Feel free to change the background-color and font-size attributes to fit your preferences
						//client.println("<style>html { font-family: Helvetica; display: inline-block; margin: 0px auto; text-align: left;}");
						//client.println(".button { background-color: #195B6A; border: none; color: white; padding: 16px 40px;");
						//client.println("text-decoration: none; font-size: 30px; margin: 2px; cursor: pointer;}");
						//client.println(".button2 {background-color: #77878A;}</style></head>");
						
						// Web Page Heading
						client.println("<body>");
						client.println("<h1>Node :");
					#	ifdef NODEID
						client.println(NODEID);
					#	else
						client.println("Unnamed");
					#	endif
						client.println("</h1>");
						client.println("<p>IP Address:");

					#	ifdef IPADDR
						char cstr[16];
						
						sprintf(cstr, "%d.%d.%d.%d", ip[0], ip[1], ip[2], ip[3]);
						client.println(cstr);
					#	else
						client.println("-");
					#	endif
						client.println("</p>");

						client.println("<p>I2C Scan : " + sScanResult + "</p>");

						if(mpu.isConnectedAccelGyro())
						{
							client.println("<p>MPU : Active</p>");
						}
						else
						{
							client.println("<p>MPU : Not Found</p>");
						}

						// Display current state, and ON/OFF buttons for BUILTIN_LED  
						client.println("<p>Roll : " + String(nRoll, DEC) + "</p>");
						client.println("<p>Pitch : " + String(nPitch, DEC) + "</p>");
						client.println("<p>Yaw : " + String(nYaw, DEC) + "</p>");
						client.println("<p>Battery : " + String(bBattPercentage, DEC) + "%</p>");
						
						client.println("</body></html>");
						
						// The HTTP response ends with another blank line
						client.println();
						
						// turns the GPIOs on and off
						if (header.indexOf("GET /calibrate") >= 0)
						{
							//Serial.println("BUILTIN_LED on");
							mpu.calibrateAccelGyro();
							//digitalWrite(LED_BUILTIN, HIGH);
						} 
						else if (header.indexOf("GET /restart") >= 0)
						{
							ESP.restart();
						}

						// Break out of the while loop
						break;
					}
					else // if you got a newline, then clear currentLine
					{
						currentLine = "";
					}
				}
				else if (c != '\r')  // if you got anything else but a carriage return character,
				{
					currentLine += c;      // add it to the end of the currentLine
				}
			}
		}

		// Clear the header variable
		header = "";

		// Close the connection
		client.stop();

		digitalWrite(LED_BUILTIN, HIGH);
	}
}

void postRequest()
{
	String server = "http://192.168.4.1/";
	String message =	"update?nod="	+ String(NODEID) + 
						"&rol="			+ String(nRoll, DEC) + 
						"&pit="			+ String(nPitch, DEC) +
						"&yaw="			+ String(nYaw, DEC) +
						"&bat=" 		+ String(bBattPercentage, DEC);

	HTTPClient http;
	http.begin(server + message);
	http.addHeader("Content-Type", "text/plain");

	// Send HTTP GET request
    http.GET();

	http.end();
}

void compassCalibration()
{
	int x, y, z;
	
	// Read compass values
	compass.readRaw();

	// Return XYZ readings
	x = compass.getX();
	y = compass.getY();
	z = compass.getZ();

	changed = false;

	if(x < calibrationData[0][0]) {
		calibrationData[0][0] = x;
		changed = true;
	}
  	if(x > calibrationData[0][1]) {
		calibrationData[0][1] = x;
		changed = true;
	}

  	if(y < calibrationData[1][0])
  	{
		calibrationData[1][0] = y;
		changed = true;
  	}
  	if(y > calibrationData[1][1])
  	{
		calibrationData[1][1] = y;
		changed = true;
  	}
	
  	if(z < calibrationData[2][0])
  	{
		calibrationData[2][0] = z;
		changed = true;
  	}
  	if(z > calibrationData[2][1])
  	{
		calibrationData[2][1] = z;
		changed = true;
	}

	if (changed && !done)
	{
		//Serial.println("CALIBRATING... Keep moving your sensor around.");
		c = millis();
	}
	t = millis();
  
  
	if ( (t - c > 5000) && !done)
	{
		done = true;

#	if 0
		Serial.println("DONE. Copy the line below and paste it into your projects sketch.);");
		Serial.println();

		Serial.print("compass.setCalibration(");
		Serial.print(calibrationData[0][0]);
		Serial.print(", ");
		Serial.print(calibrationData[0][1]);
		Serial.print(", ");
		Serial.print(calibrationData[1][0]);
		Serial.print(", ");
		Serial.print(calibrationData[1][1]);
		Serial.print(", ");
		Serial.print(calibrationData[2][0]);
		Serial.print(", ");
		Serial.print(calibrationData[2][1]);
		Serial.println(");");
#	endif
	}
}

void loop()
{
	checkUpdateRequest();
	checkClientRequest();

	if (mpu.update())
	{
		// mpu.printRollPitchYaw();

		if(nSample < TOTAL_SAMPLE)
		{
			nSampleRoll	+= mpu.getRoll();
			nSamplePitch += mpu.getPitch();
			nSampleYaw += mpu.getYaw();

			nSample++;
		}
		else
		{
			nRoll = (nSampleRoll / TOTAL_SAMPLE);
			nPitch = (nSamplePitch / TOTAL_SAMPLE);
			nYaw = (nSampleYaw / TOTAL_SAMPLE);

			nSampleRoll = 0;
			nSamplePitch = 0;
			nSampleYaw = 0;
			nSample = 0;
		}
	}

	if(WiFi.status() != WL_CONNECTED)
	{
		if(millis() - dwMillis > dwTrgMillis)
		{
			if(bLedState)
			{
				digitalWrite(LED_BUILTIN, HIGH);
				dwTrgMillis = 500;
				bLedState = false;

				if(bRetryCount >= 20)
				{
					bRetryCount = 0;
					ESP.restart();
				}
				else if(bRetryCount >= 20)
				{
					if (bConnState) 
					{
						wifiConnect();
					}
					else
					{
						wifiConnect();
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
	else
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

				if(bConnCount == 3)
				{
					nBatt = battCheck();
					bBattPercentage= battLevel(nBatt);

					postRequest();
				}

				if(bConnCount > 6)
				{
					bConnCount = 0;
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

	delay(1);
}
#else

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

enum nodeEnum
{
	NODE_ID = 0,
	NODE_ROL,
	NODE_PIT,
	NODE_YAW,
	NODE_BAT
};

enum owasEnum
{
	OWAS_BACK = 0,
	OWAS_HAND,
	OWAS_LEG,
	OWAS_LOAD,
	OWAS_LEVEL,
};

// Replace with your network credentials
const char* ssid     = "ESP32 BLE";
const char* password = "12345678";

// BLE Update Timer
const unsigned long ulPacketDelay = 15000;
const unsigned long ulNodeDelay = 1000;
unsigned long ulDelay = ulPacketDelay;
unsigned long ulLastTimer = 0;
int nodeIndex = 0;

// Set web server port number to 80
WiFiServer server(80);

BLECharacteristic *pCharacteristic;
bool bleDeviceConnected = false;

String nodeData[8][6];

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
						client.println("<body><p>OK</p></body></html>");
						
						// The HTTP response ends with another blank line
						client.println();
						// Serial.println(header);

						// Process client get request
						int index[] = {	header.indexOf("nod="),
										header.indexOf("rol="),
										header.indexOf("pit="),
										header.indexOf("yaw="),
										header.indexOf("bat="),
										header.indexOf("HTTP/1.1"),
									};
						
						int nodeId = header.substring(index[0] + 4, index[1] - 1).toInt();

						nodeData[nodeId][0] = String((nodeId + 1), DEC);
						nodeData[nodeId][1] = header.substring(index[1] + 4, index[2] - 1);
						nodeData[nodeId][2] = header.substring(index[2] + 4, index[3] - 1);
						nodeData[nodeId][3] = header.substring(index[3] + 4, index[4] - 1);
						nodeData[nodeId][4] = header.substring(index[4] + 4, index[5] - 1);
						nodeData[nodeId][5] = "0";
						
						//Serial.println();
						Serial.print("Node = ");
						Serial.println(nodeData[nodeId][0]);
						Serial.print("Roll = ");
						Serial.println(nodeData[nodeId][1]);
						Serial.print("Pitch = ");
						Serial.println(nodeData[nodeId][2]);
						Serial.print("Yaw = ");
						Serial.println(nodeData[nodeId][3]);
						Serial.print("Batt = ");
						Serial.println(nodeData[nodeId][4]);
						Serial.println("------------------------");

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

void owasJudgement()
{
	nodeData[ID_OWAS][0] = "1";
	nodeData[ID_OWAS][1] = "1";
	nodeData[ID_OWAS][2] = "1"; 
	nodeData[ID_OWAS][3] = "1"; 
	nodeData[ID_OWAS][4] = "1";
	nodeData[ID_OWAS][5] = "1";
}

void setup() {
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
}

void loop() 
{
	int i = 0;
	String sNodeData;
	char txString[20] = "";

	// Listen for incoming clients
	clientCheck(server.available());

	if (bleDeviceConnected) 
	{
		if(millis() - ulLastTimer > ulDelay)
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

			ulDelay = ulNodeDelay;
		
			nodeIndex++;
			if(nodeIndex > ID_END - 1)
			{
				ulDelay = ulPacketDelay;
				nodeIndex = 0;
			}

			ulLastTimer = millis();
		}
	}
}
#endif