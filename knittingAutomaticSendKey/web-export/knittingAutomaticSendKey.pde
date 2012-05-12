/*
* send key to kniting machine
*/
import processing.serial.*;

Serial myPort;  // Create object from Serial class

ArrayList keys;

String[] insertPattern = {"CE","INPUT","STEP","X","X","X","STEP","CE","X","X","X","STEP"};

float threshold = 127;
int cols = 60;
int rows = 60;
int[][] pixelArray; 
boolean serialIsConnected = false;

boolean insertingPattern = false;
boolean insertingPixelsPattern = false;
boolean insertingPatternEnd = false;
boolean pressUpkey = false;

float timeForSending = 0;
float timeStartSending = 0;
float timelastKeySend = 0;
float frequencyKeySend = 1000;
int insertPatternPointer = 0;
int rowtPixelPointer = 0;
int columntPixelPointer = 0;

PImage img;
PFont font;

void setup(){
  size(1024,900);
  font = loadFont("Dialog-12.vlw"); 
  setupKnitting();
  fillArrayWithImage("spam.png");
  setupSerialPort();
}

void draw(){
  background(51);
  fill(30);
  rect(690,0,width,height);
  image(img,700,20);
  fill(255);
  text("Press key \'f\': Choose file", 860, 30);
  text("Press key \'i\': Start", 860, 60);
  text("Press key \'s\': Stop", 860, 90);
  
  if(insertingPixelsPattern){
    color(255,0,0);
    //textFont(font, 12); 
    
    text("ROW:"+Integer.toString(rows-rowtPixelPointer), 860, 130);
    text("COLUMN:"+Integer.toString(columntPixelPointer), 860,180);
    int percentage = 100-(int)(((((float)rowtPixelPointer*(float)cols)+(float)columntPixelPointer) / ((float)cols*(float)rows))*100);
    text("PERCENTAGE:"+Integer.toString(percentage)+"%", 860,230);
  }
  
  int cubSize = 3;
  for(int x=0;x<cols;x++){
     for(int y=0;y<rows;y++){
       if(pixelArray[x][y]==1){
         fill(255);
       }else{
         fill(0);
       }
       if(insertingPixelsPattern && rowtPixelPointer==y && columntPixelPointer==x ){
         fill(255,0,0);
       }
       rect(x*cubSize, y*cubSize, cubSize,cubSize);
     }
   }
   
   // Calculating time spend for sending keys
   timeForSending = millis()-timeStartSending;
   // frequencyKeySend
   if(millis()-timelastKeySend> frequencyKeySend){
       timelastKeySend = millis();
       if((insertingPattern || insertingPixelsPattern || insertingPatternEnd)){
         if(pressUpkey){
           pressUpkey = false;
           pressKnittingKey("UP");
           println("Up set");
         }else if(insertingPattern){
           println(insertPattern[insertPatternPointer]);
           pressKnittingKey(insertPattern[insertPatternPointer]);
           insertPatternPointer++;
           
           while( insertPatternPointer<insertPattern.length && insertPattern[insertPatternPointer]=="X"){
             println("inside while");
             insertPatternPointer++;
           }
           //println("end while");
           //println(Integer.toString(insertPatternPointer)+">="+Integer.toString(insertPattern.length));
           if(insertPatternPointer>=insertPattern.length){ 
             insertingPattern = false;
             println("now pixels will come");
             //frequencyKeySend = 500;
           }
         }else if(insertingPixelsPattern ){
           if( isBlackPixel(columntPixelPointer,rowtPixelPointer) ){
             pressKnittingKey("BLACKSQUARE");
             columntPixelPointer++;
             if(columntPixelPointer>=cols){
               columntPixelPointer=0;
               rowtPixelPointer-=1;
              
               if(rowtPixelPointer<0){ 
                 insertingPixelsPattern = false;
               }else{
                 pressUpkey = true;
               }
             }
             println("blackpixel");
         }else if(anyMoreBlackInThisRow(columntPixelPointer,rowtPixelPointer)){
            pressKnittingKey("WHITESQUARE");
            columntPixelPointer++;
            if(columntPixelPointer>=cols){
              columntPixelPointer=0;
              rowtPixelPointer-=1;
              if(rowtPixelPointer<0){ 
                insertingPixelsPattern = false;
              }else{
                pressUpkey = true;
              }
            }
            println("whitepixel set");
         }else{
            columntPixelPointer=0;
            rowtPixelPointer-=1;
            if(rowtPixelPointer<0){ 
              insertingPixelsPattern = false;
            }else{
              pressUpkey = true;
            }
            
         }
       }else if(insertingPatternEnd){
         pressKnittingKey("INPUT");
         insertingPatternEnd =false;
       }
     }
   }
   
}

void keyPressed(){
 // stop inserting pattern
 if(key=='s'){
   insertingPattern = false;
   insertingPixelsPattern = false;
 } 
 // insert
 if(key=='i'){
    insertingPattern = true;
    insertingPixelsPattern = true;
    insertingPatternEnd = true;
    pressUpkey = false;
    timeForSending = 0;
    rowtPixelPointer = rows-1;
    columntPixelPointer = 0;
    insertPatternPointer = 0;
    timeStartSending = millis();
 }
 if(key=='f'){
    String loadPath = selectInput();  // Opens file chooser
    if (loadPath == null) {
      // If a file was not selected
      println("No file was selected...");
    } else {
      // If a file was selected, print path to file
      fillArrayWithImage(loadPath);
    }
 }
}

void pressKnittingKey(String keyName){
 int keyKnittingCode = 0;
 for(int i=0; i<keys.size();i++){
   KeyKnitting temp =(KeyKnitting) keys.get(i);
   if(temp.keyName.equals(keyName)) keyKnittingCode = temp.code;
 }
 //println(keyKnittingCode);
 //println((char)keyKnittingCode);
 if(serialIsConnected) myPort.write((char)keyKnittingCode);
}

class KeyKnitting{
 String keyName;
 int code;
 KeyKnitting(String _keyName, int _code){
   keyName = _keyName;
   code = _code;
 }
}



void setupKnitting(){
 // Create an empty ArrayList
 keys = new ArrayList();
 
 // Start by adding one key element
 keys.add(new KeyKnitting("DOWN",0x5F));
 keys.add(new KeyKnitting("UP",0x60));
 keys.add(new KeyKnitting("C",0x61));
 keys.add(new KeyKnitting("CR",0x62));
 keys.add(new KeyKnitting("CE",0x63));
 keys.add(new KeyKnitting("STEP",0x64));
 keys.add(new KeyKnitting("VAR1",0x65));
 keys.add(new KeyKnitting("VAR2",0x66));
 keys.add(new KeyKnitting("VAR3",0x67));
 keys.add(new KeyKnitting("VAR4",0x68));
 keys.add(new KeyKnitting("VAR5",0x69));
 keys.add(new KeyKnitting("VAR6",0x6A));
 keys.add(new KeyKnitting("KHC",0x6B));
 keys.add(new KeyKnitting("VAR7",0x6C));
 keys.add(new KeyKnitting("KRC",0x6D));
 keys.add(new KeyKnitting("CHECK",0x6E));
 keys.add(new KeyKnitting("MEMO",0x6F));
 keys.add(new KeyKnitting("INPUT",0x70));
 keys.add(new KeyKnitting("LEFT",0x71));
 keys.add(new KeyKnitting("RIGHT",0x72));
 keys.add(new KeyKnitting("SOUND",0x73));
 keys.add(new KeyKnitting("BLACKSQUARE",0x74));
 keys.add(new KeyKnitting("WHITESQUARE",0x75));
 keys.add(new KeyKnitting("M",0x76));
 keys.add(new KeyKnitting("START",0x77));
 keys.add(new KeyKnitting("SEL1",0x78));
 keys.add(new KeyKnitting("SEL2",0x79));
 keys.add(new KeyKnitting("S",0x7A));
 keys.add(new KeyKnitting("R",0x7C));
 keys.add(new KeyKnitting("YELLOW",0x7D));
 keys.add(new KeyKnitting("GREEN",0x7E));
 keys.add(new KeyKnitting("0",0x00)); 
 keys.add(new KeyKnitting("1",0x01));
 keys.add(new KeyKnitting("2",0x02));
 keys.add(new KeyKnitting("3",0x03));
 keys.add(new KeyKnitting("4",0x04));
 keys.add(new KeyKnitting("5",0x05));
 keys.add(new KeyKnitting("6",0x06));
 keys.add(new KeyKnitting("7",0x07));
 keys.add(new KeyKnitting("8",0x08));
 keys.add(new KeyKnitting("9",0x09));
}

void setupSerialPort(){
  // I know that the first port in the serial list on my mac
 // is always my  FTDI adaptor, so I open Serial.list()[0].
 // On Windows machines, this generally opens COM1.
 // Open whatever port is the one you're using.
 //println(Serial.list());
 try{
   String portName = Serial.list()[0];
   println("portname:"+portName);
   myPort = new Serial(this, portName, 9600);
   serialIsConnected = true;
 }catch(Exception e){
   serialIsConnected = false;
 }
}

void fillArrayWhite(){
  for(int i=0;i<cols;i++){
     for(int y=0;y<rows;y++){
       pixelArray[i][y]=1;
     }
   }
   
}

void fillArrayBlack(){
  for(int x=0;x<cols;x++){
     for(int y=0;y<rows;y++){
       pixelArray[x][y]=1;
     }
   }
}

void fillArrayRandom(){
  for(int x=0;x<cols;x++){
     for(int y=0;y<rows;y++){
       pixelArray[x][y]=round(random(0,1));
     }
   }
}

void fillArrayWithImage(String imgPath){ 
  img = loadImage(imgPath);
  cols = img.width;
  rows = img.height;
  pixelArray = new int[cols][rows];
  
  img.loadPixels(); 
  for (int y = 0; y <rows; y++) {
    for (int x = 0; x <  cols; x++) {
      int loc = (cols-1)-x + y*cols;
      if (brightness(img.pixels[loc]) > threshold) {
        pixelArray[x][y] = 1;
      }else{
        pixelArray[x][y] = 0;
      }
    }
  }
  // pass numbers to String
  String[] colsStr = Integer.toString(cols).split("");
  String[] rowsStr = Integer.toString(rows).split("");
  println("E:"+Integer.toString(cols)+"-"+Integer.toString(rows));
  if(cols<10){
    insertPattern[3] = colsStr[1];
    println("10");
  }else if(cols<100){
    insertPattern[3] = colsStr[0];
    insertPattern[4] = colsStr[1];
  }else if(cols>=100){
    insertPattern[3] = colsStr[1];
    insertPattern[4] = colsStr[2];
    insertPattern[5] = colsStr[3];
  }
  if(rows<10){
    insertPattern[8] = rowsStr[1];
  }else if(rows<100){
    insertPattern[8] = rowsStr[1];
    insertPattern[9] = rowsStr[2];
  }else if(rows>=100){
    insertPattern[8] = rowsStr[1];
    insertPattern[9] = rowsStr[2];
    insertPattern[10] = rowsStr[3];
  }
}


boolean isBlackPixel(int x, int y){
  return  pixelArray[x][y]==0;
}

boolean anyMoreBlackInThisRow(int columntPixelPointer,int rowtPixelPointer){
  boolean blackPixel = false;
  int y = rowtPixelPointer;
  for (int x = columntPixelPointer; x < cols; x++) {
    if( pixelArray[x][y]==0 ){ 
      blackPixel = true;
      break;
    }
  }
  return blackPixel;
}

