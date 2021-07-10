#include <Arduino.h>
#include <Wire.h>
#include "definitions.h"
#include "prototypes.h"

bool bLedState = false;

unsigned long dwLedTickCount = 0;
unsigned long dwLedTickComp = 0;

eNODESTATE eLedMode = eNODE_DISCONNECTED;

void gpio_pinInit()
{
#ifdef ESP32_DEF
	pinMode(LED_BUILTIN, OUTPUT);
	pinMode(PIN_BUZZER, OUTPUT);
	pinMode(PIN_VIBRATOR, OUTPUT);

	digitalWrite(PIN_BUZZER, LOW);
	digitalWrite(PIN_VIBRATOR, LOW);
#else
	pinMode(LED_BUILTIN, OUTPUT);
	pinMode(BAT_EN, OUTPUT);

	digitalWrite(LED_BUILTIN, LOW);
	digitalWrite(BAT_EN, LOW);
#endif

	gpio_i2cInit();
}

int gpio_battCheck()
{
	int value = 0;

#ifdef ESP32_DEF
	// ...do nothing
#else
	digitalWrite(BAT_EN, HIGH);
	delay(100);

	value = (int)(((float)(analogRead(BAT_CH) * VIN_MAX) / ADC_RESO) * 100);

	digitalWrite(BAT_EN, LOW);
#endif

	return value;
}

void gpio_i2cInit()
{
	Wire.begin();
	delay(2000);

	i2cScan();

	sensor_init();
}

void gpio_led(byte state)
{
#ifdef ESP32_DEF
	if(state == LOW)
	{
		digitalWrite(LED_BUILTIN, LOW);
	}
	else
	{
		digitalWrite(LED_BUILTIN, HIGH);
	}
#else
	if(state == LOW)
	{
		digitalWrite(LED_BUILTIN, HIGH);
	}
	else
	{
		digitalWrite(LED_BUILTIN, LOW);
	}
#endif
}

void gpio_ledBlink(eNODESTATE mode)
{
	if(dwLedTickCount++ > dwLedTickComp)
	{
		if(bLedState)
		{
			gpio_led(LOW);
			dwLedTickComp = nDelayPatternOff[mode];
		}
		else
		{
			gpio_led(HIGH);
			dwLedTickComp = nDelayPatternOn[mode];
		}

		bLedState = !bLedState;
		
		dwLedTickCount = 0;
	}
}