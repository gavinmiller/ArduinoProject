/*

READGPS - basically an all in one file. Must be connected during time of running the GPS. This assumes control of the port 
connected to the Arduino GPS and intercepts the location data as it is being received. It then runs through the data,
checking and separating the necessary lines of text in order to find the x and y coordinates. Finally it will display the
number of coordinates amounted in a Google Maps static map via the output window.

This file will not work with the SD card data, it only works with the more raw data included in the default GPS parsing file
provided by Adafruit, including some modifications to help separate the output. The GPSParsing file provided in the folder
contains our modified code, feel free to take a look at that code to get a feel for what we'll be dealing with.

These steps are assuming the GPS has been running for a short period of time in order to warm up, usually only 5 or so minutes
but could unfortunately take up to 30 minutes. Hasn't taken that long yet though.

------------------------------------------------------------------------------------------------------------------------------
PROCESSING SET UP STEPS

Step 1, change the port number of the static int portNumber below, to match the port which your arduino is 
connected. If you are unsure of where to find this information, you can print the list of ports via the console, by writing
this: printArray(Serial.list()); inside the setup method, I would recommend a blank file for this.

Step 2, change the baudRate. You may need to change the baud rate depending on what rate you need to use via the Arduino
script in order to read the data at a fast enough speed.

Step 3, change the maximum number of coordinates (maxNumOfCoordinates), self explanatory. Once connected to at least one 
satellite, you will usually receive a set of coordinates every 1 - 2 seconds.

Step 4, run the processing file. 

------------------------------------------------------------------------------------------------------------------------------

*/


// Import serial libraries to use ports that Arduino use. (USB)
import processing.serial.*;

// Decided to confine static variables to top.
// This variable declares the number of coordinates to store. Could store many more, but would take much longer.
// New default value of 25.
static int maxNumOfCoordinates = 2;
// As mentioned in the Arduino code for the gps, change this value in order to find a different control character/string
// prior to x and y coordinates in degrees.
static String coordinateLocation = "Location (in degrees, works with Google Maps): ";

// CHANGE THIS DEPENDING ON WHICH PORT YOUR ARDUINO/GPS IS PLUGGED INTO
static int portNumber = 0;
// CHANGE THIS DEPENDING ON BAUD RATE DEFINED IN ARDUINO SCRIPT  
static int baudRate = 115200;
// To be changed only if you change the final/control character in the Arduino script
static char controlChar = '#';
//URL for the static map
static String startURL = "https://maps.googleapis.com/maps/api/staticmap?&size=1000x1000&maptype=roadmap&markers=color:red%7Clabel:M";

// Will create/load and hold the image of the Google static map to draw to the screen with all coordinates
PImage img;

// Declare port variable in order to locate active port in Setup method
Serial myPort;

// Array of string values used to hold all of the NMEA sentences from gps serial output, for coordinates
String[] values;

PrintWriter output;

//float[][] coordinates; // Debating whether or not to use a multidimensional array or make a class. Decided to make a 
                         // Coordinate class, as seen at bottom.
int counter;

// Array of custom class Coordinate, to store all our lovely GPS points.
Coordinate[] coords;

void setup()
{
  size(1000,1000); // Set the size of the window to hold the Google map later
  
  output = createWriter("GPSData.txt");
  //printArray(Serial.list()); // Uncomment this line to find value of each com port
  counter = 0; // Number of stored variables, counter for while loop
  values = new String[maxNumOfCoordinates]; // Initialise the values array with length as defined above.
  coords = new Coordinate[maxNumOfCoordinates]; // Same as line above except it's an array of coordinates.
  String portName = Serial.list()[portNumber]; // Setting the listening port, using assigned variable 'portNumber' above.
  myPort = new Serial(this, portName, baudRate); // Begin listen on certain port with baud rate defined above
}

void draw()
{
  // available() is a method which returns the number of bytes available for reading from the serial port.
  // The counter variable must be less than the length of array values, as to not exceed limits of the arrays.
  if (myPort.available() > 0 && counter < values.length)
  {
    AssignData();
  }
  else if (counter >= values.length) // Activated once the counter hits/exceeds the limits of the arrays, then loads the map
  {
    WriteToFile();
    img = loadImage(CreateURL(coords), "jpg"); // Passing in the string method CreateURL as a parameter, with the
                                               // coordinates array we just created
    //println( CreateURL(coords)  )    ;
    //println(coords[0].x);
    if (img != null)
    {
      image(img,0,0,width,height);
    }
  }
}

// Made this function primarily to tidy up draw method
void AssignData()
{
     // Assinging whatever string data is sent from gps, up until the control character.
    values[counter] = myPort.readStringUntil(controlChar); // Basically captures every bit of data in a single send, time,
                                                           // date, latitude and longitude etc.
    
    // Check to make sure data saved isn't null data, as the draw method runs every frame!
    if (values[counter] != null)
    {
      //println(values[counter]); // Uncomment this for debugging, to check that we are communicating correctly with arduino
      
      // Method below is used to check the strings saved in string array values, and extract the coordinates into a new array
      CheckValue(values[counter], counter);
      
      // Add one to the counter in this conditional because if a null value is stored to values[counter] as seen above, we 
      // want to overwrite that value with a good one.
      counter++;
    }
}


// Pass in the NMEA sentence, and the position it is at for setting tRuhe position in the coords array.
// Position is not totally necessary, but may be good for cross referencing arrays later if need be.
void CheckValue(String sentence, int valuesPosition)
{
  String[] myString; // Local string array used to store each individual line of the NMEA sentence(GPS data) for parsing
  myString = sentence.split("\n");
  for (int i = 0; i < myString.length; i++) // Length of thelocal array myString used here obviously, to check each line 
  {
    if (myString[i].contains(coordinateLocation)) // This is where we implement the static string to find the maps coordinates
    {
      
      String bothCoords = myString[i].substring(coordinateLocation.length() - 1); // New local string which contains ony
                                                                                  // the x and y coordinates
                                                                                  
                                                                                  
      //println(bothCoords); // Debugging line, uncomment to make sure substring method above is working
      bothCoords = bothCoords.replaceAll(" ", ""); // Replace space(s) with nothing!
      int indexOfComma = bothCoords.indexOf(','); // Find index of comma between coords for splitting!
                                                  // Learnt this structure from one of the JavaScript assessments!!
      
      coords[valuesPosition] = new Coordinate(); // Initialise the new coordinate found, using empty constructor
      
      coords[valuesPosition].x = bothCoords.substring(0, indexOfComma); // Find first coordinate for x value
      coords[valuesPosition].y = bothCoords.substring(indexOfComma + 1); // Find second coordinate after comma for y value
      
      PrintCoordinates(coords[valuesPosition], valuesPosition); // Debugging, printing the coordinates using method
                                                                // PrintCoordinates, passing in the newly saved coordinate 
                                                                // from our 'coords' array as the parameter
    }
  }
}

// Creating a method which takes a variable of type 'Coordinate' as a value, and a position of type integer
void PrintCoordinates(Coordinate coordinates, int pos)
{
  println("Position in coordinate array: " + pos);
  println("X coordinate: " + coordinates.x);
  println("Y coordinate: " + coordinates.y); // Self explanatory, prints the coordinates on separate lines in the console.
  println();
}



void WriteToFile()
{
  for (int i = 0; i < coords.length; i++)
  {
    output.println("Latitude:" + coords[i].x);
    output.println("Longitude:" + coords[i].y);
    output.println("Altitude:" + "0.5");
  }
  
  output.flush();
  output.close();
}

// From our Coords_to_map file, a String method which will return the final product and tell Google Maps where to place all
// of our lovely markers. There is so much more potential with the static Google maps api such as plotting a route with lines
// and other custom markers which we could've done if only we had more time...
String CreateURL(Coordinate[] coordinates)
{ // Obviously we pass in our Coordinate array to map the coordinates
  String newURL = startURL; // New url string to add to later
  //For loop to add all the maps markers in order to have, theoretically, a differing number of coordinates and not break
  // the code.
  for (int i = 0; i < coordinates.length; i++)
  {
    
    // Must perform a final null check as to not break our code if the user decides to end the gps data collection prematurely
    if (coordinates[i].x != null && coordinates[i].y != null)
    {
      if (!newURL.contains(coordinates[i].x + "," + coordinates[i].y))
      {
        newURL += "%7C" + coordinates[i].x + "," + coordinates[i].y;
      }
    }
  }
  // Development Key that allows the map API to be edited
  newURL += "&key=AIzaSyCCLkMPWOC_ZHb86cojflgHfTATlTIxu_s";
  // Returning the completed URL
  return newURL;
}

public class Coordinate // Coordinate class declaration, only stores two values.
{
  // Decided on string instead of float as I wanted to use interchangeably with URL strings and whatnot, no mathematical
  // calculations necessary. (AS OF NOW anyway)
  public String x;
  public String y;
  
  public Coordinate() // Empty constructor to set values individually.
  {
    
  }
  
  public Coordinate(String xCoord, String yCoord) // Constructor to set values in one line for lazy people like me, for
  {                                               // hardcoded variables for debugging anyway
    x = xCoord;
    y = yCoord;
  }
}