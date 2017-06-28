//DC Removal variables
float red_w = 0;
float ir_w = 0;
float irAC;
float irDC;
float redAC;
float redDC;

//Moving average function variables
float movingAverage;
float prev_movingAverage;
float movingSum;
int totalSamples = 31;
int numInMovingAverage = 8;
int numOfSamples = 0;
int[] pulsOxi_arr = new int[totalSamples];          //Keep track of the latest n Pulse oxi readings

//Sample period
long millisPPG;
long millisBeat;
long millisSp02;
long millisTemp;
long startMillis = millis();

//Moving FFT calculation varaibles
int fft_BufferSize = 128;
float fft_Buffer[] = new float[fft_BufferSize];    //Contains the last 1024 pulse oxi samples

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void pulseOxiProcessing(int irPPG_raw, int redPPG_raw)
{ 
  millisPPG = millis()-startMillis;
  
  r_ir.removeDC(irPPG_raw);
  r_red.removeDC(redPPG_raw);
  
  f_ir.lowpassFilter(int(r_ir.ac));
  f_red.lowpassFilter(int(r_red.ac));
  f_irDC.lowpassFilter(int(r_ir.dc));
  f_redDC.lowpassFilter(int(r_red.dc));
  
  slopeSumming(f_ir.filterOut);
  beatDetection(ssf);
  movingFFT(f_ir.filterOut[0]);
  sp02Calc(f_ir.filterOut[0], f_red.filterOut[0], f_irDC.filterOut[0], f_redDC.filterOut[0]);

  plotGraph[0] = true;
}