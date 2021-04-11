import java.util.ArrayList;
import java.util.Collections;

//these are variables you should probably leave alone
int index = 0; //starts at zero-ith trial
float border = 0; //some padding from the sides of window
int trialCount = 12; //this will be set higher for the bakeoff
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 0.5f; //for every error, add this value to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false; //is the user done

final int screenPPI = 72; //what is the DPI of the screen you are using
//you can test this by drawing a 72x72 pixel rectangle in code, and then confirming with a ruler it is 1x1 inch. 

//These variables are for my example design. Your input code should modify/replace these!
float logoX = 0;
float logoY = 0;
float logoZ = 50f;
float logoRotation = 0;

private class Destination
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

//caseyCode
PImage ccwbImg;
PImage ccwImg;
PImage cwImg;
PImage cwbImg;

ArrayList<Destination> destinations = new ArrayList<Destination>();

void setup() {
  size(1000, 800);  
  rectMode(CENTER);
  textFont(createFont("Arial", inchToPix(.3f))); //sets the font to Arial that is 0.3" tall
  textAlign(CENTER);

  //caseyCode
  frameRate(30);
  ccwbImg = loadImage("CCWB.png");
  ccwImg  = loadImage("CCW.png");
  cwImg   = loadImage("CW.png");
  cwbImg  = loadImage("CWB.png");

  //don't change this! 
  border = inchToPix(2f); //padding of 1.0 inches

  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Destination d = new Destination();
    d.x = random(-width/2+border, width/2-border); //set a random x with some padding
    d.y = random(-height/2+border, height/2-border); //set a random y with some padding
    d.rotation = random(0, 360); //random rotation between 0 and 360
    int j = (int)random(20);
    d.z = ((j%12)+1)*inchToPix(.25f); //increasing size from .25 up to 3.0" 
    destinations.add(d);
    println("created target with " + d.x + "," + d.y + "," + d.rotation + "," + d.z);
  }

  Collections.shuffle(destinations); // randomize the order of the button; don't change this.
}



void draw() {

  background(40); //background is dark grey
  fill(200);
  noStroke();

  //shouldn't really modify this printout code unless there is a really good reason to
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchToPix(.4f));
    text("User had " + errorCount + " error(s)", width/2, inchToPix(.4f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per destination", width/2, inchToPix(.4f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per destination inc. penalty", width/2, inchToPix(.4f)*4);
    return;
  }

  //===========DRAW DESTINATION SQUARES=================
  for (int i=trialIndex; i<trialCount; i++) // reduces over time
  {
    pushMatrix();
    translate(width/2, height/2); //center the drawing coordinates to the center of the screen
    Destination d = destinations.get(i);
    translate(d.x, d.y); //center the drawing coordinates to the center of the screen
    rotate(radians(d.rotation));
    noFill();
    strokeWeight(3f);
    if (trialIndex==i)
      stroke(255, 0, 0, 192); //set color to semi translucent
    else
      stroke(128, 128, 128, 128); //set color to semi translucent
    rect(0, 0, d.z, d.z);
    popMatrix();
  }

  //===========DRAW LOGO SQUARE=================
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen
  translate(logoX, logoY);
  rotate(radians(logoRotation));
  noStroke();
  fill(60, 60, 192, 192);
  rect(0, 0, logoZ, logoZ);
  popMatrix();

  //===========DRAW EXAMPLE CONTROLS=================
  controlBox();
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchToPix(.8f));
}

//caseyCode
//draws control box in bottom right corner with stats and controls
//this is over 300 lines long. Only open this if you need to :)
void controlBox()
{
  Destination d = destinations.get(trialIndex);

  float controlW = 7*width/16;
  float controlH = height/3;
  float controlX = width - controlW/2;
  float controlY = height - controlH/2;

  //TODO Fix box not actually moving?
  //if the destination is behind the panel, move panel to the bottom left instead
  if (d.x > (controlX - controlW) && d.y > (controlY - controlH))
  {
    controlX = controlW/2;
  }

  //submit box
  if (checkForSuccess())
  {
    fill(0, 215, 0, 90);
  }
  else
  {
    fill(255, 255, 255, 90);
  }
  rect(width/2, 5*height/6 + 1, controlW/4, height/3);
  fill(0);
  text("Submit", width/2, 5*height/6 + 1);

  //box bg
  fill(255, 255, 255, 90);
  rect(controlX, controlY, controlW, controlH);
  //control div lines
  stroke(0);
  strokeWeight(1);
  line(controlX - controlW/4, controlY - controlH/2, controlX - controlW/4, controlY + controlH/2); //left line
  line(controlX, controlY - controlH/2, controlX, controlY + controlH/2);                           //center line
  line(controlX + controlW/4, controlY - controlH/2, controlX + controlW/4, controlY + controlH/2); //right line

  //control labels
  fill(255);
  text("X", controlX - 3*controlW/8, controlY - 17*controlH/32);
  text("Y", controlX - controlW/8, controlY - 17*controlH/32);
  text("R", controlX + controlW/8, controlY - 17*controlH/32);
  text("Z", controlX + 3*controlW/8, controlY - 17*controlH/32);

  //control stats
  float xDiff = pixToInch(dist(d.x, 0, logoX, 0));
  float yDiff = pixToInch(dist(0, d.y, 0, logoY));
  double rDiff = calculateDifferenceBetweenAngles(d.rotation, logoRotation);
  float zDiff = abs(d.z - logoZ);
  {
    if (xDiff < 0.05f)
    {
      fill(0, 127, 0);
    }
    else
    {
      fill(0);
    }
    text(Float.toString(xDiff).substring(0, 5), controlX - 3*controlW/8, controlY); //X diff

    if (yDiff < 0.05f)
    {
      fill(0, 127, 0);
    }
    else
    {
      fill(0);
    }
    text(Float.toString(yDiff).substring(0, 5), controlX - controlW/8, controlY); //Y diff

    if (rDiff <= 5)
    {
      fill(0, 127, 0);
    }
    else
    {
      fill(0);
    }
    text(Double.toString(rDiff).substring(0, 5), controlX + controlW/8, controlY);  //R diff

    //if z close enough, green. else black.
    if (zDiff < inchToPix(0.05f))
    {
      fill(0, 127, 0);
    }
    else
    {
      fill(0);
    }
    if (Float.toString(zDiff).length() > 5)
    {
      text(Float.toString(zDiff).substring(0, 5), controlX + 3*controlW/8, controlY);  //Z diff
    }
    else
    {
      text(Float.toString(zDiff), controlX + 3*controlW/8, controlY);
    }
  }

  fill(0);
  //draws the control glyphs. its very ugly please dont look if you dont need to :)
  {
    //superLeft
    pushMatrix(); //I have no idea what this does, but I need it to rotate text
    translate(controlX - 25*controlW/64, controlY - 13*controlH/32);
    rotate(radians(270));
    text("▲", 0, 0);
    popMatrix();
    pushMatrix(); //I have no idea what this does, but I need it to rotate text
    translate(controlX - 23*controlW/64, controlY - 13*controlH/32);
    rotate(radians(270));
    text("▲", 0, 0);
    popMatrix();
    //left
    pushMatrix(); //I have no idea what this does, but I need it to rotate text
    translate(controlX - 3*controlW/8, controlY - 7*controlH/32);
    rotate(radians(270));
    text("▲", 0, 0);
    popMatrix();
    //right
    pushMatrix(); //I have no idea what this does, but I need it to rotate text
    translate(controlX - 3*controlW/8, controlY + 5*controlH/32);
    rotate(radians(270));
    text("▼", 0, 0);
    popMatrix();
    //superRight
    pushMatrix(); //I have no idea what this does, but I need it to rotate text
    translate(controlX - 25*controlW/64, controlY + 11*controlH/32);
    rotate(radians(270));
    text("▼", 0, 0);
    popMatrix();
    pushMatrix(); //I have no idea what this does, but I need it to rotate text
    translate(controlX - 23*controlW/64, controlY + 11*controlH/32);
    rotate(radians(270));
    text("▼", 0, 0);
    popMatrix();
  
    //superUp
    text("▲▲", controlX - controlW/8, controlY - 3*controlH/8);
    //up
    text("▲", controlX - controlW/8, controlY - 3*controlH/16);
    //down
    text("▼", controlX - controlW/8, controlY + 3*controlH/16);
    //superDown
    text("▼▼", controlX - controlW/8, controlY + 3*controlH/8);

    //superCW
    image(cwbImg, controlX + controlW/8 - cwbImg.width/2, controlY - 3*controlH/8 - 7*cwbImg.height/8);
    //CW
    image(cwImg, controlX + controlW/8 - cwbImg.width/2, controlY - controlH/8 - 3*cwbImg.height/2);
    //CCW
    image(ccwImg, controlX + controlW/8 - cwbImg.width/2, controlY + controlH/8 - 4);
    //superCCW
    image(ccwbImg, controlX + controlW/8 - cwbImg.width/2, controlY + 3*controlH/8 - 7*cwbImg.height/8);

    //superBig
    text("++", controlX + 3*controlW/8, controlY - 3*controlH/8);
    //big
    text("+", controlX + 3*controlW/8, controlY - 3*controlH/16);
    //small
    text("-", controlX + 3*controlW/8, controlY + 3*controlH/16);
    //superSmall
    text("--", controlX + 3*controlW/8, controlY + 3*controlH/8);
  }

  //control logic
  {
    //superLeft
    if (dist(mouseX, mouseY, controlX - 25*controlW/64, controlY - 13*controlH/32) < inchToPix(0.25f))
    {
      cursor(HAND);
      if(mousePressed)
      {
        logoX -= inchToPix(0.2f);
      }
    }
    //left
    else if (dist(mouseX, mouseY, controlX - 3*controlW/8, controlY - 7*controlH/32) < inchToPix(0.25f))
    {
      cursor(HAND);
      if(mousePressed)
      {
        logoX -= inchToPix(0.02f);
      }
    }
    //right
    else if (dist(mouseX, mouseY, controlX - 3*controlW/8, controlY + 5*controlH/32) < inchToPix(0.25f))
    {
      cursor(HAND);
      if(mousePressed)
      {
        logoX += inchToPix(0.02f);
      }
    }
    //superRight
    else if (dist(mouseX, mouseY, controlX - 25*controlW/64, controlY + 11*controlH/32) < inchToPix(0.25f))
    {
      cursor(HAND);
      if(mousePressed)
      {
        logoX += inchToPix(0.2f);
      }
    }
    //superUp
    else if (dist(mouseX, mouseY, controlX - controlW/8, controlY - 13*controlH/32) < inchToPix(0.25f))
    {
      cursor(HAND);
      if(mousePressed)
      {
        logoY -= inchToPix(0.2f);
      }
    }
    //up
    else if (dist(mouseX, mouseY, controlX - controlW/8, controlY - 7*controlH/32) < inchToPix(0.25f))
    {
      cursor(HAND);
      if(mousePressed)
      {
        logoY -= inchToPix(0.02f);
      }
    }
    //down
    else if (dist(mouseX, mouseY, controlX - controlW/8, controlY + 5*controlH/32) < inchToPix(0.25f))
    {
      cursor(HAND);
      if(mousePressed)
      {
        logoY += inchToPix(0.02f);
      }
    }
    //superDown
    else if (dist(mouseX, mouseY, controlX - controlW/8, controlY + 11*controlH/32) < inchToPix(0.25f))
    {
      cursor(HAND);
      if(mousePressed)
      {
        logoY += inchToPix(0.2f);
      }
    }
    //superCW
    else if (dist(mouseX, mouseY, controlX + controlW/8, controlY - 13*controlH/32) < inchToPix(0.25f))
    {
      cursor(HAND);
      if(mousePressed)
      {
        logoRotation += 3;
      }
    }
    //CW
    else if (dist(mouseX, mouseY, controlX + controlW/8, controlY - 7*controlH/32) < inchToPix(0.25f))
    {
      cursor(HAND);
      if(mousePressed)
      {
        logoRotation += 1;
      }
    }
    //CCW
    else if (dist(mouseX, mouseY, controlX + controlW/8, controlY + 5*controlH/32) < inchToPix(0.25f))
    {
      cursor(HAND);
      if(mousePressed)
      {
        logoRotation -= 1;
      }
    }
    //superCCW
    else if (dist(mouseX, mouseY, controlX + controlW/8, controlY + 11*controlH/32) < inchToPix(0.25f))
    {
      cursor(HAND);
      if(mousePressed)
      {
        logoRotation -= 3;
      }
    }
    //superBig
    else if (dist(mouseX, mouseY, controlX + 3*controlW/8, controlY - 13*controlH/32) < inchToPix(0.25f))
    {
      cursor(HAND);
      if(mousePressed)
      {
        logoZ = constrain(logoZ+inchToPix(.06f), .01, inchToPix(4f)); //leave min and max alone!;
      }
    }
    //big
    else if (dist(mouseX, mouseY, controlX + 3*controlW/8, controlY - 7*controlH/32) < inchToPix(0.25f))
    {
      cursor(HAND);
      if(mousePressed)
      {
        logoZ = constrain(logoZ+inchToPix(.02f), .01, inchToPix(4f)); //leave min and max alone!;
      }
    }
    //small
    else if (dist(mouseX, mouseY, controlX + 3*controlW/8, controlY + 5*controlH/32) < inchToPix(0.25f))
    {
      cursor(HAND);
      if(mousePressed)
      {
        logoZ = constrain(logoZ-inchToPix(.02f), .01, inchToPix(4f)); //leave min and max alone!;
      }
    }
    //superSmall
    else if (dist(mouseX, mouseY, controlX + 3*controlW/8, controlY + 11*controlH/32) < inchToPix(0.25f))
    {
      cursor(HAND);
      if(mousePressed)
      {
        logoZ = constrain(logoZ-inchToPix(.06f), .01, inchToPix(4f)); //leave min and max alone!;
      }
    }
    //submitBtn
    else if(width/2 - controlW/8 <= mouseX && mouseX < width/2 + controlW/8 && height - controlH <= mouseY)
    {
      cursor(HAND);
    }
    else
    {
      cursor(ARROW);
    }
  }
}


void mousePressed()
{
  if (startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
  }
}


void mouseReleased()
{

  //caseyCode
  //check to see if user clicked within submit box
  if (width/2 - 7*width/16/8 <= mouseX && mouseX < width/2 + 7*width/16/8 && height - height/3 + 1 <= mouseY)
  {
    //moved from checkForSuccess() to not spam logs  
    Destination d = destinations.get(trialIndex);  
    boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
    boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, logoRotation)<=5;
    boolean closeZ = abs(d.z - logoZ)<inchToPix(.05f); //has to be within +-0.05"  

    println("Close Enough Distance: " + closeDist + " (logo X/Y = " + d.x + "/" + d.y + ", destination X/Y = " + logoX + "/" + logoY +")");
    println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(d.rotation, logoRotation)+")");
    println("Close Enough Z: " +  closeZ + " (logo Z = " + d.z + ", destination Z = " + logoZ +")");
    println("Close enough all: " + (closeDist && closeRotation && closeZ));

    
    if (userDone==false && !checkForSuccess())
      errorCount++;

    trialIndex++; //and move on to next trial

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
  }
}

//caseyCode
//allows for quick resetting after testing. QOL only
void keyPressed()
{
  // restart if user is done and presses "r"
  if (userDone && key == 'r')
  {
    //these are variables you should probably leave alone
    index = 0; //starts at zero-ith trial
    border = 0; //some padding from the sides of window
    trialCount = 12; //this will be set higher for the bakeoff
    trialIndex = 0; //what trial are we on
    errorCount = 0;  //used to keep track of errors
    errorPenalty = 0.5f; //for every error, add this value to mean time
    startTime = 0; // time starts when the first click is captured
    finishTime = 0; //records the time of the final click
    userDone = false; //is the user done
    

    logoX = 0;
    logoY = 0;
    logoZ = 50f;
    logoRotation = 0;

    setup();
  }
}

//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
  Destination d = destinations.get(trialIndex);  
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, logoRotation)<=5;
  boolean closeZ = abs(d.z - logoZ)<inchToPix(.05f); //has to be within +-0.05"  

  return closeDist && closeRotation && closeZ;
}

//utility function I include to calc diference between two angles
double calculateDifferenceBetweenAngles(float a1, float a2)
{
  double diff=abs(a1-a2);
  diff%=90;
  if (diff>45)
    return 90-diff;
  else
    return diff;
}

//utility function to convert inches into pixels based on screen PPI
float inchToPix(float inch)
{
  return inch*screenPPI;
}

//caseyCode
//utility function to convert pixels back into inches based on screen PPI
float pixToInch(float pix)
{
  return pix/screenPPI;
}
