
//-------------------------------------STATIC ELEMENTS DRAWN ONCE IN THE BEGININING---------------------------------------------------------------------------------------------------------
void drawStartup()
{
  fill(0);
  stroke(#0024FF);
  rect(statsBlocks_x, blocks_y[0], statsBlocks_w, blockHeight);
  rect(statsBlocks_x, blocks_y[1], statsBlocks_w, blockHeight);
  rect(statsBlocks_x, blocks_y[2], statsBlocks_w, blockHeight);
  rect(statsBlocks_x, blocks_y[3], statsBlocks_w, blockHeight);

  stroke(#0024FF);
  fill(0);
  rect(graphBlocks_x, blocks_y[0], graphBlocks_w, blockHeight);
  rect(graphBlocks_x, blocks_y[1], graphBlocks_w, blockHeight);
  rect(graphBlocks_x, blocks_y[2], graphBlocks_w, blockHeight);
  rect(graphBlocks_x, blocks_y[3], graphBlocks_w, blockHeight);

  fill(#0024FF);
  textSize(22); 
  textAlign(LEFT, TOP);
  text("HR", statsBlocks_x+10, blocks_y[0]+30);
  text("bpm", statsBlocks_x+10, blocks_y[0]+55);
  text("Sp02", statsBlocks_x+10, blocks_y[1]+30);
  text("%", statsBlocks_x+10, blocks_y[1]+55);
  text("Temp", statsBlocks_x+10, blocks_y[2]+30);
  text("\u00b0C", statsBlocks_x+10, blocks_y[2]+55);
}




//------------------------------------DRAW IN THE BEGINNING OF EACH LOOP-------------------------------------------
int prevFlashSecond = second();
boolean flash = true;

void drawLoop()
{ 
  //Titlebar and Title
  fill(0);
  stroke(#0024FF);
  rect(0, 0, width, menuBarHeight);
  fill(255);
  textSize(40);
  textAlign(CENTER, CENTER);
  text("E A R - M O N I T O R", width/2, 26);

  //Time
  fill(255);
  textSize(40);
  text(hour() + ":" + minute() + ":" + second(), width-320, 26);

  //Menu buttons
  if (fftOn) fill(0, 255, 0); //FFT
  else fill(0);
  rect(100, 0, 100, 60);

  if (recording_A || recording_B) fill(255, 0, 0); //Recording
  else fill(0);
  rect(200, 0, 100, 60);

  fill(0);
  rect(0, 0, 100, 60);          //Burger
  rect(width-100, 0, 100, 60);  //Battery
  rect(width-200, 0, 100, 60);  //Connect status

  //Draw Button Icons
  textSize(30);
  fill(255);
  textAlign(CENTER, CENTER);
  text("FFT", 150, 28);
  imageMode(CENTER);
  image(battery_Img, width-50, 30, 50, 25);
  image(refresh_Img, 50, 30, 40, 40);
  image(record_Img, 250, 30, 40, 40);
  if (serialOpen) 
  {
    image(bluetooth_Img, width-150, 30, 25, 30);
  }
  if (runWhithoutSerial)
  {
    if (second()!=prevFlashSecond)
    {
      flash = !flash;
      prevFlashSecond = second();
    }

    if (flash)
    {
      text("No Device!", 500, 28);
    }
  }

  fill(#0024FF);
  textSize(22); 
  textAlign(LEFT, TOP);
  text("Alarms", statsBlocks_x+10, blocks_y[3]+30);
  textSize(19); 
  text("HR: Hi=180, Low=50\nBreathig: Low=15\nSp02: Low=90%\nTemp: Hi=38\u00b0C, Low=35.5\u00b0C", statsBlocks_x+10, blocks_y[3]+60);
  fill(0);

  if (!fftOn)
  {
    fill(0);
    noStroke();
    rect(10, blocks_y[0]+10, 40, 30);
    rect(10, blocks_y[1]+10, 115, 30);
    rect(10, blocks_y[2]+10, 155, 30);

    fill(#0024FF);
    textSize(22);
    text("HR", 10, blocks_y[0]+10);
    text("Breathing", 10, blocks_y[1]+10);
    text("Temperature", 10, blocks_y[2]+10);
  }

  //Recording process
  if (preRecording)
  {
    preRecordingFunction();
  }
  if (recording_A)
  {
    recordingFunction_A();
  }
  if (recording_B)
  {
    recordingFunction_B();
  }
}

//Recodring and prerecording variables
String recordingName;
boolean preRecordingSetup = false;
int countDown = 11;
int countUp = 0;
int prevSecond = second();
int startSecond;
int countDownLength = 10;
int recordingLength_A = 60;
int recordingLength_B = 60;

//--------------------------------------preRecordingFunction--------------------------------------
void preRecordingFunction()
{
  if (!preRecordingSetup)
  {
    //Date variables
    Date d = new Date();
    date = trim(d.toString().replaceAll(":", "-"));

    //Ask user for recording name and create a text file with the recording name
    recordingName = JOptionPane.showInputDialog("Enter recording name:");  
    FolderName = (recordingName + "_" + date);

    //Create text file with recordingName
    patientName = createWriter(FolderName + "/" + recordingName + ".txt");
    patientName.println("Data recording countdown (10s) started at: " + hour() + "-" + minute() + "-" + second());

    createTextFiles();
    preRecordingSetup = true;
  }

  //Countdown Window
  fill(0);
  stroke(#0024FF);
  rectMode(CENTER); 
  strokeWeight(4);
  rect(0.5*width, 0.5*height, 800, 300);
  rectMode(CORNER); 
  strokeWeight(1);

  //Text
  fill(255);
  textAlign(CENTER, CENTER);
  text("Recording for " + recordingName, 0.5*width, 0.5*height-130);
  text("Starting in: ", 0.5*width, 0.5*height-100);

  //Countdown
  if (prevSecond != second())
  {
    countDown--;
    prevSecond = second();
    if (countDown <= 8 && countDown != 0)
    {
      beep.play();
    }
  }

  if (countDown <= 8)
  {
    textSize(150);
    text(countDown, 0.5*width, 0.5*height+20);
  }


  //If the countdown is done
  if (countDown == 0)
  {
    //Place marker in BioTrace
    robot.mouseMove(10, 200);
    robot.mousePress(InputEvent.BUTTON1_MASK);
    peep.play();
    robot.mouseRelease(InputEvent.BUTTON1_MASK);
    robot.keyPress(KeyEvent.VK_SPACE);  
    robot.keyRelease(KeyEvent.VK_SPACE);

    preRecording = false;
    recording_A = true;
    clearBackground();
    countDown = countDownLength;
    startSecond = second();
  }
}

//-------------------------------------------------recordingFunction_A---------------------------------------
void recordingFunction_A()
{
  //Counter upper
  if (prevSecond != second())
  {
    if (countUp>=recordingLength_A-4)
    {
      if  (countUp != recordingLength_A-1)
      {
        beep.play();
      }

      fill(0);
      rect(statsBlocks_x/3, blocks_y[2]-130, 500, 125);

      textSize(50);
      fill(#0024FF);
      textAlign(CENTER, CENTER);
      text("Breathing test in: ", statsBlocks_x/2, blocks_y[2]-55);
      text(recordingLength_A-countUp-1, statsBlocks_x/2, blocks_y [2]-100);
    }

    countUp++;
    prevSecond = second();
  }
  fill(255);
  textSize(50);
  text(countUp, 350, 2);

  //After the recording time is done
  if (countUp == recordingLength_A)
  {
    peep.play();
    fill(0);
    rect(statsBlocks_x/3, blocks_y[2]-130, 500, 125);
    recording_A = false;
    recording_B = true;
    prevMillis = millis();
    beginMillis = millis();
  }
}

//Breathing box variables
float inc = 20;
int prevMillis;
int prevCenti = 0;
int beginMillis;
float load = 0;
int count = 0;
int grad = 1;

//----------------------------------------------recordingFunction_B---------------------------------------------------------
void recordingFunction_B()
{
  if (prevSecond != second())
  {
    countUp++;
    prevSecond = second();
  }
  fill(255);
  textSize(50);
  text(countUp, 350, 5);

  if (int((millis()-beginMillis)/100) != prevCenti)  //Every 100 ms
  {
    //Set the increment and the gradient
    prevCenti = int((millis()-beginMillis)/100);
    prevMillis = millis();
    load = load+grad*inc;
    if (load <= 0)
    {
      respText.println("Empty: " + millis());
      grad = -grad;
      count++;
      load = 0;
    } else if (load >= 400)
    {
      respText.println("Full: " + millis());
      grad = -grad;
      count++;
      load = 400;
    }

    //Breathing Box
    fill(0);
    stroke(#0024FF);
    strokeWeight(4);
    rect(statsBlocks_x/3, blocks_y[2]-55, 400, 50);
    strokeWeight(1);
    fill(#0024FF);
    rect(statsBlocks_x/3, blocks_y[2]-55, load, 50);

    //After the recording time is done
    if (countUp == recordingLength_A+recordingLength_B)
    {
      //Place marker in BioTrace
      robot.mouseMove(10, 200);
      robot.mousePress(InputEvent.BUTTON1_MASK);
      peep.play();
      robot.mouseRelease(InputEvent.BUTTON1_MASK);
      robot.keyPress(KeyEvent.VK_SPACE);  
      robot.keyRelease(KeyEvent.VK_SPACE);

      recording_B = false;
      countUp = 0;

      //Clear the breathing box
      fill(0);
      stroke(0);
      strokeWeight(5);
      rect(statsBlocks_x/3, blocks_y[2]-55, 400, 50);
      strokeWeight(1);
      flushTextFiles();
    }
  }
}

//--------------------------------------------------------clearBackground---------------------------------------------
void clearBackground()
{
  p1.clearGraph(0);
  p2.clearGraph(0);
  p3.clearGraph(0);
  p4.clearGraph(0);
  p5.clearGraph(0);
  p6.clearGraph(0);
}
//--------------------------------------------------plotBeat StatsBlock-------------------------------------------------------------------------------------------------

void plotBeatStats()
{
  fill(0);
  stroke(#0024FF);
  rect(statsBlocks_x, blocks_y[0], statsBlocks_w, blockHeight);

  fill(#0024FF);
  textSize(22); 
  textAlign(LEFT, TOP);
  text("HR", statsBlocks_x+10, blocks_y[0]+30);
  text("bpm", statsBlocks_x+10, blocks_y[0]+55);

  imageMode(CENTER);
  image(heart_Img, statsBlocks_x+0.85*statsBlocks_w, blocks_y[0]+0.5*blockHeight, 60, 40);
  fill(#FF0000);    //Set the color to red
  stroke(#FF0000);    //Set the color to red
  ellipse(p3.x_new-2, blocks_y[1]-ssf[1]-100, 6, 6);

  textSize(100);
  textAlign(RIGHT, CENTER);
  text(bpm, statsBlocks_x+0.7*statsBlocks_w, blocks_y[0]+0.5*blockHeight);

  beatPeriodTextArea.append("\n" + str(beatPeriodMillis[0]));

  //fill(#FF0000);
  //stroke(#FF0000);
  ////line(p3.x_new+beatPeriodMillis[0]*0.8,70, p3.x_new+beatPeriodMillis[0]*0.8, 100);
  ////line(p3.x_new+beatPeriodMillis[0]*1.5,70, p3.x_new+beatPeriodMillis[0]*1.5, 100);

  plotBeatStats = false;
}

//--------------------------------------------------plotSp02 StatsBlock-------------------------------------------------------------------------------------------------
void plotSp02Stats()
{

  fill(0);
  stroke(#0024FF);
  rect(statsBlocks_x, blocks_y[1], statsBlocks_w, blockHeight);

  fill(#0024FF);
  textSize(22); 
  textAlign(LEFT);
  text("Sp02", statsBlocks_x+10, blocks_y[1]+30);
  text("%", statsBlocks_x+10, blocks_y[1]+55);

  float temp = round(sp02*100);

  fill(#FF0000);    //Set the color to red
  textSize(100);
  textAlign(RIGHT, CENTER);
  text(str(temp/100), statsBlocks_x+0.85*statsBlocks_w, blocks_y[1]+0.5*blockHeight);

  sp02TextArea.append("\n" + str(sp02));
  plotSp02Stats = false;
}

//-------------------------------------------------------plotTemp StatsBlock-----------------------------------------------------------------------------------------

void plotTempStats()
{
  fill(0);
  stroke(#0024FF);
  rect(statsBlocks_x, blocks_y[2], statsBlocks_w, blockHeight);

  fill(#0024FF);
  textSize(22); 
  textAlign(LEFT);
  text("Temp", statsBlocks_x+10, blocks_y[2]+30);
  text("\u00b0C", statsBlocks_x+10, blocks_y[2]+55);

  float temp = round(objTemp*10);

  fill(#FF0000);    //Set the color to red
  textSize(100);
  textAlign(RIGHT, CENTER);
  text(str(temp/10), statsBlocks_x+0.85*statsBlocks_w, blocks_y[2]+0.5*blockHeight);

  objectTempTextArea.append("\n" + str(objTemp));
  ambientTempTextArea.append("\n" + str(dieTemp));

  plotTempStats = false;
}

//-------------------------------------------------------plotFFT----------------------------------------------------------------------------------------------

void plotFFT()
{
  fill(0);
  stroke(#0024FF);
  rect(0, blocks_y[1], statsBlocks_x, 3*blockHeight);

  //float sum = 0;
  fft.linAverages(20);
  fft.forward(fft_Buffer);

  stroke(255);
  fill(255);
  for (int i = 0; i < fft.specSize(); i++)
  {
    // draw the line for frequency band i, scaling it up a bit so we can see it
    float temp = (fft.getBand(i)*0.1);
    if (temp>3*blockHeight)
    {
      temp = (3*blockHeight)-1;
    }
    rect((statsBlocks_x/fft_BufferSize)*i, height - int(temp), (statsBlocks_x/fft_BufferSize), int(temp));
    if (i>30)
    {
      //sum = sum+temp;
    }
  }
  //println(sum);
  //p2.plot(int(sum)+30);
  //sum = 0;

  plotFFT = false;
}