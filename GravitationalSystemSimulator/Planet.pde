
float GRAVITY = 8; 
int const_Hlen = 100;

float minRandRad = 1000;
float minRandVel = 50; 
float minMass = 100;
float maxRandRad = 200000;
float maxRandVel = 100; 
float minRandMass = 150;
float maxRandMass = 1500;

float TRAYECTORY_ANGLE_RESOLUTION = radians(3.0);
float MIN_DIST_HIST = 2000;
float MAX_DIST_HIST = 1000000;

float RADIUS_FACTOR = 25.0/(4.0*PI);
float MIN_RADIUS = pow(minRandMass*RADIUS_FACTOR, 0.333333333);
float MAX_RADIUS = pow(maxRandMass*RADIUS_FACTOR, 0.333333333);

float visualScalePlanet = 1;
float visualScaleSun = 1;


class Planet {
  int id = 0;
  PVector position;
  PVector velocity;
  PVector prevVelocity;
  PVector prevAcceleration;
  PVector acceleration;
  float mass;
  float r;
  float diam;
  color col;
  PShape history;
  int histIndex;
  int hist_len;
  long iteration;  

  float prevVelocityMag = 0;
  float dist = 0;


  Planet(int index, float m, PVector p, PVector v) {
    id = index;
    hist_len=const_Hlen;
    histIndex = 0;
    setMass(m);
    if (position == null) position = new PVector(p.x, p.y, p.z);
    else position.set(p.x, p.y, p.z);
    if (velocity == null) velocity = new PVector(v.x, v.y, v.z);   // Arbitrary starting velocity
    else velocity.set(v.x, v.y, v.z); 
    prevVelocity= new PVector(v.x, v.y, v.z);
    prevVelocityMag = prevVelocity.mag();
    if (acceleration == null) acceleration = new PVector(0, 0, 0);
    else acceleration.set(0, 0, 0);
    if (prevAcceleration == null) prevAcceleration = new PVector(0, 0, 0);
    else prevAcceleration.set(0, 0, 0);
    history = createShape();
    history.beginShape();
    history.setFill(0);
    history.setStroke(255);
    for (int j = 0; j < hist_len; j++) {  
      history.vertex(position.x, position.y, position.z);
    }   
    history.endShape();
    history.disableStyle();
    dist = 0;
    iteration = 0;
  }

  void setMass(float m) {
    mass = m;
    r=pow((float)mass*RADIUS_FACTOR, 0.333333333);
    diam = 2*r;
    colorMode(HSB, 100, 100, 100);
    float colH = map(m, minRandMass, maxRandMass, 100, 20);
    if (colH > 100) colH = 100;
    else if (colH < 20) colH = 20;
    // println(colH);

    /* int rr = int(constrain(128+128*mass/20, 128, 255));
     int gg = int(constrain(128+128*mass/20, 128, 255));
     int bb = int(constrain(128+128*(1-mass/10), 128, 255));
     col = color(rr,gg,bb);*/
    col = color(colH, 50, 100);
    colorMode(RGB, 255, 255, 255);
  }

  void setPos(PVector newPos) {
    position.set(newPos);
    for (int j = hist_len-1; j >=0; j--) {
      history.setVertex(j, position);
    }
  }

  void randomize(PVector offset) {


    float randMass = random(minRandMass, maxRandMass);
    setMass(randMass);
    position.x = offset.x+random(-random(minRandRad, maxRandRad), random(minRandRad, maxRandRad));
    position.y = offset.y+random(-random(minRandRad, maxRandRad), random(minRandRad, maxRandRad));
    position.z = offset.z+random(-random(minRandRad, maxRandRad), random(minRandRad, maxRandRad));
    velocity.x = random(-random(minRandVel, maxRandVel), random(minRandVel, maxRandVel));
    velocity.y = random(-random(minRandVel, maxRandVel), random(minRandVel, maxRandVel));
    velocity.z = random(-random(minRandVel, maxRandVel), random(minRandVel, maxRandVel));
    prevVelocity.set(velocity);
    prevVelocityMag = prevVelocity.mag();
    for (int j = hist_len-1; j >=0; j--) {
      history.setVertex(j, position);
    }   
    iteration = 0;
    dist = 0;
  }

  void update(PVector origin) {

    if ( position.dist(origin) > MAX_DIST ) {
      String logStr = "Planet "+id+" reached end of range";

      printLog(logStr);  
      randomize(origin);
    } else {
      velocity.add(acceleration); // Velocity changes according to acceleration
      position.add(velocity);     // position changes according to velocity
      prevAcceleration.set(acceleration);
      prevAcceleration.setMag(visualScalePlanet*accelScale);
      acceleration.mult(0);

      if  ( ( dist > MAX_DIST_HIST) || ( !velocity.equals(prevVelocity)  && ( dist > MIN_DIST_HIST) &&
        (myAngleBtween(prevVelocity, velocity) >= TRAYECTORY_ANGLE_RESOLUTION)
        ))
      {
        histIndex++;
        if (histIndex > hist_len-1) histIndex = 0;
        history.setVertex(histIndex, position);
        prevVelocity.set(velocity);
        prevVelocityMag = prevVelocity.mag();
        iteration = 0;
        dist = 0;
      } 
      iteration++;
      dist += prevVelocityMag;
    }
  }

  void attract(Planet m) {
    PVector direction = PVector.sub(m.position, position);    // Calculate direction of force
    float d = direction.mag();                               // Distance between objects

    if (d <= (m.diam+diam)) { // collision
      String logStr = "Collision between #"+id+" and #"+m.id+", new mass for #";
      setMass(mass+m.mass);
      logStr+=id+": "+mass;            
      velocity.div(m.velocity.mag());
      if (followSun) m.randomize(planets.get(0).position);
      else m.randomize(new PVector(0, 0, 0));

      printLog(logStr);
    } else {
      // Get force vector --> magnitude * direction
      double dd = d*d;
      PVector force1 = new PVector();
      force1.set(direction);
      force1.setMag((float)(m.mass*GRAVITY/dd));   
      PVector force2 = new PVector();
      force2.set(direction);
      force2.setMag((float)(-mass*GRAVITY/dd));   
      acceleration.add(force1); 
      m.acceleration.add(force2);
    }
  }

  // Draw the Planet
  void display() {
    hint(DISABLE_DEPTH_TEST);
    strokeWeight(3);
    curveTightness(0.0);
    noFill();
    if (accelScale> 0) {
      stroke(255, 255, 0, 50);
      pushMatrix();
      translate(position.x+prevAcceleration.x, position.y+prevAcceleration.y, position.z+prevAcceleration.z);
      line(0, 0, 0, -prevAcceleration.x, -prevAcceleration.y, -prevAcceleration.z); 

      noStroke();
      //   scale(1,1,-1);
      //   drawCone();
      popMatrix();
    }
    if (drawHistory) {
      beginShape();
      stroke(col);
      vertex(position.x, position.y, position.z);
      int hind = histIndex;
      PVector currPt;
      for (int j = 0; j < hist_len; j++) {
        float alpha = float(hist_len-j)/float(hist_len);
        alpha = pow(alpha, 55);
        if (bTail) {
          float fadeStart = 0.15;
          if (alpha <= fadeStart) {
            alpha = map(pow(alpha, 0.025), 0, pow(fadeStart, 0.025), 0, fadeStart);
          }
        }
        stroke(col, 255*alpha);
        currPt = history.getVertex(hind); 
        //curveV
        vertex(currPt.x, currPt.y, currPt.z);
        hind--;
        if (hind < 0) hind = hist_len-1;
      }
      endShape();
    }
    hint(ENABLE_DEPTH_TEST);

    noStroke();
    fill(col);


    pushMatrix();
    translate(position.x, position.y, position.z);
    lights();
    if (id == 0) sphere(visualScaleSun*r);
    else sphere(visualScalePlanet*r);
    noLights();
    popMatrix();

    pushMatrix();   

    PVector pos = new PVector( modelX(position.x, position.y, position.z), 
      modelY(position.x, position.y, position.z), 
      modelZ(position.x, position.y, position.z)
      );
    if (followSun) translate( planets.get(0).position.x, 
      planets.get(0).position.y, 
      planets.get(0).position.z); 
    float sX = screenX(pos.x, pos.y, pos.z)-w2;//Spos.x;
    float sY = screenY(pos.x, pos.y, pos.z)-h2;//Spos.y;

    cam.beginHUD();     
    hint(DISABLE_DEPTH_TEST);
    ortho();
    strokeWeight(1);
    stroke(col);
    if (drawIds) {
      text(id, sX+3, sY-3);
      line(sX-10, sY, sX-5, sY);
      line(sX+5, sY, sX+10, sY);
      line(sX, sY-10, sX, sY-5);
      line(sX, sY+5, sX, sY+10);
    }
    if ((abs(sX-mouseX+w2) < 20) && (abs(sY-mouseY+h2) < 20) ) {
      noFill();
      ellipse(sX, sY, 20, 20);
      text("#"+id+" "+nf(velocity.mag(), 3, 2), sX+3, sY+15);
    }
    hint(ENABLE_DEPTH_TEST);
    cam.endHUD();
    popMatrix();
  }
}
