#include <Wire.h>
#include "prototypes.h"
#ifdef USE_MPU9250
#	include "MPU9250.h"
#else
#	include "MPU9250_mod.h"
#endif


#ifdef USE_MPU9250
MPU9250 mpu;
#else
MPU6500 mpu;
QMC5883L compass;
#endif

// Variables for Calibration
bool changed = false;
bool done = false;
int calibrationData[3][2];
int t = 0;
int c = 0;

// Sampling Values
int nSample			= 0;
int nSampleRoll		= 0;
int nSamplePitch	= 0;
int nSampleYaw		= 0;

// Current Rotation Values
int nCurrentRoll	= 0;
int nCurrentPitch	= 0;
int nCurrentYaw		= 0;

// Previous Rotation Values
int nPreviousRoll	= 0;
int nPreviousPitch	= 0;
int nPreviousYaw	= 0;

void sensor_init()
{
	mpu.setup(0x68);

	//mpu.calibrateAccelGyro();
	//mpu.calibrateMag();

#ifndef USE_MPU9250
	mpu.setupMag();
#endif
}

bool sensor_checkConnection()
{
#ifdef USE_MPU9250
	return mpu.isConnected();
#else
	return mpu.isConnectedAccelGyro();
#endif
}

void sensor_calibCompass()
{
#ifndef USE_MPU9250
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
#endif
}

void sensor_calibGyro() 
{
	mpu.calibrateAccelGyro();
}

bool sensor_checkForUpdates()
{
    bool bRetVal = false;

    if (mpu.update())
	{
		bRetVal = true;
	}

    return bRetVal;
}

void sensor_getData(int *roll, int *pitch, int *yaw, long *rollMov, long *pitchMov)
{
    if(sensor_checkForUpdates())
    {
        // mpu.printRollPitchYaw();

		if(nSample < TOTAL_SAMPLE)
		{
			nCurrentRoll = mpu.getRoll();
			nCurrentPitch = mpu.getPitch();
			nCurrentYaw = mpu.getYaw();

			nSampleRoll += nCurrentRoll;
			nSamplePitch += nCurrentPitch;
			nSampleYaw += nCurrentYaw;
			
			if(abs(nCurrentRoll) >= nPreviousRoll)
			{
				*rollMov += abs(nCurrentRoll) - nPreviousRoll;
			}
			else
			{
				*rollMov += nPreviousRoll - abs(nCurrentRoll);
			}

			if(abs(nCurrentPitch) >= nPreviousPitch)
			{
				*pitchMov += abs(nCurrentPitch) - nPreviousPitch;
			}
			else
			{
				*pitchMov += nPreviousPitch - abs(nCurrentPitch);
			}

			nPreviousRoll = abs(nCurrentRoll);
			nPreviousPitch = abs(nCurrentPitch);
			nPreviousYaw = abs(nCurrentYaw);

			nSample++;
		}
		else
		{
			*roll = (nSampleRoll / TOTAL_SAMPLE);
			*pitch = (nSamplePitch / TOTAL_SAMPLE);
			*yaw = (nSampleYaw / TOTAL_SAMPLE);

			nSampleRoll = 0;
			nSamplePitch = 0;
			nSampleYaw = 0;
			nSample = 0;
		}
    }
}