import processing.serial.*;

Serial myPort;
String val;
String[] values;
int counter;
void settings(){
  
}

void setup(){
  size(800,600);
  counter = 0;
  values = new String[100];
  String portName = Serial.list()[1];
  myPort = new Serial(this, portName, 115200);
}

void draw(){
    if (myPort.available() > 0 && counter < 100){
   values[counter] = myPort.readStringUntil('#'); 
   if (values[counter] != null){
     println(values[counter]);
counter++;
   }
    }

}