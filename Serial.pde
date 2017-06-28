void serialHandler(String input)
{
  char label = input.charAt(0);
  switch (label)
  {
  case 'e':
    eeg = input.substring(2);
    break;

  case 'i':
      irPPG = -int(input.substring(2).trim());  //Remove label, remove black spaces and convert to int
    break;

  case 'r':
      redPPG = -int(input.substring(2).trim());
      pulseOxiProcessing(irPPG, redPPG);
    break;

  case 'd':
      dieTemp = float(input.substring(2).trim());
    break;

  case 'o':
      objTemp = float(input.substring(2).trim());//Remove label, remove black spaces and convert to int
    break;

  case 'v':
      sensorVolt = float(input.substring(2).trim());//Remove label, remove black spaces and convert to int
      millisTemp = millis();
      plotGraph[2] = true;
      plotTempStats = true;
      writeTemp = true;
    break;

  default:
    println("Unrecognized data from serial port: " + input);
    break;
  }
}

//-----------------------------------------------------------------------------------------------------------------------------------

void startSerial(String portName, int baud)
{
  printArray(Serial.list());
  try
  {
    myPort = new Serial(this, portName, baud);  //Set up the serial port
    myPort.bufferUntil(10);                     //Read in data until a line feed (10 is ASCII for new line), so the arduino must do a println
    println(portName + " opened!");
    serialOpen = true;
  } 
  catch (RuntimeException e)
  {
    println(portName + " cannot be opened, check connections and try again");
  }
}

void checkSerial()
{
  //If the COM port could not be opened -> display message
  if (!serialOpen && !runWhithoutSerial)
  {
    if (JOptionPane.showConfirmDialog(null, portName + " cannot be opened.\nRecconnect?", "PROBLEM", JOptionPane.YES_NO_OPTION) == JOptionPane.YES_OPTION)
    {
      println("Attempting to reconnect");
      startSerial(portName, baud);  //Open the COM port: portName
    } else
    {
      println("No device connected");
      runWhithoutSerial = true;
    }
  }//----------------------------------------------------------------------------------------------------
}