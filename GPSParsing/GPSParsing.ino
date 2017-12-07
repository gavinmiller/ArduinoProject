// Disclaimer!! Main bulk of code from Adafruit gps library.
// Most comments are ours though.

// Importing the Adafruit GPS libraries
#include <Adafruit_GPS.h>
#include <SoftwareSerial.h>

// Opening the connections on the Arduino
SoftwareSerial mySerial(3, 2);
Adafruit_GPS GPS(&mySerial);

// Activating the debugger/serial monitor in order to monitor the coordinates and data received from the gps
#define GPSECHO  true

// This keeps track of whether we're using the interrupt
// off by default!
boolean usingInterrupt = false;
void useInterrupt(boolean); // Func prototype keeps Arduino 0023 happy // (Me) Probably not necessary in this version of Arduino but will leave on for safekeeping...

// Run once on startup
void setup()  
{
    
  // Connect at 115200 (baud rate) so we can read the GPS fast enough and echo without dropping characters
  Serial.begin(115200);
  Serial.println("Adafruit GPS library basic test!");

  // 9600 NMEA is the default baud rate for Adafruit MTK GPS's- some use 4800
  GPS.begin(9600);
  
  // Next line turns on RMC (recommended minimum) and GGA (fix data) including altitude // May switch to minimum recommended
  GPS.sendCommand(PMTK_SET_NMEA_OUTPUT_RMCGGA);
  
  // uncomment next line to restrict to the "minimum recommended" data
  //GPS.sendCommand(PMTK_SET_NMEA_OUTPUT_RMCONLY);
  
  // Set the update rate to 1HZ (1 update per second)
  GPS.sendCommand(PMTK_SET_NMEA_UPDATE_1HZ);   

  // Request updates on antenna status, comment out to keep quiet, but will be left on now to figure out when the antenna comes online
  GPS.sendCommand(PGCMD_ANTENNA);

  // Activate the 'timer0' interrupt to check for data and store it in order to not clutter up loop and make sure the rest of the  
  // code runs whilst the loop function is running! Called once a millisecond as stated below.
  useInterrupt(true);

  delay(1000);
  // Ask for firmware version
  mySerial.println(PMTK_Q_RELEASE);
}


// Interrupt is called once a millisecond, looks for any new GPS data, and stores it
SIGNAL(TIMER0_COMPA_vect) {
  char c = GPS.read();

#ifdef UDR0
  if (GPSECHO)
  {
    if (c)
    {
      UDR0 = c;  
    }
    // writing direct to UDR0 is much much faster than Serial.print 
    // but only one character can be written at a time. 
  }
#endif
}

void useInterrupt(boolean v) {
  if (v) {
    // Timer0 is already used for millis() - we'll just interrupt somewhere
    // in the middle and call the "Compare A" function above
    OCR0A = 0xAF;
    TIMSK0 |= _BV(OCIE0A);
    usingInterrupt = true;
  } else {
    // do not call the interrupt function COMPA anymore
    TIMSK0 &= ~_BV(OCIE0A);
    usingInterrupt = false;
  }
}

uint32_t timer = millis();

// One iteration every frame
void loop()
{
  // If interrupt is disabled, this conditional will handle dealing with the queries by hand.
  if (! usingInterrupt) {
    // read data from the GPS in the 'main loop'
    char c = GPS.read();

    // Checks to see if debugging/printing to serial monitor is activated, if so print data character by character. (If there is a 
    // character to be printed)
    if (GPSECHO)
      if (c) 
      {
        {
          Serial.print(c);
        }
      }
  }
  
  // if a sentence(GPS data) is received, we can check the checksum, parse it...
  if (GPS.newNMEAreceived()) {
    // a tricky thing here is if we print the NMEA sentence, or data
    // we end up not listening and catching other sentences! 
    // so be very wary if using OUTPUT_ALLDATA and trytng to print out data
    //Serial.println(GPS.lastNMEA());   // this also sets the newNMEAreceived() flag to false
  
    if (!GPS.parse(GPS.lastNMEA()))   // this also sets the newNMEAreceived() flag to false
      return;  // we can fail to parse a sentence in which case we should just wait for another
  }

  // if millis() or timer wraps around, we'll just reset it
  if (timer > millis())
  {
    timer = millis();
  }

  // approximately every 2 seconds or so, print out the current stats
  if (millis() - timer > 2000) 
  { 
    timer = millis(); // reset the timer
    
    Serial.print("\nTime: ");
    Serial.print(GPS.hour, DEC); Serial.print(':');
    Serial.print(GPS.minute, DEC); Serial.print(':');
    Serial.print(GPS.seconds, DEC); Serial.print('.');
    Serial.println(GPS.milliseconds);
    Serial.print("Date: ");
    Serial.print(GPS.day, DEC); Serial.print('/');
    Serial.print(GPS.month, DEC); Serial.print("/20");
    Serial.println(GPS.year, DEC);
    Serial.print("Fix: "); Serial.print((int)GPS.fix);
    Serial.print(" quality: "); Serial.println((int)GPS.fixquality); 
    if (GPS.fix) 
    {
      // The issue was whether or not to use latitude and longitude as is or convert to degrees, we decided to use the degrees version
      // below.
      Serial.print("Location: ");
      Serial.print(GPS.latitude, 4); Serial.print(GPS.lat);
      Serial.print(", "); 
      Serial.print(GPS.longitude, 4); Serial.println(GPS.lon);
      
      // Could implement use of control characters here as well to make finding specific coordinates for Google Maps easier,
      // but I like to complicate things. However, in Processing, I added a static string called 'coordinateLocation'.
      // If implementing a control character instead is completely necessary, you can just change what's in that string to what is
      // replaced with here. Program should continue to work fine.
      Serial.print("Location (in degrees, works with Google Maps): "); 
      
      Serial.print(GPS.latitudeDegrees, 4);
      Serial.print(", "); // Could remove space to make things easier in Processing....
      Serial.println(GPS.longitudeDegrees, 4);
      
      Serial.print("Speed (knots): "); Serial.println(GPS.speed);
      Serial.print("Angle: "); Serial.println(GPS.angle);
      Serial.print("Altitude: "); Serial.println(GPS.altitude);
      Serial.print("Satellites: "); Serial.println((int)GPS.satellites);
    }

    Serial.println("#"); // Control character to show end of data, for processing to communicate and grab coordinates
  }
}
