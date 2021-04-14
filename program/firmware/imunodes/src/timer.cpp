#include "prototypes.h"
#include "Ticker.h"

Ticker systick(NULL, 0, 0, MILLIS);

void timer_init(void (&callBackFunc)(), int period)
{
    systick = Ticker(callBackFunc, period, 0, MILLIS);

    systick.start();
}

void timer_update()
{
    systick.update();
}