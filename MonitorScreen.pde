import processing.serial.*;     //Serial
import java.util.*;             //Date
import controlP5.*;             //GUI
import ddf.minim.analysis.*;    //FFT
//import ddf.minim.*;             //FFT
import javax.swing.JOptionPane; //Messages
import java.awt.Robot;          //Keyboard robot
import java.awt.AWTException;   //Keyboard robot Exception
import java.awt.event.KeyEvent; //Keyprss
import java.awt.event.InputEvent; //Keyprss
//import java.awt.Toolkit;
import processing.sound.SoundFile;  //Sound beeps

//Serial communication variables
Serial myPort;
int baud = 57600;                     //57600 for USB, 9600 for BT
String portName = "COM6";             //COM6 for USB, COM8 for BT, COM5 for UNO
String inString;                      //Input string from serial port
boolean serialOpen = false;           //True is the serial port is successfully opened
boolean runWhithoutSerial = false;    //True if user select to continue without connected device

//File writer
PrintWriter ppgText;
PrintWriter beatText;
PrintWriter tempText;
PrintWriter respText;
PrintWriter patientName;

//Define images
PImage heart_Img;
PImage battery_Img;
PImage bluetooth_Img;
PImage save_Img;
PImage refresh_Img;
PImage marker_Img;
PImage record_Img;

//Libraries
//Minim       minim;
FFT         fft;
Robot       robot;
SoundFile   beep;
SoundFile   peep;

//GUI
ControlP5 cp5;
Textarea beatPeriodTextArea;
Textarea sp02TextArea;
Textarea objectTempTextArea;
Textarea ambientTempTextArea;

//GUI layout variables
int menuBarHeight;
float statsBloksWidth;
int blockHeight;
float graphBlocks_x;
float graphBlocks_w;
float statsBlocks_x;
float statsBlocks_w;
float blocks_y[] = new float[4];

//Vital signs
String eeg;             //String of the measured EEG signal (substring'ed from inString)
int redPPG;        //String of the pulse oximeter (substring'ed from inString)
int irPPG;
//float 
int bpm;
float sp02;            //String of the calculated Sp02 (substring'ed from inString)
float prev_sp02;
float objTemp;         //TMP006 object Temp (substring'ed from inString)
float dieTemp;         //TMP006 ambient Temp (substring'ed from inString)
float sensorVolt;      //TMP006 ambient Temp (substring'ed from inString)

boolean plotGraph[] = new boolean[6];
int graphValues[] = new int[6];

boolean plotTempStats = false;
boolean plotBeatStats = false;
boolean plotSp02Stats = false;
boolean plotFFT = false;

boolean altBeatStats = false;
boolean altBreathStats = false;
boolean altSp02Stats = false;
boolean altTempStats = false;

//Other variables
boolean writePPG = false;
boolean writeBeat = false;
boolean writeTemp = false;
boolean fftOn = false;
boolean noise = false;

boolean recording = false;
boolean preRecording = false;
boolean recording_A = false;
boolean recording_B = false;

void settings()
{
  size(displayWidth-100, displayHeight-200);
}

//SETUP_SETUP_SETUP_SETUP_SETUP_SETUP_SETUP_SETUP_SETUP_SETUP_SETUP_SETUP_SETUP_SETUP_SETUP_SETUP_SETUP_SETUP_SETUP_SETUP_SETUP_SETUP_SETUP_SETUP_SETUP_SETUP_SETUP_SETUP_SETUP_SETUP_SETUP_SETUP_

void setup() 
{
  background(0);
  frameRate(1000);
  //surface.setResizable(true);

  startSerial(portName, baud);  //Open the COM port: portName

  //Start robot for pressing space for BioTrace marker
  try { 
    robot = new Robot();
  } 
  catch (AWTException e) {
    e.printStackTrace();
    exit();
  }

  //Load images
  heart_Img = loadImage("data/Heart.jpg");
  battery_Img = loadImage("data/BatteryIndicator.jpg");
  bluetooth_Img = loadImage("data/BT_logo.jpg");
  save_Img = loadImage("data/Save.jpg");
  refresh_Img = loadImage("data/Refresh.png");
  marker_Img = loadImage("data/Marker.jpg");
  record_Img = loadImage("data/Record.png");

  //Assign values to GUI layout variables
  menuBarHeight = 60;
  statsBloksWidth = 0.25;
  blockHeight = (height-menuBarHeight)/4;  //=205 on laptop
  graphBlocks_x = 0;
  graphBlocks_w = (1-statsBloksWidth)*width;
  statsBlocks_x = (1-statsBloksWidth)*width;
  statsBlocks_w = statsBloksWidth*width;

  for (int i=0; i<4; i++)
  {
    blocks_y[i] = menuBarHeight + i*blockHeight;
  }


  beep = new SoundFile(this, "Beep.wav");   //Sound file
  peep = new SoundFile(this, "Peep.wav");   //Sound file

  cp5 = new ControlP5(this);                //GUI
  //minim = new Minim(this);                //FFT
  fft = new FFT(fft_BufferSize, 50);

  createTextAreas();
  drawStartup();
}

//DRAW_DRAW_DRAW_DRAW_DRAW_DRAW_DRAW_DRAW_DRAW_DRAW_DRAW_DRAW_DRAW_DRAW_DRAW_DRAW_DRAW_DRAW_DRAW_DRAW_DRAW_DRAW_DRAW_DRAW_DRAW_DRAW_DRAW_DRAW_DRAW_DRAW_DRAW_DRAW_DRAW_DRAW_DRAW_
void draw()
{
  drawLoop();

  //Plot graphs
  if (plotGraph[0])
  {
    p1.plot(int(f_red.filterOut[0]+50));
    p2.plot(int(f_ir.filterOut[0]+50));
    p3.plot(ssf[1]+100);
  }
  if (!fftOn)
  {
    if (plotGraph[1])
    {
      p4.plot(beatPeriodMillis[0]/10);
    }
    if (plotGraph[2])
    {
      p5.plot(int(205*((dieTemp-25)/20)));
      p6.plot(int(205*((objTemp-25)/20)));
    }
  }

  //Plot stats blocks
  if (plotBeatStats)
  {
    plotBeatStats();
  }
  if (plotSp02Stats)
  {
    plotSp02Stats();
  }
  if (plotTempStats)
  {
    plotTempStats();
  }
  if (plotFFT)
  {
    plotFFT();
  }

  //Clear the beating heart-----------------------------------------------------------
  if (millis() - prev_beatMillis > 150)
  { 
    fill(0);
    stroke(0);
    rect(statsBlocks_x+0.85*statsBlocks_w-30, blocks_y[0]+0.5*blockHeight-20, 60, 40);
  }//---------------------------------------------------------------------------------


  checkSerial();   //If the COM port could not be opened -> display message
  writeToFiles();  //Write to the text file
}

//---------------------------------------SERIAL_EVENT---------------------------------------------------
void serialEvent(Serial myPort)   //this is called whenever data is sent over by the arduino
{
  inString = myPort.readString();
  serialHandler(inString);
}

//---------------------------------------Mouse Clicked---------------------------------------------------

void mouseClicked()
{
  if (mouseX>0 && mouseX<100 && mouseY<60)            //Refresh button pressed
  {
    myPort.stop();
    startSerial(portName, baud);  //Re-open serial
  } else if (mouseX>100 && mouseX<200 && mouseY<60)   //FFT button pressed
  {
    if (fftOn)
    {
      fftOn = false;
      beatPeriodTextArea.show();
      sp02TextArea.show();
      objectTempTextArea.show();
      ambientTempTextArea.show();
      clearBackground();
    } else
    {
      fftOn = true;
      beatPeriodTextArea.hide();
      sp02TextArea.hide();
      objectTempTextArea.hide();
      ambientTempTextArea.hide();
    }
  } else if (mouseX>200 && mouseX<300 && mouseY<60)    //Recording button pressed
  { 
    if (!recording_A && !recording_B)
    {
      preRecording = !preRecording;
      countDown = countDownLength;
    } else
    {
      recording_A = false;
      recording_B = false;
      preRecording = false;
    }
    clearBackground();
  } else
  {
    println("Program closed");
    if (serialOpen)
    {
      myPort.stop();
    }
    exit();  // Stops the program
  }
}