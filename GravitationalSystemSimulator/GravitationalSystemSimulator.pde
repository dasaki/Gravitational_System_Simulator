/**
 * Planet Gravitational System Simulation
 * by David Sanz Kirbis
 * 2019
 *
 * Inspired in the example GravitationalAttraction3D
 * by Daniel Shiffman.  
 * 
 */
import peasy.*;
import controlP5.*;
import processing.opengl.*;

import java.util.*;

ControlP5 cp5;
PeasyCam cam;


// declare arrays and params for storing sin/cos values 
float acosLUT[]; // acos Look Up Table
// set table precision in radians
float AC_PRECISION = 0.0004f;
// caculate reciprocal for conversions
float AC_INV_PREC = 1.0/AC_PRECISION;
// compute required table length
int AC_PERIOD = round(2.0f*AC_INV_PREC);
int AC_PERIOD2 = round(AC_INV_PREC);

PVector sunInitPos = new PVector(0, 0, 0);

int numPlanets = 10;
// A bunch of planets
ArrayList<Planet> planets = new ArrayList<Planet>();

float iterationsPerFrame = 10;
float iterations = 0;

float MAX_DIST =9e9;
float INIT_CAM_DIST =9e5;

PFont myFont;

float w2;
float h2;

long lastDraw;


boolean drawHistory = true;
boolean lookUp = true;
boolean drawIds = false;
boolean followSun = true;
boolean bSaveFrame = false;
boolean bShowGUI = true;
PVector origin = new PVector(0, 0, 0);

// initialize vertex arrays
int conePts = 4;
float  coneLength = 2000;
float  coneRadius = 1000;
PVector[][]  cone = new PVector[2][conePts+1];

void setup() {
  size(1280, 720, P3D);
  w2 = width/2;
  h2 = height/2;
  // noSmooth();
  cam = new PeasyCam(this, 400);
  cam.setDistance(INIT_CAM_DIST/4.0);
  perspective(PI/3, float(width)/float(height), 1, 1000000000);
  myFont = createFont("Courier", 15);
  textFont(myFont);

  initAcos();

  prepareCone();
  createGUI();
  randomizePlanets();

  frameRate(10000000);
  lastDraw = millis();
}


void draw() {

  iterations += iterationsPerFrame;
  if (followSun) origin.set(planets.get(0).position);
  origin.set(new PVector(0, 0, 0));

  if (iterations >=1) {
    for (int i = 0; i < round(iterations); i++) {

      // All the Planets
      for (int j = 0; j < planets.size(); j++) {
        Planet planetj = planets.get(j);
        for (int k = j; k < planets.size(); k++) {
          Planet planetk = planets.get(k);
          if  (planetj.id != planetk.id) {
            planetj.attract(planetk);
            //  planetk.attract(planetj);
          }
        }
      }   
      for (Planet planet : planets) {
        planet.update(origin);
      }
    }
    iterations = 0;
  }
  if (millis()-lastDraw >= 20) {    
    background(0);
    // Setup the scene
    sphereDetail(8);
    if (followSun) translate( -planets.get(0).position.x, 
      -planets.get(0).position.y, 
      -planets.get(0).position.z );


    for (Planet planet : planets) planet.display();

    if (bShowGUI) gui();
    Textlabel txt = ((Textlabel)cp5.getController("labelFPS"));
    txt.setText(str(round(1000/(millis()-lastDraw))));
    lastDraw = millis();
  }

  if (bSaveFrame) saveFrame("frames/#####.tif");
}

void gui() {
  hint(DISABLE_DEPTH_TEST);
  cam.beginHUD();
  cp5.draw();
  cam.endHUD();
  hint(ENABLE_DEPTH_TEST);
}

void randomizePlanets() {

  planets.clear();
  randomSeed(second()*minute()*hour());
  for (int i = 0; i < numPlanets; i++) {
    Planet newPlanet = new Planet(i, random(minRandMass, maxRandMass), new PVector(0, 0, 0), new PVector(0, 0, 0));
    newPlanet.randomize(origin);
    planets.add(newPlanet);
  }
  Planet sun = planets.get(0);
  sun.velocity.set(0.1e-9, 0.1e-9, 0.1e-9);
  sun.prevVelocity.set(1, 1, 1);
  sun.prevVelocityMag= sun.prevVelocity.mag();
  sun.dist += sun.prevVelocityMag;
  sun.setMass(SUNMASS);
  sun.setPos(sunInitPos);
  for (int j = sun.hist_len-1; j >=0; j--) {
    sun.history.setVertex(j, sun.position);
  } 

  logList.clear();
  String logStr = "Simulation started";
  printLog(logStr);
}





// init sin/cos tables with values
// should be called from setup()

void initAcos() {
  println(AC_PERIOD);
  acosLUT = new float[AC_PERIOD];
  for (int i = 0; i < AC_PERIOD; i++) {
    double cosVal = (i*AC_PRECISION-1);
    acosLUT[i] = (float)Math.acos(cosVal);
  }
}

double  myAngleBtween(PVector v1, PVector v2) {

  // We get NaN if we pass in a zero vector which can cause problems
  // Zero seems like a reasonable angle between a (0,0,0) vector and something else
  if (v1.mag() == 0 || v2.mag() == 0) return 0.0f;


  // This should be a number between -1 and 1, since it's "normalized"
  double amt = v1.dot(v2) / (v1.mag() * v2.mag());

  // But if it's not due to rounding error, then we need to fix it
  // http://code.google.com/p/processing/issues/detail?id=340
  // Otherwise if outside the range, acos() will return NaN
  // http://www.cppreference.com/wiki/c/math/acos
  if (amt <= -1) {
    return PConstants.PI;
  } else if (amt >= 1) {
    // http://code.google.com/p/processing/issues/detail?id=435
    return 0;
  }

  if (lookUp) {
    int lutIndex = (int)(AC_PERIOD2*(amt+1));
    double acosL = acosLUT[lutIndex];

    return acosL;
  } else return Math.acos(amt);
}


void prepareCone() {

  float angle = 0;

  // fill arrays
  for (int i = 0; i < 2; i++) {
    angle = 0;
    for (int j = 0; j <= conePts; j++) {
      cone[i][j] = new PVector();
      if (i==1) {
        cone[i][j].x = 0;
        cone[i][j].y = 0;
      } else {
        cone[i][j].x = cos(radians(angle)) * coneRadius;
        cone[i][j].y = sin(radians(angle)) * coneRadius;
      }
      cone[i][j].z = coneLength; 
      // the .0 after the 360 is critical
      angle += 360.0/conePts;
    }
    coneLength *= -1;
  }
}
void drawCone() {
  // draw cylinder tube
  lights();
  fill(255, 200, 200);
  beginShape(QUAD_STRIP);
  for (int j = 0; j <= conePts; j++) {
    vertex(cone[0][j].x, cone[0][j].y, cone[0][j].z);
    vertex(cone[1][j].x, cone[1][j].y, cone[1][j].z);
  }
  endShape();

  //draw cylinder ends
  for (int i = 0; i < 2; i++) {
    beginShape();
    for (int j = 0; j < conePts; j++) {
      vertex(cone[i][j].x, cone[i][j].y, cone[i][j].z);
    }
    endShape(CLOSE);
  }
  noFill();
}

void keyPressed()
{
  if (key == 'i') drawIds = !drawIds;
  else if (key == 'l') {
    lookUp = !lookUp;
    println(lookUp);
  } else if (key == 'f') {
    followSun = !followSun;
    if (followSun) cp5.getController("followSun").setValue(1);
    else cp5.getController("followSun").setValue(0);
  } else if (key == 'h') {
    drawHistory = !drawHistory;
  } else if (key == 't') {
    bTail = !bTail;
  } else if (key == 's') {
    bSaveFrame = !bSaveFrame;
    String logStr;
    if (bSaveFrame) logStr = "start frame recording";
    else logStr = "stop frame recording";
    printLog(logStr);
  } else if (key == 'g') {
    bShowGUI = !bShowGUI;
  }
}

/**/
