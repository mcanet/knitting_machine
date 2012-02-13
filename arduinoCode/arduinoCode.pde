/*
* KEY PRESS
*
*/

#define DOWN 0x5F
#define UP 0x60
#define  C 0x61
#define CR 0x62
#define CE 0x63
#define STEP 0x64
#define VAR1 0x65
#define VAR2 0x66
#define VAR3 0x67
#define VAR4 0x68
#define VAR5 0x69
#define VAR6 0x6A
#define KHC  0x6B
#define VAR7 0x6C
#define KRC  0x6D

#define CHECK 0x6E
#define MEMO 0x6F
#define INPT 0x70  /*not use INPUT because reserved name*/
#define LEFT 0x71
#define RIGHT 0x72
#define SOUND 0x73
#define BLACKSQUARE 0x74
#define WHITESQUARE 0x75
#define M 0x76
#define START 0x77
#define SEL1 0x78
#define SEL2 0x79
#define S 0x7A
#define R 0x7C
#define YELLOW 0x7D
#define GREEN 0x7E

char inByte = 0;         // incoming serial byte

int keyPressDelayTime = 200;
int keyReleaseDelayTime = 0;

// digital 0-9
int columns[10] = {10,11,2,3,4,5,6,7,8,9};
// analog 0-3
int rows[4] = {A0,A1,A2,A3};

void setup()
{
 Serial.begin(9600);
 pinMode(13, OUTPUT);
 setAllLow();
}

void loop()
{
 digitalWrite(13,LOW);
 // if we get a valid byte, read analog ins:
 if(Serial.available() > 0) {
     inByte = Serial.read();
     Serial.flush();
     digitalWrite(13,HIGH);
     keypress(inByte);
 } 
 // delay 10ms to let the ADC recover:
 delay(10);
}

void setAllLow(){
 // columns
 for(int i=0;i<10;i++) digitalWrite(columns[i], LOW); 
 // rows
 for(int i=0;i<4;i++) digitalWrite(rows[i], LOW);
}

void key(int row, int col){

digitalWrite(rows[row], HIGH);
digitalWrite(columns[col], HIGH);
delay(keyPressDelayTime);
setAllLow();
delay(keyReleaseDelayTime);  
}


void keypress(char c){
switch(c){
case C:
  key(1,1);
  break;
case CR:
  key(1,8); //CR
  break;
case CE:
  key(1,7); //CE
  break;
case 1: case '1':
  key(0,8); //1
  break;
case 2: case '2':
  key(0,7); //2
  break;
case 3: case '3':
  key(0,6); //3
  break;
case 4: case '4':
  key(0,5);
  break;
case 5: case '5':
  key(0,4);
  break;
case 6: case '6':
  key(0,3);
  break;
case 7: case '7':
  key(0,2);
  break;
case 8: case '8':
  key(0,1);
  break;
case 9: case '9':
  key(0,0);
  break;
case 0: case '0':
  key(0,9);
  break;
case STEP:
  key(1,9);
  break;
case VAR1:
  key(3,9);
  break;
case VAR2:
  key(3,8);
  break;
case VAR3:
  key(3,6);
  break;
case VAR4:
  key(3,5);
  break;
case VAR5:
  key(3,7);
  break;
case VAR6: //case KHC:
  key(3,4);
  break;
case VAR7: //case KRC:
  key(3,3);
  break;
case CHECK:
  key(2,8);
  break;
case MEMO:
  key(2,6);
  break;
case INPT:
  key(2,9);
  break;
case LEFT:
  key(2,1);
  break;
case RIGHT:
  key(2,2);
  break;
case SOUND:
  key(2,7);
  break;
case BLACKSQUARE:
  key(2,3);
  break;
case WHITESQUARE:
  key(2,4);
  break;
case M:
  key(1,2);
  break;
case START:
  key(3,0);
  break;
case SEL1:
  key(1,0);
  break;
case SEL2:
  key(2,0);
  break;
case S:
  key(3,1);
  break;
case R:
  key(3,2);
  break;
case YELLOW:
  key(1,6);
  break;
case GREEN:
  key(1,5);
  break;
case UP:
  key(1,4);
  break;
case DOWN:
  key(1,3);
  break;
}
}

