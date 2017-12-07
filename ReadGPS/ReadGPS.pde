// Import serial libraries to use ports that Arduino use. (USB)
import processing.serial.*;

// Decided to confine static variables to top.
// This variable declares the number of coordinates to store. Could store many more, but would take much longer.
// New default value of 25.
static int maxNumOfCoordinates = 25;
// As mentioned in the Arduino code for the gps, change this value in order to find a different control character/string
// prior to x and y coordinates in degrees.
static String coordinateLocation = "Location (in degrees, works with Google Maps): ";

// CHANGE THIS DEPENDING ON WHICH PORT YOUR ARDUINO/GPS IS PLUGGED INTO
static int portNumber = 2;
// CHANGE THIS DEPENDING ON BAUD RATE DEFINED IN ARDUINO SCRIPT  
static int baudRate = 115200;
// To be changed only if you change the final/control character in the Arduino script
static char controlChar = '#';

// Declare port variable in order to locate active port in Setup method
Serial myPort;

// Array of string values used to hold all of the NMEA sentences from gps serial output, for coordinates
String[] values;


//float[][] coordinates; // Debating whether or not to use a multidimensional array or make a class. Decided to make a 
                         // Coordinate class, as seen at bottom.
int counter;

// TBC - True or false value to indicate back to arduino that gps is done collecting values.
boolean readFinished = false;

// Array of custom class Coordinate, to store all our lovely GPS points.
Coordinate[] coords;

void setup()
{
  //size(800,600); // Not necessary atm...
  //printArray(Serial.list()); // Uncomment this line to find value of each com port
  counter = 0; // Number of stored variables, counter for while loop
  values = new String[maxNumOfCoordinates]; // Initialise the values array with length as defined above.
  coords = new Coordinate[maxNumOfCoordinates]; // Same as line above except it's an array of coordinates.
  String portName = Serial.list()[portNumber]; // Setting the listening port, using assigned variable 'portNumber' above.
  myPort = new Serial(this, portName, baudRate); // Begin listen on certain port with baud rate defined in above
}

void draw()
{
  // available() is a method which returns the number of bytes available for reading from the serial port.
  // The counter variable must be less than the length of array values, as to not exceed limits of the arrays.
  if (myPort.available() > 0 && counter < values.length)
  {
    // Assinging whatever string data is sent from gps, up until the control character.
    values[counter] = myPort.readStringUntil(controlChar); 
    // Check to make sure data saved isn't null data, as the draw method runs every frame!
    if (values[counter] != null)
    {
      //println(values[counter]); // Uncomment this for debugging, to check that we are communicating correctly with arduino
      
      // Custom method below to check the string saved in values, and extract and save the coordinates
      CheckValue(values[counter], counter);
      // Add one to counter, in here because if a null value is stored to values[counter] as seen above, we want to overwrite
      // that value with a good one.
      counter++;
    }
  }
  else if (counter >= values.length) // Activated once the counter hits/exceeds the limits of the arrays, and return true for
  {                                  // arduino script to initiate stop method for the gps.
    readFinished = true;
  }
}

// Pass in the NMEA sentence, and the position it is at for setting the position in the coords array.
// Position is not totally necessary, but may be good for cross referencing arrays later if need be.
void CheckValue(String sentence, int valuesPosition)
{
  String[] myString; // String array used to store each individual line of the NMEA sentence for parsing
  myString = sentence.split("\n");
  for (int i = 0; i < myString.length; i++) // Length of thelocal array myString used here obviously, to check each line 
  {
    if (myString[i].contains(coordinateLocation)) // This is where we implement the static string to find the maps coordinates
    {
      String bothCoords = myString[i].substring(coordinateLocation.length() - 1); // New local string which contains ony
                                                                                  // the x and y coordinates
      //println(bothCoords); // Debugging line, uncomment to make sure substring method above is working
      bothCoords = bothCoords.replaceAll(" ", ""); // Replace space with nothing!
      int indexOfComma = bothCoords.indexOf(','); // Find index of comma between coords for splitting!
      
      coords[valuesPosition] = new Coordinate(); // Initialise the new coordinate found using empty constructor
      
      coords[valuesPosition].x = bothCoords.substring(0, indexOfComma); // Find first coordinate for x value
      coords[valuesPosition].y = bothCoords.substring(indexOfComma + 1); // Find second coordinate after comma for y value
      
      PrintCoordinates(coords[valuesPosition], valuesPosition); // Debugging, printing the coordinates using custom method passing in
                                                // the newly saved coordinate in our coords array as the parameter
    }
  }
}

void PrintCoordinates(Coordinate coordinates, int pos)
{
  println("Position in coordinate array: " + pos);
  println("X coordinate: " + coordinates.x);
  println("Y coordinate: " + coordinates.y); // Self explanatory, prints the coordinates on separate lines in the console.
  println();
}

public class Coordinate // Coordinate class declaration, only stores two values.
{
  public String x;
  public String y;
  // Should be float (to complete the vector2) but it's okay...
  
  public Coordinate() // Empty constructor to set values individually.
  {
    
  }
  
  public Coordinate(String xCoord, String yCoord) // Constructor to set values in one line for lazy people
  {
    x = xCoord;
    y = yCoord;
  }
}