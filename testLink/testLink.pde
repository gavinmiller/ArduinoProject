String urlStart = "https://www.google.com/maps/search/?api=1";
String newUrl = "";
Coordinate[] exampleCoord = {new Coordinate("57.1187", "-2.1314"), new Coordinate("57.1091", "-2.1314")};

boolean hasStarted = false;


void setup(){
  size(800,600);
}

void draw(){
  if (hasStarted == false){
    String urlA = urlStart + "&query=" + exampleCoord[0].x + "," + exampleCoord[0].y + "&query=" + exampleCoord[1].x + "," + exampleCoord[1].y;
    link(urlA);
    hasStarted = true;
  }
}

public class Coordinate {
 String x;
 String y;
 
 public Coordinate(String xCoord, String yCoord){
  x = xCoord;
  y = yCoord;
 }
 
 public Coordinate(){}
}