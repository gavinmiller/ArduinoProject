# ArduinoProject
ArduinoProject

The main four files are the 'GPSParsing' file, the GPSParsingLoggingSDLEDS, ReadGPS and SDDataToMap. Two Arduino files and two Processing files. If the Arduino is to stay connected to the computer, the GPSParsing program paired with the ReadGPS program will log the coordinates as they come through, then display the map afterwards. However, for on the go, you can attach a micro SD card to the Arduino and upload the GPSParsingLoggingSDLEDS in order to save the data to a text file. Then move the GPSData.txt file to the folder containing the SDDataToMap program and you will be able to display the journey you took via Processing.

------------------------------------------------------------------------------------------------------------------------------------------

NEW
Readme needs updating as the files to use have changed. We now have implemented saving to an SD card, reading data and displaying the coordinates on a static Google Map via processing.

All code contained in this repository is copyrighted by Gavin Miller, Calum Walker, Sean Kemp, James Alderson and Harsha Valluru. This code is open source and freely available to use. Thank you.
