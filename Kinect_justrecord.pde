//--Kinect sectup
import org.openkinect.*;
import org.openkinect.processing.*;
Kinect kinect;
boolean depth = true;
boolean rgb = false;
boolean ir = false;
boolean process = false;
float deg = 0;  // orig 15
int[] depthArray;
int pixelCounter = 1;
//--

int maxDepthValue = 1040 ;  // full range 0-2047, rec'd 530-1040
int minDepthValue = 530 ;  
int w = 640;
int h = 480;
int fps = 24;
int fontSize = 12;
boolean record = false;
PImage displayImg;
PFont font;
String sayText;
String fileType = "tga";
int counter = 1; 
int shot = 1;

//-----------------------------------------

void setup() {
  size(w,h);
  frameRate = fps;
  font = createFont("Arial",fontSize);
  textFont(font,fontSize);
  initKinect();
  displayImg = createImage(w,h,RGB);
  sayText="READY  " + "shot" + shot;
  println(sayText);
}

//---

void draw() {
  background(0);
  depthArray = kinect.getRawDepth();
  imageProcess();
  image(displayImg,4,0);
  if(record) {
    saveFrame("render/shot" + shot + "_" + counter + "." +fileType);
    sayText="REC  shot" + shot + "_" + counter + "." + fileType;
    println(sayText);
    counter++;
  }
  recDot();
}

//-----------------------------------------

void recDot() {
  fill(200);
  text(sayText,40,35);
  text(int(frameRate) + " fps", w-60,35);
  noFill();
  if(record&&(counter%2!=0)) {
    stroke(255,0,0);
  } 
  else {
    stroke(35,0,0);
  }
  strokeWeight(20);
  point(20,30);
  stroke(200);
  strokeWeight(1);
  rectMode(CORNER);
  rect(3,59,633,360);
  line((w/2)-10,(h/2),(w/2)+10,(h/2));
  line((w/2),(h/2)-10,(w/2),(h/2)+10);
}

//---

void keyPressed() {
  if(key==' ') {
    if (record) {
      record=false;
      shot++;
      sayText="READY  shot" + shot;
      println(sayText);
      counter=1;
    } 
    else {
      record=true;
    }
  }
}

//---

void imageProcess() {
  for(int i=0;i<depthArray.length;i++) {
    float q = map(depthArray[i],minDepthValue,maxDepthValue,255,0);
    depthArray[i] = color(q);
  }
  displayImg.pixels = depthArray;
  displayImg.updatePixels();
  //displayImg.filter(GRAY);
  //displayImg.filter(INVERT);
}

//---

void initKinect() {
  kinect = new Kinect(this);
  kinect.start();
  kinect.enableDepth(depth);
  kinect.enableRGB(rgb);
  kinect.enableIR(ir);
  kinect.processDepthImage(process);
  kinect.tilt(deg);
}

//---

void stop() {
  kinect.quit();
  super.stop();
}

//---   END   ---
