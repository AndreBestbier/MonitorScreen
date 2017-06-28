//-----------------------------------------------------------------Slope Summing Function-------------------------------------
int[] ssf = new int [3];

void slopeSumming(float[] filteredVals)
{
  int tempSSF = 0;
  ssf[2] = ssf[1];
  ssf[1] = ssf[0];

  for (int i = 0; i < 9; i++)
  {
    float delta_SSF = filteredVals[i] - filteredVals[i+1];
    if (delta_SSF>0)
    {
      tempSSF = tempSSF + int(delta_SSF);
    }
    ssf[0] = tempSSF;
  }
  writePPG = true;
}

//Beat detection variables
int beatPeriodSum;                        //Sum of the previous '5' heart beat periods
int numBeatsInAverage = 10;
int[] beatPeriodMillis = new int[numBeatsInAverage];
int beatPeriodAverage;          //Averge HR period in ms

int prev_beatMillis;            //Previous beat period     
int beatDelay = 840;            //Time to wait after searching for next beat -> 72bpm (initial value, but dinamically updated)
float threshold = 2;              //Minimum height of SSF peak detected as a beat
int[] peakHeight = new int[3];  //Store the y values of the 3 most recent peaks
boolean first = true;



//-----------------------------------------------------Beat detection-------------------------------------------------------
void beatDetection(int[] ssf)
{
  
  int tempBeatPeriod = millis()-prev_beatMillis;
  if (first)
  {
    peakHeight[2] = 5;
    peakHeight[1] = 5;
    peakHeight[0] = 5;
    first = false;
  }

  threshold = (((peakHeight[0]+peakHeight[1]+1)/3)*0.5);
  if (threshold>50)
  {
    threshold = 10;
  }
  
  //println(ssf[1] + "\t" + threshold );

  if (ssf[1] > threshold && tempBeatPeriod > beatDelay && ssf[1]>ssf[2] && ssf[1]>=ssf[0])// || beatPeriodCounter > 1.3*beatPeriodSamplesAverage)
  {
    millisBeat = millis()-startMillis;  //Timestamp of betected beat

    peakHeight[2] = peakHeight[1];
    peakHeight[1] = peakHeight[0];
    peakHeight[0] = ssf[1];

    //Moving average array calculations
    beatPeriodSum -= beatPeriodMillis[numBeatsInAverage-1];  //Subtract last element from sum
    for (int i = numBeatsInAverage-1; i>0; i--)
    {
      beatPeriodMillis[i] = beatPeriodMillis[i-1];  //Shift all values in array
    }

    if (tempBeatPeriod>1500)
    {
      beatPeriodMillis[0] = 1500;
    } else if (tempBeatPeriod<500)
    {
      beatPeriodMillis[0] = 500;
    } else
    {
      beatPeriodMillis[0] = tempBeatPeriod;
    }

    prev_beatMillis = millis();
    beatPeriodSum += beatPeriodMillis[0];
    beatPeriodAverage = beatPeriodSum/numBeatsInAverage;
    bpm = 60000/beatPeriodAverage;

    beatDelay = int(0.7*beatPeriodAverage);

    calculateSpO2 = true;

    plotBeatStats = true;
    plotGraph[1] = true;
  }
}

//-------------------------------------------------Sp02 Calculation---------------------------------------------------------
//Sp02 Calculation variables
float redACsqrSum;
float irACsqrSum;
float redDCsqrSum;
float irDCsqrSum;

boolean calculateSpO2 = false;
float[] r_Sp02 = new float[10];
float r_Sp02_Sum = 0;

void sp02Calc(float irAC, float redAC, float irDC, float redDC)
{
  //Add new samples to moving root squared sum
  irACsqrSum += sqrt(irAC * irAC);
  redACsqrSum += sqrt(redAC * redAC);
  irDCsqrSum += sqrt(irDC * irDC);
  redDCsqrSum += sqrt(redDC * redDC);
  
  //Subtract old samples from 
  
  if (calculateSpO2)
  {
    millisSp02 = millis()-startMillis;    //SpO2 reading
    
    //Shift history of R values
    r_Sp02_Sum -= r_Sp02[9];
    for(int i = 9; i>0; i--)
    {
      r_Sp02[i] = r_Sp02[i-1];
    }
    r_Sp02[0] = (redACsqrSum/redDCsqrSum) / (irACsqrSum/irDCsqrSum);
    r_Sp02_Sum += r_Sp02[0];
    
    sp02 = 113-(25*(r_Sp02_Sum/10));

    if (sp02>100)
    {
      //sp02 = 100;
    }

    irACsqrSum = 0;
    redACsqrSum = 0;
    irDCsqrSum = 0;
    redDCsqrSum = 0;
    calculateSpO2 = false;
    //writeSp02 = true;
    plotSp02Stats = true;
    writeBeat = true;
  }
}

//-----------------------------------------------------------------Moving FFT-------------------------------------
void movingFFT(float input)
{
  for (int i=fft_BufferSize-1; i>0; i--)
  {
    fft_Buffer[i] = fft_Buffer[i-1];
  }
  fft_Buffer[0] = input;

  if (fftOn)
  {
    plotFFT = true;
  } else
  {
    fft.forward(fft_Buffer);
    float sum = 0;
    for (int i = 0; i < fft.specSize(); i++)
    {
      float temp = (fft.getBand(i)*0.1);
      if (i>0)  //Specify which bands to sum
      {
        sum = sum+temp;
      }
    }
    //println(sum);
    if (sum>1500)
    {
      noise = true;
    } else
    {
      noise = false;
    }
  }
}

//-----------------------------------------------------------------Moving Average-------------------------------------
void movingAverage(int pulseOxi)
{
  prev_movingAverage = movingAverage;
  movingSum -= pulsOxi_arr[numInMovingAverage-1];  //subtract the last element from the moving sum
  movingSum += pulseOxi;        //add the new element to the moving sum
  movingAverage = movingSum / numOfSamples;  //calculate average, divide by number of samples present in array

  for (int i = totalSamples-1; i>0; i--)
  {
    pulsOxi_arr[i] = pulsOxi_arr[i-1];  //shift all the elements to the left
  }
  pulsOxi_arr[0] = pulseOxi;  //load the new sample in the first position

  if (numOfSamples < numInMovingAverage)
  {
    numOfSamples++;    //inctement number of samples as samples are read, untill the array in full
  }
}