//Plotting objects of the class PlotGraph
PlotGraph p1 = new PlotGraph(1, 0, 2, 1, #00FFFF);  //(int x_O, int y_O, int x_I, int graphNum)
PlotGraph p2 = new PlotGraph(1, 0, 2, 1, #00FF00);
PlotGraph p3 = new PlotGraph(1, 0, 2, 1, #FF0000);
PlotGraph p4 = new PlotGraph(1, 0, 5, 2, #FFFF00);
PlotGraph p5 = new PlotGraph(1, 0, 10, 3, #00FFFF);
PlotGraph p6 = new PlotGraph(1, 0, 10, 3, #FF0000);

//DC Remover objects of the class DC_Remover
DC_Remover r_ir =  new DC_Remover(0.7);
DC_Remover r_red =  new DC_Remover(0.7);

//Filter objects of the class Filter
float[] b = { 0.0048, 0.0143, 0.0143, 0.0048};  //coeficients
float[] a = {1.0000, -2.2501, 1.7564, -0.4683}; //coeficients

Filter f_ir = new Filter(3, b, a, 10);
Filter f_red = new Filter(3, b, a, 3);
Filter f_irDC = new Filter(3, b, a, 3);
Filter f_redDC = new Filter(3, b, a, 3);

class PlotGraph
{
  int x_old, x_new, y_old, x_inc, pos;
  color col;

  PlotGraph(int x_O, int y_O, int x_I, int graphNum, color c)
  {
    x_old = x_O;
    x_new = x_O+x_I;
    y_old = y_O;
    x_inc = x_I;
    pos = graphNum;
    col = c;
  }

  void plot(int yVal)
  {
    if (yVal>=blockHeight)
    {
      yVal = blockHeight-1;
    }
    if (yVal<1)
    {
      yVal = 1;
    }

    stroke(col);
    line(x_old, blocks_y[pos]-y_old, x_new, blocks_y[pos]-yVal);

    y_old = yVal;
    x_old = x_new;
    x_new += x_inc;

    if (x_new > statsBlocks_x-1)
    {
      clearGraph(yVal);
    }
    plotGraph[pos-1] = false;
  }

  void clearGraph(int yVal)
  {
    stroke(#0024FF);
    fill(0);
    rect(graphBlocks_x, blocks_y[pos-1], graphBlocks_w, blockHeight);

    x_new = 1;
    x_old = 1;
    y_old = int(blocks_y[pos]) - yVal;
  }
}

class Filter
{
  int filterOrder;    //order of the filter
  int n;              //size of the coeficeint matrix
  int w;              //SSF window size, numbe of previous values to store
  float[] filterIn;   //stores the most recent n raw samples
  float[] filterOut;  //stores the most recent n filtered samples
  float[] b;          // = {0.0134,    0.0267,    0.0134};  //coeficients
  float[] a;          // = {1.0000,   -1.6475,    0.7009}; //coeficients

  Filter(int ordr, float[] bb, float[] aa, int ww)
  {
    filterOrder = ordr;
    n = filterOrder+1;    //Plus 1 because for a n_th order filter there are n+1 coeficients
    w = ww;               //SSF window size, numbe of previous values to store
    filterIn = new float[w+1];
    filterOut = new float[w+1];
    b = bb;    //coeficients
    a = aa;    //coeficients
  }

  void lowpassFilter(int input)
  {
    for (int i = w; i>0; i--)
    {
      filterIn[i] = filterIn[i-1];  //Shift all previous Input values one to the right
    }
    filterIn[0] = input;

    for (int i = w; i>0; i--)
    {
      filterOut[i] = filterOut[i-1];  //Shift all previous Output values one to the right
    }

    //Calculate the next filter output
    filterOut[0] = 0;
    for (int i = 0; i<n; i++)
    {
      filterOut[0] = filterOut[0] + b[i]*filterIn[i];
    }
    for (int i = 1; i<n; i++)
    {
      filterOut[0] = filterOut[0] - a[i]*filterOut[i];
    }

    filterOut[0] = filterOut[0]/a[0];
  }
}

class DC_Remover
{
  float alpha;               
  float w;
  float new_w;        
  float ac;
  float dc;

  DC_Remover(float a)
  {
    alpha = a;
  }

  void removeDC(int input)
  {
    new_w  = input + alpha*w;
    ac = new_w - w;
    dc = input - ac;
    w = new_w;
  }
}