/*

SDDataToMap - This program will search through the data given in the file provided by the GPS, saved onto the SD card. Please
remember to transfer the text file to the same folder holding this program.

*/


//URL for the static map
static String startURL = 
"https://maps.googleapis.com/maps/api/staticmap?&zoom=14&size=1000x1000&maptype=roadmap&markers=color:red%7Clabel:M";

// Array of custom class Coordinate, to store all our lovely GPS points.
Coordinate[] coords;

// Will create/load and hold the image of the Google static map to draw to the screen with all coordinates
PImage img;

// Used as to not create the map before all of the points have been read.
boolean readyToMap = false;

void setup()
{
  size(1000, 1000);
}

void draw()
{
  if (readyToMap)
  {
  img = loadImage(CreateURL(coords), "jpg"); // Passing in the string method CreateURL as a parameter, with the
                                             // coordinates array we just created             
  image(img,0,0,width,height);
  }
}

// This is a String method which will return the final product and tell Google Maps where to place all of our lovely markers. 
// There is so much more potential with the static Google maps api such as plotting a route with lines and other custom 
// markers which we could've done if only we had more time...
String CreateURL(Coordinate[] coords) // Obviously we pass in our Coordinate array to map the coordinates
{ 
  String newURL = startURL; // New url string to add to later
  //For loop to add all the maps markers in order to have, theoretically, a differing number of coordinates and not break
  // the code.
  for (int i = 0; i < coords.length; i++)
  {
    
    // Must perform a final null check as to not break our code if the user decides to end the gps data collection prematurely
    if (coords[i] != null)
    {
      newURL += "%7C" + coords[i].x + "," + coords[i].y;
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