import SimpleOpenNI.*;
import ddf.minim.*;

int sW = 640;
int sH = 480;
int fps = 24;

color bgColor = color(0);

String fileType = "tga";  //tif, tga, jpg, png; use tga for best speed
String audioFileType = "wav";
String fileName = "shot";
String filePath = "data";
String folderIndicator = "_folder";
//**************************************
boolean mirror = true;
boolean recordToBuffer = false;
float bufferTimeInSec = 30;
boolean rawDepth = false;
boolean remapRawDepth = false;
int rawDepthMaxValue = 1040;  // full range 2047, default 1040
int rawDepthMinValue = 530;  //  full range 0, default 530
//**************************************
//sound
Minim minim;
AudioInput in;
AudioRecorder fout;

//--Kinect secup
SimpleOpenNI context;
boolean depthSwitch = true;
boolean rgbSwitch = false;
boolean firstRun = true;
int[] depthArray = new int[sW*sH];
PImage arrayToImg = createImage(sW,sH,RGB);

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

// Disk recording on a C2D or better will be fine (especially with an SSD),
// but low-powered machines like netbooks will probably need to use the RAM buffer.
//--
// The buffer will increase your speed on slower machines, but record time depends on available RAM.
// Use bufferTimeInSec to reduce the buffer size if you're getting "out of memory" errors.
// 30 sec. of recording time per 1GB RAM allocated to Processing is a good rule of thumb.
int bufferCounterMin = counter;
int bufferCounter = bufferCounterMin;
int bufferCounterMax = int(bufferTimeInSec * fps);
PImage[] frameBuffer;
boolean savingFromBuffer=false;
//--

XMLInOut xmlIO;
XMLElement xmlFile;
String xmlFileName;
boolean loaded = false;

//-----------------------------------------

void setup() {
  size(50, 50, P2D);
  surface.setSize(sW, sH);
  frameRate(fps);
  initBuffer();
  setupRecord();
  setupGrid();
  setupSound("sounds");
}

//---

void draw() {
  background(bgColor);
  context.update();
  //~~~~~~~~~~~~~~~~~~~~
  if(rawDepth){
  depthArray = context.depthMap();
  imageProcess(rawDepthMinValue, rawDepthMaxValue, remapRawDepth);
  arrayToImg.pixels = depthArray;
  drawGrid(arrayToImg);
  }else{
  drawGrid(context.depthImage());
  }
  //~~~~~~~~~~~~~~~~~~~~
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

void xmlEvent(XMLElement element) {
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
    actuallyRecord();
    xmlAdd();
    counter++;
  }
}

void actuallyRecord(){
  sayText = "BUFFERING  " + fileName + shot + "_frame" + bufferCounter;
if(recordToBuffer){
  if(bufferCounter<bufferCounterMax){
    PImage temp = get();
    frameBuffer[bufferCounter] = temp;
    println("buffering: " + bufferCounter);
    bufferCounter++;
  }else{
    stopAll();
  }
}else{
  saveFrameHandler(counter);
}
}

void saveFrameHandler(int _c){
    if(recordToBuffer){
      sayText = fileName + shot + "_frame" + (_c + 1) + "." + fileType;
      PImage tempImg = frameBuffer[_c];
      image(tempImg,0,0);
    } else {
      sayText = fileName + shot + "_frame" + _c + "." + fileType;
    }
    saveFrame(filePath + "/" + fileName + shot + folderIndicator + "/" + sayText);
    sayText = "REC  " + sayText;
    println(sayText);
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
  //--
  if(modeRec&&recordToBuffer){
      strokeWeight(2);
      stroke(255,0,0);
      float q = 10 + (float(sW-20) * (float(bufferCounter)/float(bufferCounterMax)));
      line(10,10,q,10);
    }
  //--
  if(savingFromBuffer){
  noStroke();
  fill(255,0,0,100);
  rect(0,0,sW,sH);
  }
}

//---
void doSaveWrapup() {
  if(recordToBuffer){
    savingFromBuffer=true;
    for(int i=0;i<bufferCounter;i++){
      saveFrameHandler(i);
    }
    bufferCounter=bufferCounterMin;
    savingFromBuffer=false;
  }
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

void initBuffer(){
  if(recordToBuffer){
    frameBuffer = new PImage[bufferCounterMax];
    for(int i=0;i<frameBuffer.length;i++){
      frameBuffer[i] = createImage(sW,sH,GRAY);
      //frameBuffer[i].filter(GRAY);
    }
  }
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
  XMLElement frame = new XMLElement("frame");
  xmlFile.addChild(frame);
  frame.addAttribute("index", counter);
  frame.addAttribute("timestamp", timestamp);
}

void xmlInit() {
  xmlIO = new XMLInOut(this);
  xmlFileName = fileName + shot + ".xml";
  xmlFile = new XMLElement("timestamps");
  xmlFile.addAttribute("shot", shot);
}

void imageProcess(int _min, int _max, boolean _b) {
  if(_b){
  for(int i=0;i<depthArray.length;i++) {
    int q = int(map(depthArray[i],_min,_max,255,0));
    depthArray[i] = color(q);
  }
  }
}
//---   END   ---