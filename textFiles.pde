String FolderName;
String date;


void createTextFiles()
{
  //Create text files for storing data
  ppgText = createWriter(FolderName + "/ppgText.txt");
  ppgText.println("Data recorded on " + date);
  ppgText.println("Time: " + hour() + ":" +  minute () + ":" +  second());
  ppgText.println("Time\t\tMillis\t\tIR PPG\t\tRed PPG\t\tFiltered\t\tSSF");

  beatText = createWriter(FolderName + "/beatText.txt");
  beatText.println("Data recorded on " + date);
  beatText.println("Time: " + hour() + ":" +  minute () + ":" +  second());
  beatText.println("Time\t\tMillis\t\tbpm\t\tPeriod\t\tSpO2");

  tempText = createWriter(FolderName + "/tempText.txt");
  tempText.println("Data recorded on " + date);
  tempText.println("Time: " + hour() + ":" + minute () + ":" +  second());
  tempText.println("Time\t\tMillis\t\tobjTemp\t\tdieTemp\t\tsensorVoltage");

  respText = createWriter(FolderName + "/respText.txt");
  respText.println("Data recorded on " + date);
  respText.println("Time: " + hour() + ":" + minute () + ":" +  second());
  respText.println("Breathing cycle millis");
}

void writeToFiles()
{
  if (writePPG && recording_A || writePPG && recording_B)
  {
    ppgText.print(minute() + "," + second() + "\t,\t" + millisPPG + "\t,\t");
    ppgText.print(irPPG + "\t,\t" + redPPG + "\t,\t");
    ppgText.print(f_ir.filterOut[0] + "\t,\t");
    ppgText.println(ssf[1]);
    writePPG = false;
  }

  if (writeBeat && recording_A || writePPG && recording_B)
  {
    beatText.print(minute() + "," + second() + "\t,\t" + millisBeat + "\t,\t");
    beatText.println(bpm + "\t,\t" + beatPeriodMillis[0] + "\t,\t" + sp02);
    writeBeat = false;
  }

  if (writeTemp && recording_A || writePPG && recording_B)
  {
    tempText.print(minute() + "," + second() + "\t,\t" + millisTemp + "\t,\t");
    tempText.println(objTemp + "\t,\t" + dieTemp + "\t,\t" + sensorVolt);
    writeTemp = false;
  }
}

void flushTextFiles()
{
  ppgText.flush();  // Writes the remaining data to the file
  ppgText.close();  // Finishes the file

  beatText.flush();  // Writes the remaining data to the file
  beatText.close();  // Finishes the file

  tempText.flush();  // Writes the remaining data to the file
  tempText.close();  // Finishes the file

  respText.flush();  // Writes the remaining data to the file
  respText.close();  // Finishes the file

  patientName.flush();  // Writes the remaining data to the file
  patientName.close();  // Finishes the file
}