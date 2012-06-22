class Particle {
  
  PVector p, s, q;
  float spread = 4;
  int alphaNumOrig = 20;
  int alphaNum = alphaNumOrig;
  int alphaDelta = 2;
  boolean isAlive = true;

  Particle(float _px, float _py, float _sx, float _sy) {
    p = new PVector(_px, _py);
    s = new PVector(_sx, _sy);
  }

  void init(float _r) {
    q = new PVector(s.x*(_r/masterSize), s.y*(_r/masterSize));
  }

  void run() {
    update();
    render(q.x, q.y);
  }

  void update() {
    p.x += random(spread) - random(spread);
    p.y += random(spread) - random(spread);
    if(persistence) p.y -= spread;
  }

  void render(float _qx, float _qy) {
    noStroke();
    fill(255, alphaNum);
    
    if (persistence) {
      alphaNum-=alphaDelta;
      if (alphaNum<0) {
        alphaNum=0;
        isAlive=false;
      }
    }
    
    ellipseMode(CENTER);
    ellipse(p.x, p.y, _qx, _qy);
  }
}

