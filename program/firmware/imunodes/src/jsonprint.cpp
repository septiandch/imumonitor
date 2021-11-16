#include "prototypes.h"

void jsonPrintStart(WiFiClient &s)
{
    s.println("{");
}

void jsonPrintEnd(WiFiClient &s)
{
    s.println("  \"end\": \"end\"");
    s.print("}");
}

void jsonPrintItem(WiFiClient &s, String name, int value)
{
    s.print("  \"");
    s.print(name);
    s.print("\": \"");
    s.print(value, DEC);
    s.println("\",");
}

void jsonPrintArray(WiFiClient &s, String name, int* ptr, int size)
{
    int i;

    s.print("  \"");
    s.print(name);
    s.println("\": [");

    for(i = size - 1; i >= 0; i--)
    {
        s.print("    ");
        s.print(ptr[i], DEC);
        
        if(i > 0)
        {
            s.println(",");
        }
        else
        {
            s.println();
        }
    }

    s.println("  ],");
}

void jsonPrintArrayCustom(WiFiClient &s, String name, int* ptr, int start, int size)
{
    int i;

    s.print("  \"");
    s.print(name);
    s.println("\": [");

    for(i = start - 1; i >= 0; i--)
    {
        s.print("    ");
        s.print(ptr[i], DEC);
        s.println(",");
    }

    for(i = size - 1; i > start; i--)
    {
        s.print("    ");
        s.print(ptr[i], DEC);
        
        if(i > start + 1)
        {
            s.println(",");
        }
        else
        {
            s.println();
        }
    }

    s.println("  ],");
}