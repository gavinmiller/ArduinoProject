Coordinate[] newCoords = {new Coordinate("57.1187", "-2.1314"), new Coordinate("57.1091", "-2.1314"), new Coordinate("57.1065", "-2.1314")};
PImage img;

String startURL = "https://maps.googleapis.com/maps/api/staticmap?&zoom=14&size=1000x1000&maptype=roadmap&markers=color:red%7Clabel:M";
void setup() {
  size(1000,1000);
}
void draw(){
  //img = loadImage(startURL + center[0].x + "," + center[0].y + "&key=AIzaSyCCLkMPWOC_ZHb86cojflgHfTATlTIxu_s", "jpg");
  img = loadImage(CreateURL(newCoords), "jpg");
  image(img,0,0,width,height);
}

String CreateURL(Coordinate[] coords){
  String newURL = startURL;
  
  for (int i = 0; i < coords.length; i++){
    newURL += "%7C" + coords[i].x + "," + coords[i].y;
  }
  
  newURL += "&key=AIzaSyCCLkMPWOC_ZHb86cojflgHfTATlTIxu_s";
  
  return newURL;
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