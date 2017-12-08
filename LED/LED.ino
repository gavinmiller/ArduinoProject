

void setup() {
  pinMode(8, OUTPUT);
  pinMode(9,OUTPUT);
}

void loop() {
while(true){
  ChangeLED(true);
  delay(1000);
  ChangeLED(false);
  delay(1000);
}

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

