#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include "prototypes.h"
#include "definitions.h"
#include "variables.h"

#define USE_JSON

WiFiServer server(80);

void webserver_init()
{
	server.begin();
}

void webserver_commandCheck(String cmd)
{
    if(cmd.indexOf(CMD_WAIT) > 0 )
	{
		/* wait... */
	}
	else if (cmd.indexOf(CMD_CALIBRATE) > 0)
	{
		sensor_calibGyro();
	}
	else if (cmd.indexOf(CMD_RESTART) > 0)
	{
		ESP.restart();
	}
	else if (cmd.indexOf(CMD_DISCONNECT) > 0)
	{	
		wifi_disconnect();
	}
	else
	{
		wifi_disconnect();
	}
}

#if 0
void webserver_createJsonDoc(WiFiClient &client)
{
	StaticJsonDocument<10000> doc;
	int i;

	doc["id"] = NODEID;
	doc["batt"] = bBatt;

	JsonArray datar = doc.createNestedArray("roll");
	for(i = nDataCount - 1; i >= 0; i--)
	{
		datar.add(nRollData[i]);
	}
	for(i = nDataMax - 1; i > nDataCount; i--)
	{
		datar.add(nRollData[i]);
	}

	JsonArray datap = doc.createNestedArray("pitch");
	for(i = nDataCount; i >= 0; i--)
	{
		datap.add(nPitchData[i]);
	}
	for(i = nDataMax - 1; i > nDataCount; i--)
	{
		datap.add(nPitchData[i]);
	}

	JsonArray datay = doc.createNestedArray("yaw");
	for(i = nDataCount; i >= 0; i--)
	{
		datay.add(nYawData[i]);
	}
	for(i = nDataMax - 1; i > nDataCount; i--)
	{
		datay.add(nYawData[i]);
	}

	doc["rmov"] = (dwRollMov);
	doc["pmov"] = (dwPitchMov);

	serializeJsonPretty(doc, client);
}
#endif

void  webserver_checkClientRequest()
{
	WiFiClient client = server.available();

	if(client)
	{
		unsigned long currentTime = 0;
		unsigned long previousTime = 0;

		String currentLine;
		String header; 
		
		currentTime = millis();
		previousTime = currentTime;

	#	ifdef ESP32_DEF
		digitalWrite(LED_BUILTIN, HIGH);
	#	else
		digitalWrite(LED_BUILTIN, LOW);
	#	endif
		
		while (client.connected() && currentTime - previousTime <= timeoutTime)
		{
			currentTime = millis();         
			
			if (client.available())
			{
				char c = client.read();
				Serial.write(c);
				header += c;
				
				if (c == '\n')
				{				
					if (currentLine.length() == 0)
					{
						// HTTP headers always start with a response code (e.g. HTTP/1.1 200 OK)
						// and a content-type so the client knows what's coming, then a blank line:
						client.println("HTTP/1.1 200 OK");
					#	if defined(USE_JSON)
						client.println("Content-Type: application/json");
					#	else
						client.println("Content-type:text/html");
					#	endif
						client.println();
						
						if (header.indexOf("dummy") >= 0) 
						{
							//...do nothing
						}
					#ifdef ALARM_SUPPORT
						else if (header.indexOf("alert1") >= 0) 
						{
							bAlertCount = 0;
						}
						else if (header.indexOf("alert2") >= 0) 
						{
							bAlertCount = 1;
							bAlertState = true;
							ulAlertTimer = millis();
						}
						else if (header.indexOf("alert3") >= 0) 
						{
							bAlertCount = 2;
							bAlertState = true;
							ulAlertTimer = millis();
						}
						else if (header.indexOf("alert4") >= 0) 
						{
							bAlertCount = 3;
							bAlertState = true;
							ulAlertTimer = millis();
						}
					#endif
						else
						{
					#	if defined(USE_JSON)
							//webserver_createJsonDoc(client);
							jsonDocPrint(client);
					#	else
							// Display the HTML web page
							client.println("<!DOCTYPE html><html>");
							client.println("<head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">");
							client.println("<link rel=\"icon\" href=\"data:,\">");
							
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
							client.println(IPADDR);
						#	else
							client.println("-");
						#	endif
							client.println("</p>");

							//client.println("<p>I2C Scan : " + sScanResult + "</p>");

							if(sensor_checkConnection())
							{
								client.println("<p>MPU : Active</p>");
							}
							else
							{
								client.println("<p>MPU : Not Found</p>");
							}

							client.println("<p>Roll : "			+ String(nRoll, DEC)		+ "</p>");
							client.println("<p>Pitch : "		+ String(nPitch, DEC)		+ "</p>");
							client.println("<p>Yaw : "			+ String(nYaw, DEC)			+ "</p>");
							client.println("<p>Battery : "		+ String(bBatt, DEC)		+ "%</p>");
							client.println("<p>Roll Diff : "	+ String(dwRollMov, DEC)	+ "</p>");
							client.println("<p>Pitch Diff : "	+ String(dwPitchMov, DEC)	+ "</p>");
							
							client.println("</body></html>");
						
							// The HTTP response ends with another blank line
							client.println();
					#	endif
						}
						
						/*
						if (header.indexOf("GET /calibrate") >= 0)
						{
							webserver_commandCheck(CMD_CALIBRATE);
						} 
						else if (header.indexOf("GET /restart") >= 0)
						{
							webserver_commandCheck(CMD_RESTART);
						}
						else if (header.indexOf("GET /disconnect") >= 0)
						{
							webserver_commandCheck(CMD_DISCONNECT);
						}
						*/

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

		// Clear the header variable
		header = "";

		// Close the connection
		client.stop();


	#	ifdef ESP32_DEF
		digitalWrite(LED_BUILTIN, LOW);
	#	else
		digitalWrite(LED_BUILTIN, HIGH);
	#	endif
	}
}

String webserver_prePostRequest(String sNodeId)
{
	String payload;
	int httpCode;

	String server = "http://192.168.4.1/";
	String message = "connect?nod="	+ sNodeId;

	HTTPClient http;
	http.begin(server + message);
	http.addHeader("Content-Type", "text/plain");

	// Send HTTP GET request
    httpCode = http.GET();

	if (httpCode > 0)
	{
		//Check the returning code
        payload = http.getString();   //Get the request response payload
    }

	http.end();

	/* webserver_commandCheck(payload); */

	return payload;
}

String webserver_getRequest(String sNodeId, int nRoll, int nPitch, int nYaw, long dwRollMov, long dwPitchMov, byte bBatt, String others)
{
	String payload;
	int httpCode;

	String server = "http://192.168.4.1/";
	String message =	"update?nod="	+ sNodeId + 
						"&rol="			+ String(nRoll, DEC) + 
						"&pit="			+ String(nPitch, DEC) +
						"&yaw="			+ String(nYaw, DEC) +
						"&mro="			+ String(dwRollMov, DEC) +
						"&mpi="			+ String(dwPitchMov, DEC) +
						"&bat=" 		+ String(bBatt, DEC);

	if(others != "")
	{
		message += others;
	}

	HTTPClient http;
	http.begin(server + message);
	http.addHeader("Content-Type", "text/plain");

	// Send HTTP GET request
    httpCode = http.GET();

	if (httpCode > 0)
	{
		//Check the returning code
        payload = http.getString();   //Get the request response payload
    }

	http.end();

	/* webserver_commandCheck(payload); */

	return payload;
}