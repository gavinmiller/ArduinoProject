// Initiates GPS tracking and logs to SD card.

// Importing the Adafruit GPS libraries
#include <Adafruit_GPS.h>
#include <SoftwareSerial.h>
#include <SD.h> //Load SD card library
#include<SPI.h> //Load SPI Library
 
 
String NMEA1; //Variable for first NMEA sentence
String NMEA2; //Variable for second NMEA sentence
char c; //to read characters coming from the GPS
 
int chipSelect = 4; //chipSelect pin for the SD card Reader
File mySensorData; //Data object you will write your sesnor data to
 
 
// Opening the connections on the Arduino
SoftwareSerial mySerial(3, 2);
Adafruit_GPS GPS(&mySerial);

// Activating the debugger/serial monitor in order to monitor the coordinates and data received from the gps
#define GPSECHO  true

// This keeps track of whether we're using the interrupt
// off by default!
boolean usingInterrupt = false;
void useInterrupt(boolean); // Func prototype keeps Arduino 0023 happy // (Me) Probably not necessary in this version of Arduino but 
                                                                       // will leave on for safekeeping...
int previousTime = 0;

// Run once on startup
void setup()  
{
  pinMode(8, OUTPUT);
  pinMode(9,OUTPUT);
  
  // Connect at 115200 (baud rate) so we can read the GPS fast enough and echo without dropping characters
  //Serial.begin(115200);
  //Serial.println("Adafruit GPS library basic test!");

  // 9600 NMEA is the default baud rate for Adafruit MTK GPS's- some use 4800
  //GPS.begin(9600);
  
  // Next line turns on RMC (recommended minimum) and GGA (fix data) including altitude // May switch to minimum recommended
  //GPS.sendCommand(PMTK_SET_NMEA_OUTPUT_RMCGGA);
  
  // uncomment next line to restrict to the "minimum recommended" data
  //GPS.sendCommand(PMTK_SET_NMEA_OUTPUT_RMCONLY);
  
  // Set the update rate to 1HZ (1 update per second)
  //GPS.sendCommand(PMTK_SET_NMEA_UPDATE_1HZ);   

  // Request updates on antenna status, comment out to keep quiet, but will be left on now to figure out when the antenna comes online
  //GPS.sendCommand(PGCMD_ANTENNA);

  // Activate the 'timer0' interrupt to check for data and store it in order to not clutter up loop and make sure the rest of the  
  // code runs whilst the loop function is running! Called once a millisecond as stated below.
  //useInterrupt(true);

  //delay(1000);
  // Ask for firmware version
  //ySerial.println(PMTK_Q_RELEASE);

    
  Serial.begin(115200); //Turn on serial monitor
  Serial.println("HERE WE GO!");
  GPS.begin(9600); //Turn on GPS at 9600 baud
  GPS.sendCommand("$PGCMD,33,0*6D");  //Turn off antenna update nuisance data
  GPS.sendCommand(PMTK_SET_NMEA_OUTPUT_RMCGGA); //Request RMC and GGA Sentences only
  GPS.sendCommand(PMTK_SET_NMEA_UPDATE_1HZ); //Set update rate to 1 hz
  delay(1000); 
  
  pinMode(10, OUTPUT); //Must declare 10 an output and reserve it to keep SD card happy 
}


// Interrupt is called once a millisecond, looks for any new GPS data, and stores it
SIGNAL(TIMER0_COMPA_vect) {
  char c;
  c = GPS.read();

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

  //------------- START OF LOOP ------------------

    
  readGPS();
 
  if(GPS.fix==1) { //Only save data if we have a fix
    mySensorData = SD.open("NMEA.txt", FILE_WRITE); //Open file on SD card for writing
    mySensorData.println(NMEA1); //Write first NMEA to SD card
    mySensorData.println(NMEA2); //Write Second NMEA to SD card
    mySensorData.close();  //Close the file
    mySensorData = SD.open("GPSData.txt", FILE_WRITE);
    Serial.print("Location: ");
    Serial.print("Fix: "); Serial.print((int)GPS.fix);
    Serial.println(" quality: "); Serial.println((int)GPS.fixquality);
    Serial.print("");
    Serial.print(GPS.hour, DEC); Serial.print(':');
    Serial.print(GPS.minute, DEC); Serial.print(':');
    Serial.print(GPS.seconds, DEC); Serial.print('.');
    Serial.print(GPS.milliseconds);
    Serial.print(",");
    Serial.print(GPS.latitudeDegrees,4);
    //Serial.print((int)GPS.lat);
    Serial.print(",");
    Serial.print(GPS.longitudeDegrees,4);
    //Serial.print((int)GPS.lon);
    Serial.print(",");
    Serial.print(GPS.altitude);
    mySensorData.print(GPS.latitudeDegrees,4); //Write measured latitude to file
    //mySensorData.print(GPS.lat); //Which hemisphere N or S
    mySensorData.print(",");
    mySensorData.print(GPS.longitudeDegrees,4); //Write measured longitude to file
    //mySensorData.print(GPS.lon); //Which Hemisphere E or W
    mySensorData.print(",");
    mySensorData.println(GPS.altitude);
    mySensorData.close();
  }
  Serial.println("#");// Control character to show end of data, for processing to communicate and grab coordinates, can be changed
                         // but make sure to change static char in my processing file...


if (GPS.fix > 0){
  ChangeLED(true);
} else {
  ChangeLED(false);
}

if (previousTime == GPS.seconds) {
  ChangeLED(false);
}


  //---------------------- END OF LOOP ------------------------
}

void ChangeLED(boolean hasAFix){
    if (hasAFix == true) {
    digitalWrite(9,LOW);
    digitalWrite(8,HIGH);
  }
  else {
    digitalWrite(8,LOW);
    digitalWrite(9,HIGH);
  }
}

//----------------------------------------



 
void readGPS() {
  
  clearGPS();
  while(!GPS.newNMEAreceived()) { //Loop until you have a good NMEA sentence
    c=GPS.read();
  }
  GPS.parse(GPS.lastNMEA()); //Parse that last good NMEA sentence
  NMEA1=GPS.lastNMEA();
  
   while(!GPS.newNMEAreceived()) { //Loop until you have a good NMEA sentence
    c=GPS.read();
  }
  GPS.parse(GPS.lastNMEA()); //Parse that last good NMEA sentence
  NMEA2=GPS.lastNMEA();
  
  Serial.println(NMEA1);
  Serial.println(NMEA2);
  Serial.println("");
  
}
 
void clearGPS() {  //Clear old and corrupt data from serial port 
  while(!GPS.newNMEAreceived()) { //Loop until you have a good NMEA sentence
    c=GPS.read();
  }
  GPS.parse(GPS.lastNMEA()); //Parse that last good NMEA sentence
  
  while(!GPS.newNMEAreceived()) { //Loop until you have a good NMEA sentence
    c=GPS.read();
  }
  GPS.parse(GPS.lastNMEA()); //Parse that last good NMEA sentence
   while(!GPS.newNMEAreceived()) { //Loop until you have a good NMEA sentence
    c=GPS.read();
  }
  GPS.parse(GPS.lastNMEA()); //Parse that last good NMEA sentence
  
}
