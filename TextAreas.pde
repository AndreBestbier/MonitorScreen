void createTextAreas()
{
  beatPeriodTextArea = cp5.addTextarea("txt1")
    .setPosition(10, blocks_y[3]+1)
    .setSize(100, blockHeight-10)
    .setFont(createFont("arial", 12))
    .setLineHeight(14)
    .setColor(color(225))
    .setColorBackground(color(0))
    .setColorForeground(color(225))
    ;
  beatPeriodTextArea.setText("Beat Periods");

  sp02TextArea = cp5.addTextarea("txt2")
    .setPosition(120, blocks_y[3]+1)
    .setSize(100, blockHeight-10)
    .setFont(createFont("arial", 12))
    .setLineHeight(14)
    .setColor(color(225))
    .setColorBackground(color(0))
    .setColorForeground(color(225))
    ;
  sp02TextArea.setText("Sp02");

  objectTempTextArea = cp5.addTextarea("txt3")
    .setPosition(230, blocks_y[3]+1)
    .setSize(100, blockHeight-10)
    .setFont(createFont("arial", 12))
    .setLineHeight(14)
    .setColor(color(225))
    .setColorBackground(color(0))
    .setColorForeground(color(225))
    ;
  objectTempTextArea.setText("Object Temp");

  ambientTempTextArea = cp5.addTextarea("txt4")
    .setPosition(340, blocks_y[3]+1)
    .setSize(100, blockHeight-10)
    .setFont(createFont("arial", 12))
    .setLineHeight(14)
    .setColor(color(225))
    .setColorBackground(color(0))
    .setColorForeground(color(225))
    ;
  ambientTempTextArea.setText("Ambient Temp");
}