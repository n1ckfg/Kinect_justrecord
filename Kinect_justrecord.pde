import SimpleOpenNI.*;
import ddf.minim.*;
import processing.opengl.*;
import proxml.*;

//**************************************
//int maxDepthValue = 1040;  // full range 0-2047, rec'd 530-1040
//int minDepthValue = 530;  
int sW = 640;
int sH = 480;
int fps = 30;

color bgColor = color(0);

String fileType = "tga";  //tif, tga, jpg, png; use tga for best speed
String audioFileType = "wav";
String fileName = "shot";
String filePath = "data";
String folderIndicator = "_folder";
//**************************************

//sound
Minim minim;
AudioInput in;
AudioRecorder fout;

//--Kinect sectup
SimpleOpenNI context;
boolean mirror = true;
boolean depthSwitch = true;
boolean rgbSwitch = false;
boolean firstRun = true;
//--

int fontSize = 12;
boolean modeRec = false;
//boolean needsSaving = false;
PFont font;
int counter = 1; 
int shot = 1;
int timestamp;
int timestampInterval = 1000;
String sayText;


XMLInOut xmlIO;
proxml.XMLElement xmlFile;
String xmlFileName;
boolean loaded = false;

//-----------------------------------------

void setup() {
  size(sW, sH, P2D);
  frameRate(fps);
  setupRecord();
  setupGrid();
  setupSound("sounds");
}

//---

void draw() {
  background(bgColor);
  context.update();
  drawGrid(context.depthImage());
  if (modeRec) {
    drawRecord();
  }
  else {
    if (fout.isRecording()) {
      fout.endRecord();
      fout.save();
      initAudioFout();
    }
  }
  recDot();
}

void xmlEvent(proxml.XMLElement element) {
  //this function is ccalled by default when an XML object is loaded
  xmlFile = element;
  //parseXML(); //appelle la fonction qui analyse le fichier XML
  loaded = true;
}

//-----------------------------------------
void setupRecord() {
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 512);
  initAudioFout();
  font = createFont("Arial", fontSize);
  textFont(font, fontSize);
  initKinect();
  sayText="READY  " + fileName + shot;
  println(sayText);
}

//---

void drawRecord() {
  if (modeRec) {
    if (!fout.isRecording()) {
      xmlInit();
      fout.beginRecord();
    }
    timestamp=millis();
    sayText = fileName + shot + "_frame" + counter + "." + fileType;
    saveFrame(filePath + "/" + fileName + shot + folderIndicator + "/" + sayText);
    xmlAdd();
    sayText="REC " + sayText;
    println(sayText);
    counter++;
  }
}

void recDot() {
  fill(200);
  text(sayText, 40, 35);
  text(int(frameRate) + " fps", sW-60, 35);
  noFill();
  if (modeRec&&(counter%2!=0)) {
    stroke(255, 0, 0);
  } 
  else {
    stroke(35, 0, 0);
  }
  strokeWeight(20);
  point(20, 30);
  stroke(200);
  strokeWeight(1);
  rectMode(CORNER);
  rect(3, 59, 633, 360);
  line((sW/2)-10, (sH/2), (sW/2)+10, (sH/2));
  line((sW/2), (sH/2)-10, (sW/2), (sH/2)+10);
}

//---
void doSaveWrapup() {
  if (fout.isRecording()) {
    fout.endRecord();
    fout.save();
    initAudioFout();
  }
  println("saved " + fileName+shot+"."+audioFileType);
  xmlSaveToDisk();
  println("saved " + "timestamps_" + fileName + shot + ".xml");
  shot++;
  sayText="READY  shot" + shot;
  println(sayText);
  counter=1;
}

//---

void initKinect() {
  context = new SimpleOpenNI(this,SimpleOpenNI.RUN_MODE_MULTI_THREADED);
  context.setMirror(mirror);
  if (depthSwitch) {
    context.enableDepth();
  }
  if (rgbSwitch) {
    context.enableRGB();
  }
}

//---

void initAudioFout() {
  fout = minim.createRecorder(in, filePath + "/" + fileName + shot + "." + audioFileType, true);
}

//---

void stop() {
  in.close();
  minim.stop();
  //kinect.quit();
  super.stop();
  exit();
}

/* saves the XML list to disk */
void xmlSaveToDisk() {
  xmlIO.saveElement(xmlFile, xmlFileName);
}  

void xmlAdd() {
  proxml.XMLElement frame = new proxml.XMLElement("frame");
  xmlFile.addChild(frame);
  frame.addAttribute("index", counter);
  frame.addAttribute("timestamp", timestamp);
}

void xmlInit() {
  xmlIO = new XMLInOut(this);
  xmlFileName = fileName + shot + ".xml";
  xmlFile = new proxml.XMLElement("timestamps");
  xmlFile.addAttribute("shot", shot);
}

//---   END   ---

