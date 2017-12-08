import processing.serial.*;

import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.utils.*; 

UnfoldingMap map;

// Declare port variable in order to locate active port
Serial myPort;

// Array of string values used to hold all of the NMEA sentences from gps serial output, for coordinates
String[] values;

//int[][] coordinates;
int counter;
boolean readFinished = false;

Coordinate[] coords;

Coordinate defaultPos = new Coordinate(57.1519, -2.1061);

static int maxNumOfCoordinates = 100;
static String coordinateLocation = "Location (in degrees, works with Google Maps): ";

// CHANGE THIS DEPENDING ON WHICH PORT YOUR ARDUINO/GPS IS PLUGGED INTO
static int portNumber = 2;

void setup()
{
  size(800,600);
  map = new UnfoldingMap(this);
    MapUtils.createDefaultEventDispatcher(this, map);
  //printArray(Serial.list()); // Uncomment this line
  /*counter = 0;
  values = new String[maxNumOfCoordinates];
  coords = new Coordinate[maxNumOfCoordinates];
  String portName = Serial.list()[portNumber];
  myPort = new Serial(this, portName, 115200);*/
}

void draw(){
  map.draw();
  map.zoomAndPanTo(new Location(defaultPos.x, defaultPos.y), 15);
}

/*
void draw()
{
  if (myPort.available() > 0 && counter < values.length)
  {
    values[counter] = myPort.readStringUntil('#'); 
    if (values[counter] != null)
    {
      //println(values[counter]);
      CheckValue(values[counter], counter);
      counter++;
    }
  }
  else if (counter >= values.length)
  {
    readFinished = true;
  }
}
*/
/*
void CheckValue(String sentence, int valuesPosition)
{
  String[] myString;
  myString = sentence.split("\n");
  for (int i = 0; i < myString.length; i++)
  {
    if (myString[i].contains(coordinateLocation))
    {
      String bothCoords = myString[i].substring(coordinateLocation.length() - 1); 
      //println(bothCoords);
      bothCoords = bothCoords.replaceAll(" ", "");
      int indexOfComma = bothCoords.indexOf(',');
      
      coords[valuesPosition] = new Coordinate();
      
      coords[valuesPosition].x = bothCoords.substring(0, indexOfComma);
      coords[valuesPosition].y = bothCoords.substring(indexOfComma + 1);
      
      PrintCoordinates(coords[valuesPosition]);
    }
  }
}

void PrintCoordinates(Coordinate coordinates)
{
  println("X coordinate: " + coordinates.x);
  println("Y coordinate: " + coordinates.y);
}
*/
public class Coordinate 
{
  public float x;
  public float y;
  // Should be float but y'know
  
  public Coordinate(){}
  
  public Coordinate(float xCo, float yCo){
   x = xCo;
   y = yCo;
  }
}