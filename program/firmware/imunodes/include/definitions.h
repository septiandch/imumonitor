#ifndef DEFINITIONS_H
#define DEFINITIONS_H

/*---------------------------------------*/
/* Define Options                        */
/*---------------------------------------*/

//#define CALIBRATE_COMPASS


/*---------------------------------------*/
/* Parameters                            */
/*---------------------------------------*/

#ifndef NODEID
#	define NODEID	    "-"
#endif

#define VIN_MAX		    6
#define ADC_RESO	    1023

#define WIFI_TIMEOUT    5000
#define RETRY_TIMEOUT   10

#define CMD_NONE		"cmd=none"
#define CMD_OK		    "cmd=ok"
#define CMD_WAIT		"cmd=wait"
#define CMD_CALIBRATE   "cmd=calibrate"
#define CMD_RESTART     "cmd=restart"
#define CMD_DISCONNECT  "cmd=disconnect"

#define TICK_DEFAULT	1000
#define TICK_RETRY  	200
#define TICK_WAIT   	2000

#define SUBSTRACTOR		1

/*---------------------------------------*/
/* GPIO                                  */
/*---------------------------------------*/

#define LED01		    D3		//GPIO00
#define LED02		    D4		//GPIO02
#define BTN01		    D0		//GPIO16
#define BTN02		    D5		//GPIO14
#define BAT_EN		    D6		//GPIO12
#define BAT_CH		    A0		//ADC

/* ESP32 */
#define PIN_BUZZER		D3
#define PIN_VIBRATOR	D4

/*---------------------------------------*/
/* WiFi Parameters                       */
/*---------------------------------------*/

#define DEFAULT_IP      192,168,4,111
#define DEFAULT_NETMSK  255,255,255,0

#ifndef DUMMY_FLG
#define DEFAULT_NETWRK 	192,168,4,1
#define DEFAULT_DNS   	192,168,4,1
#else
#define DEFAULT_NETWRK 	192,168,4,1
#define DEFAULT_DNS   	192,168,4,1
#endif

#endif  /* DEFINITIONS_H */