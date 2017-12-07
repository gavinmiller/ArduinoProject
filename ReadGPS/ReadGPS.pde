import processing.serial.*;

Serial myPort;
String val;
String[] values;
//int[][] coordinates;
int counter;
boolean readFinished = false;

Coordinate[] coords;

static int maxNumOfCoordinates = 100;
static String coordinateLocation = "Location (in degrees, works with Google Maps): ";

void setup()
{
  size(800,600);
  counter = 0;
  values = new String[maxNumOfCoordinates];
  coords = new Coordinate[maxNumOfCoordinates];
  String portName = Serial.list()[1];
  myPort = new Serial(this, portName, 115200);
}

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

void CheckValue(String sentence, int valuesPosition)
{
  String[] myString;
  myString = sentence.split("\n");
  for (int i = 0; i < myString.length; i++)
  {
    if (myString[i] == coordinateLocation)
    {
      String bothCoords = myString[i].replaceAll(coordinateLocation, ""); 
      bothCoords.replaceAll("\\s+", "");
      int indexOfComma = bothCoords.indexOf(',');
      
      coords[i].x = bothCoords.substring(0, indexOfComma);
      coords[i].y = bothCoords.substring(indexOfComma);
      
      PrintCoordinates(coords[i]);
    }
  }
}

void PrintCoordinates(Coordinate coordinates)
{
  println("X coordinate: " + coordinates.x);
  println("Y coordinate: " + coordinates.y);
}

public class Coordinate 
{
  public String x;
  public String y;
  // Should be float but y'know
}