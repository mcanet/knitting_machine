
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
