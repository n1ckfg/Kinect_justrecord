AudioSnippet startRecSound, stopRecSound, pKeySound, sKeySound;

void setupSound(String _sf){
   
    startRecSound = minim.loadSnippet(_sf + "/" + "startRec.wav");
    stopRecSound = minim.loadSnippet(_sf + "/" + "stopRec.wav");
    pKeySound = minim.loadSnippet(_sf + "/" + "24th blip sync pop.wav");
    sKeySound = minim.loadSnippet(_sf + "/" + "24th blip sync pop.wav");

}


