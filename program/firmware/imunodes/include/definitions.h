#ifndef DEFINITIONS_H
#define DEFINITIONS_H

#ifndef ESPRESSIF32

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

#define WIFI_TIMEOUT    3000
#define RETRY_TIMEOUT   20

#define CMD_NONE		"cmd=none"
#define CMD_WAIT		"cmd=wait"
#define CMD_CALIBRATE   "cmd=calibrate"
#define CMD_RESTART     "cmd=restart"
#define CMD_DISCONNECT  "cmd=disconnect"

#define TICK_TIMEOUT	2500

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


/*---------------------------------------*/
/* WiFi Parameters                       */
/*---------------------------------------*/

#define DEFAULT_IP      192,168,4,111
#define DEFAULT_NETMSK  255,255,255,0

#ifndef DUMMY_FLG
#define DEFAULT_NETWRK 	192,168,4,1
#define DEFAULT_DNS   	192,168,4,1
#else
#define DEFAULT_NETWRK 	192,168,0,1
#define DEFAULT_DNS   	192,168,0,1
#endif

#endif /* ESPRESSIF32 */

#endif  /* DEFINITIONS_H */