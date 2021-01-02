/*
  Calibrate HMC5883L. Output for HMC5883L_calibrate_processing.pde
  Read more: http://www.jarzebski.pl/arduino/czujniki-i-sensory/3-osiowy-magnetometr-hmc5883l.html
  GIT: https://github.com/jarzebski/Arduino-HMC5883L
  Web: http://www.jarzebski.pl
  (c) 2014 by Korneliusz Jarzebski
*/

#include <Arduino.h>
#include <Wire.h>
#include "EasyOta.h"
#include "MPU9250.h"

//#define CALIBRATE_COMPASS

#define LED01	D3		//GPIO00
#define LED02	D4		//GPIO02
#define BTN01	D0		//GPIO16
#define BTN02	D5		//GPIO14

const char WIFI_NAME[] = "ibnubin.studio";
const char WIFI_PW[] = "bismillah90";

WiFiServer server(80);

IPAddress IP(192,168,0,110);
IPAddress NETMASK(255,255,255,0);
IPAddress NETWORK(192,168,0,1);
IPAddress DNS(192,168,0,1);

String header;
String LED_BUILTIN_State = "off";

unsigned long currentTime = millis();
unsigned long previousTime = 0; 
const long timeoutTime = 2000;

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

int calibrationData[3][2];
bool changed = false;
bool done = false;
int t = 0;
int c = 0;

void setup()
{
	pinMode(LED_BUILTIN, OUTPUT);
	pinMode(LED01, OUTPUT);
	pinMode(LED02, OUTPUT);
	pinMode(BTN01, INPUT);
	pinMode(BTN02, INPUT);

	digitalWrite(LED01, HIGH);
	digitalWrite(LED02, HIGH);
	//digitalWrite(BTN01, HIGH);
	//digitalWrite(BTN02, HIGH);

	Wire.begin();
	delay(2000);

	mpu.setup(0x68);  // change to your own address

	  mpu.calibrateAccelGyro();
	  //mpu.calibrateMag();

	mpu.setupMag();

	delay(500);
	
	WiFi.mode(WIFI_STA); 
	WiFi.begin(WIFI_NAME, WIFI_PW);

	while (WiFi.waitForConnectResult() != WL_CONNECTED);

  	WiFi.config(IP, NETWORK, NETMASK, DNS);

	server.begin();

	EasyOta.setup();
}

void CheckUpdateRequest()
{
	EasyOta.checkForUpload();
}

void checkClientRequest()
{
	WiFiClient client = server.available();   // Listen for incoming clients

	if(client)  // If a new client connects,
	{
		digitalWrite(LED02, LOW);
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
						
						// turns the GPIOs on and off
						if (header.indexOf("GET /on") >= 0)
						{
							//Serial.println("BUILTIN_LED on");
							LED_BUILTIN_State = "on";
							//digitalWrite(LED_BUILTIN, HIGH);
						} 
						else if (header.indexOf("GET /off") >= 0)
						{
							//Serial.println("BUILTIN_LED off");
							LED_BUILTIN_State = "off";
							//digitalWrite(LED_BUILTIN, LOW);
						}
						
						// Display the HTML web page
						client.println("<!DOCTYPE html><html>");
						client.println("<head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">");
						client.println("<link rel=\"icon\" href=\"data:,\">");
						
						// CSS to style the on/off buttons 
						// Feel free to change the background-color and font-size attributes to fit your preferences
						client.println("<style>html { font-family: Helvetica; display: inline-block; margin: 0px auto; text-align: left;}");
						client.println(".button { background-color: #195B6A; border: none; color: white; padding: 16px 40px;");
						client.println("text-decoration: none; font-size: 30px; margin: 2px; cursor: pointer;}");
						client.println(".button2 {background-color: #77878A;}</style></head>");
						
						// Web Page Heading
						client.println("<body><h1>ESP8266 Sensor Node</h1>");
						client.println("<h2>Node ID: Upper Left Hand</h2>");
						
						// Display current state, and ON/OFF buttons for BUILTIN_LED  
						client.println("<p>BUILTIN_LED - State " + LED_BUILTIN_State + "</p>");

						// If the LED_BUILTIN_State is off, it displays the ON button
						if (LED_BUILTIN_State=="off")
						{
							client.println("<p><a href=\"/on\"><button class=\"button\">Refresh</button></a></p>");
						}
						else
						{
							client.println("<p><a href=\"/off\"><button class=\"button button2\">Refresh</button></a></p>");
						}
						
						// Display current state, and ON/OFF buttons for BUILTIN_LED  
						client.println("<p>Roll : " + String(nRoll, DEC) + "</p>");
						client.println("<p>Pitch : " + String(nPitch, DEC) + "</p>");
						client.println("<p>Yaw : " + String(nYaw, DEC) + "</p>");
						client.println("<p>Battery : " + String(70, DEC) + "</p>");
						
						client.println("</body></html>");
						
						// The HTTP response ends with another blank line
						client.println();
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
		//Serial.println("Client disconnected.");
		//Serial.println("");

		digitalWrite(LED02, HIGH);
	}
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
		//Serial.println("DONE. Copy the line below and paste it into your projects sketch.);");
		//Serial.println();

		//Serial.print("compass.setCalibration(");
		//Serial.print(calibrationData[0][0]);
		//Serial.print(", ");
		//Serial.print(calibrationData[0][1]);
		//Serial.print(", ");
		//Serial.print(calibrationData[1][0]);
		//Serial.print(", ");
		//Serial.print(calibrationData[1][1]);
		//Serial.print(", ");
		//Serial.print(calibrationData[2][0]);
		//Serial.print(", ");
		//Serial.print(calibrationData[2][1]);
		//Serial.println(");");
	}
}

void loop()
{
	CheckUpdateRequest();
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
			digitalWrite(LED01, LOW);
			
			nRoll = (nSampleRoll / TOTAL_SAMPLE);
			nPitch = (nSamplePitch / TOTAL_SAMPLE);
			nYaw = (nSampleYaw / TOTAL_SAMPLE);

			nSampleRoll = 0;
			nSamplePitch = 0;
			nSampleYaw = 0;
			nSample = 0;

			delay(50);
			digitalWrite(LED01, HIGH);
		}
	}

	delay(1);
}