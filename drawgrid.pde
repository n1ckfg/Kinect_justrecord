//particles persist after they are generated
//instead of being cleared each frame
boolean persistence = false;

int masterSize = 70;

int numColumns = 64;
int numRows = 36;

PImage mapImg;
PImage scaleImg;
boolean showImg = true;

ArrayList particleFrame;

void setupGrid() {
  scaleImg = createImage(numColumns, numRows, RGB);
  particleFrame = new ArrayList();
  if(!persistence){
    particleFrame.add(new ParticleFrame());
  }
}

void drawGrid(PImage _img) {
    mapImg = _img;

    mainRender();

}

void mainRender() {
  //~~~~~~~~~~~~~~~~
  image(mapImg, 0, 0, numColumns, numRows);

  scaleImg = get(0, 0, numColumns, numRows);
  background(bgColor);

  //main
  if (!showImg) {
    //~~~~~~~~~~~~~~~
    if (persistence) {
      particleFrame.add(new ParticleFrame());
      for (int i=0;i<particleFrame.size();i++) {
        ParticleFrame temp = (ParticleFrame) particleFrame.get(i);
        if(temp.isAlive){
        if (temp.firstRun) {
          temp.pixelTrack();
          firstRun=false;
        }else{
          temp.update();
        }
        }else{
        particleFrame.remove(i);
        }
      }
    }
    else {
      ParticleFrame temp = (ParticleFrame) particleFrame.get(0);
      temp.pixelTrack();
      temp.update();
    }
    //~~~~~~~~~~~~~~~~
  }
  else {
    image(mapImg, 0, 0, sW, sH);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~
}


