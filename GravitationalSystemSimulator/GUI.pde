StringList logList  = new StringList();
Textarea logArea;
float SUNMASS = 2e8;
int minGuiSpeed = 1;
int maxGuiSpeed = 3000;
int minGuiPlanets = 1;
int maxGuiPlanets = 100;

float minGuiRandVel = 1.0;
float maxGuiRandVel = 200.0;
float minGuiRandMass = 100.0; 
float maxGuiRandMass = 2e9;
float minGuiRandRad = 2000.0;
float maxGuiRandRad = 9e7;
float minGuiVisScale = 1.0;
float maxGuiVisScale = 1000.0;
float minGuiAccelScale = 0;
float maxGuiAccelScale = 20000;
float minGuiGravity = 0.1;
float maxGuiGravity = 100.0;

boolean bTail = true;
float accelScale = 0;


void createGUI() {
  cp5 = new ControlP5(this);
  int yPos = 15;
  int grpXpos = 10;
  int grpYpos = 25;
  int xPos = 5;
  int btnWidth = 50;
  int controllerH = 10;
  int ctrSpace = controllerH+20;
  int sliderW = 250;

   Group g1 = cp5.addGroup("SYSTEM PRESETS")
                .setPosition(grpXpos,grpYpos)
                .setBackgroundColor(color(255,50))
                .setWidth(sliderW+20);
                
     
 cp5.addSlider( "sliderNumPlanets", minGuiPlanets, maxGuiPlanets, numPlanets, 
                 xPos, yPos, 
                 sliderW, controllerH)
    .setLabel("Number of Planets")
    .setGroup(g1)
    .getCaptionLabel().getStyle().movePadding(-controllerH, 0, 0, -sliderW+controllerH+btnWidth);
  
  cp5.addSlider("sliderSunMass", minGuiRandMass, maxGuiRandMass, SUNMASS, xPos, yPos+=ctrSpace, sliderW, controllerH)
    .setLabel("Sun Mass")
    .setGroup(g1)
    .getCaptionLabel().getStyle().movePadding(-controllerH, 0, 0, -sliderW);

  cp5.addRange("sliderRandVel")
    .setLabel("Max Random Initial Velocity")
    .setBroadcast(false) 
    .setPosition(xPos, yPos+=ctrSpace)
    .setSize(sliderW, controllerH)
    .setHandleSize(5)
    .setRange(minGuiRandVel, maxGuiRandVel)
    .setRangeValues(10.0, 100.0)
    // after the initialization we turn broadcast back on again
    .setBroadcast(true)
    .setGroup(g1)
    .getCaptionLabel().getStyle().movePadding(-controllerH, 0, 0, -sliderW)
    ;
  cp5.addRange("sliderRandMass")
    .setLabel("Max Random Mass")
    .setBroadcast(false) 
    .setPosition(xPos, yPos+=ctrSpace)
    .setSize(sliderW, controllerH)
    .setHandleSize(5)
    .setRange(minGuiRandMass, maxGuiRandMass)
    .setRangeValues(150.0, 1500.0)
    // after the initialization we turn broadcast back on again
    .setBroadcast(true)
    .setGroup(g1)
    .getCaptionLabel().getStyle().movePadding(-controllerH, 0, 0, -sliderW);

  cp5.addRange("sliderRandRad")
    .setLabel("Max Random Initial Distance")
    .setBroadcast(false) 
    .setPosition(xPos, yPos+=ctrSpace)
    .setSize(sliderW, controllerH)
    .setHandleSize(5)
    .setRange(minGuiRandRad, maxGuiRandRad)
    .setRangeValues(2e3, 2e5)
    // after the initialization we turn broadcast back on again
    .setBroadcast(true)
    .setGroup(g1)
    .getCaptionLabel().getStyle().movePadding(-controllerH, 0, 0, -sliderW);
    
    
     cp5.addButton("btnRandomize")
    .setValue(0)
    .setPosition(xPos+(sliderW-btnWidth)/2, yPos+=ctrSpace)
    .setSize(btnWidth, controllerH)
    .setLabel("Randomize")
    .setGroup(g1)
    .getCaptionLabel().getStyle().movePadding(-controllerH, 0, 0, 0);
 
    
   g1.setBackgroundHeight(yPos+=2*controllerH);
   grpYpos += yPos+2*controllerH;
   yPos = 15;
   Group g2 = cp5.addGroup("SIMULATION PARAMETERS")
                .setPosition(grpXpos,grpYpos)
                .setBackgroundColor(color(255,50))
                .setWidth(sliderW+20);
  
  cp5.addSlider("sliderSpeed", minGuiSpeed, maxGuiSpeed, 10, xPos, yPos, sliderW, controllerH)
    .setLabel("Simulation Speed")
    .setGroup(g2)
    .getCaptionLabel().getStyle().movePadding(-controllerH, 0, 0, -sliderW);

  cp5.addSlider("sliderGravity", minGuiGravity, maxGuiGravity, GRAVITY, xPos, yPos+=ctrSpace, sliderW, controllerH)
    .setLabel("Gravity")
    .setGroup(g2)
    .getCaptionLabel().getStyle().movePadding(-controllerH, 0, 0, -sliderW);

  cp5.addSlider("sliderAccelScale", minGuiAccelScale, maxGuiAccelScale, accelScale, xPos, yPos+=ctrSpace, sliderW, controllerH)
    .setLabel("Acceleration Vector Scale")
    .setGroup(g2)
    .getCaptionLabel().getStyle().movePadding(-controllerH, 0, 0, -sliderW);

  cp5.addSlider("sliderVisScaleSun", minGuiVisScale, maxGuiVisScale, visualScaleSun, xPos, yPos+=ctrSpace, sliderW, controllerH)
    .setLabel("Sun Visual Scale")
    .setGroup(g2)
    .getCaptionLabel().getStyle().movePadding(-controllerH, 0, 0, -sliderW);

  cp5.addSlider("sliderVisScalePlanet", minGuiVisScale, maxGuiVisScale, visualScalePlanet, xPos, yPos+=ctrSpace, sliderW, controllerH)
    .setLabel("Planets Visual Scale")
    .setGroup(g2)
    .getCaptionLabel().getStyle().movePadding(-controllerH, 0, 0, -sliderW);
 
  // create a toggle
  cp5.addToggle("followSun")
    .setPosition(xPos, yPos+=ctrSpace)
    .setSize(btnWidth, controllerH)
    .setValue(false)
    .setLabel("Follow Sun")
    .setGroup(g2)
    .getCaptionLabel().getStyle().movePadding(round(-controllerH*2.3), 0, 0, 2);

   g2.setBackgroundHeight(yPos+=2*controllerH);
   grpYpos += yPos+2*controllerH;
   yPos = 15;

      Group g3 = cp5.addGroup("KEYBOARD COMMANDS")
                .setPosition(grpXpos,grpYpos)
                .setBackgroundHeight(130)
                .setBackgroundColor(color(255,50))
                .setWidth(sliderW+20);

  cp5.addTextlabel("labelKeys")
    .setPosition(xPos, yPos)
    .setText("   'f' toggle follow Sun\n\n"+
             "   'g' show/hide GUI\n\n"+
             "   'h' draw/hide tails\n\n"+
             "   'i' draw/hide IDs\n\n"+
             "   's' save frame"
             )
    .setGroup(g3)
    //                    .setFont(createFont("Georgia",20))
    ;

   

  cp5.addTextlabel("labelFPS")
    .setPosition(width-25, 20)
    //                    .setFont(createFont("Georgia",20))
    ;
   

  Group g4 = cp5.addGroup("LOG")
                .setPosition(0, height-80)
                .setBackgroundHeight(90)
                .setBackgroundColor(color(255,50))
                .setWidth(width);
                
  logArea = cp5.addTextarea("loglist")
    .setPosition(0, 0)
    .setSize(width, 90)
    .setColor(color(80, 80, 120))
    .setFont(createFont("Courier", 10))
    .setGroup(g4);
   
  cp5.setAutoDraw(false);
}


void printLog(String log) {
  logList.append(nf(hour(), 2)+":"+nf(minute(), 2)+":"+nf(second(), 2)+" - "+log);
  if (logList.size() > 7) logList.remove(0);

  String fullStr="";
  for (String s : logList)
    fullStr+=s+"\n";

  logArea.setText(fullStr);
}


public void sliderNumPlanets(int theValue) {
  numPlanets = theValue;
}

// an event from slider sliderA will change the value of textfield textA here
public void sliderSpeed(float theValue) {
  // Textfield txt = ((Textfield)cp5.getController("textA"));
  // txt.setValue(""+theValue);
  iterationsPerFrame = round(theValue);
}

void controlEvent(ControlEvent theControlEvent) {
  if (theControlEvent.isFrom("sliderRandVel")) {
    minRandVel = theControlEvent.getController().getArrayValue(0);
    maxRandVel = theControlEvent.getController().getArrayValue(1);
  } else if (theControlEvent.isFrom("sliderRandRad")) {
    minRandRad = theControlEvent.getController().getArrayValue(0);
    maxRandRad = theControlEvent.getController().getArrayValue(1);
  } else if (theControlEvent.isFrom("sliderRandMass")) {
    minRandMass = theControlEvent.getController().getArrayValue(0);
    maxRandMass = theControlEvent.getController().getArrayValue(1);
    MIN_RADIUS = pow(minRandMass*RADIUS_FACTOR, 0.333333333);
    MAX_RADIUS = pow(maxRandMass*RADIUS_FACTOR, 0.333333333);
  }
}

public void sliderGravity(float theValue) {
  GRAVITY = theValue;
}
public void sliderVisScaleSun(float theValue) {
  visualScaleSun = theValue;
}
public void sliderVisScalePlanet(float theValue) {
  visualScalePlanet = theValue;
}
public void sliderAccelScale(float theValue) {
  accelScale = theValue;
}
public void sliderSunMass(float theValue) {
  SUNMASS = theValue;
}


void  mouseDragged() {
  mousePressed();
}

void  mousePressed() {
  if (mouseX > 80 && mouseX < 130 && mouseY > 80 && mouseY < 280) {
    cam.setActive(false);
  } else {
    cam.setActive(true);
  }
  // print the current mouseoverlist on mouse pressed
  if (cp5.getWindow().getMouseOverList().size() > 0) cam.setActive(false);
}

void mouseReleased() {
  cam.setActive(true);
}



public void btnRandomize(int theValue) {
  randomizePlanets();
}
