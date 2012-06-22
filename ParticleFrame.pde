class ParticleFrame {
  boolean firstRun = true;
  boolean isAlive = true;

  Particle[][] particle = new Particle[numColumns][numRows];

  PVector particleSize = new PVector(sW/numColumns, sH/numRows);
  PVector particleStart = new PVector(particleSize.x/2, particleSize.y/2);

  ParticleFrame() { 
    for (int y = 0; y<numRows; y++) {
      for (int x=0; x<numColumns; x++) {
        particlesInit(x, y);
      }
    }
  }

  void update() {
    for (int y = 0; y<numRows; y++) {
      for (int x=0; x<numColumns; x++) {
        isAlive=false;
        particle[x][y].run();
        if(particle[x][y].isAlive){
        isAlive=true;
        }
      }
    }
  }

  void particlesInit(int x, int y) {
    particle[x][y] = new Particle(particleStart.x, particleStart.y, particleSize.x, particleSize.y);
    if (particleStart.x<sW-particleSize.x) {
      particleStart.x += particleSize.x;
    } 
    else {
      particleStart.x = particleSize.x/2;
      particleStart.y += particleSize.y;
    }
    //~~~~~~~~~~~~~
  }

  void pixelTrack() {
    if (firstRun) {
      for (int y = 0; y<numRows; y++) {
        for (int x=0; x<numColumns; x++) {
          int loc = x + (y*numColumns);

          float r = red(scaleImg.pixels[loc]);
          float g = green(scaleImg.pixels[loc]);
          float b = blue(scaleImg.pixels[loc]);
          int target = int((r+g+b)/3);

          particle[x][y].init(target);
        }
      }
      if(persistence){
        firstRun=false;
      }
    }
  }
  
}

