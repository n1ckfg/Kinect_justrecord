void keyPressed() {
  if (key==' '||keyCode==33||keyCode==34) {
    if (modeRec) {
      modeRec=false;
      doSaveWrapup();
      stopRecSound.play(0);
    } else {
      modeRec=true;
      startRecSound.play(0);
    }
  }
   if (key=='s'||key=='S') {
    showImg = !showImg;
    
    sKeySound.play(0);
  }
     if (key=='p'||key=='P') {
    persistence = !persistence;
    if(persistence) showImg=false;
    setupGrid();
    pKeySound.play(0);
  }
}
