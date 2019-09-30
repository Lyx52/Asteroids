class bullet {
  PVector bulpos;
  float ang = 0;
  float acc = 0.3;
  boolean remove = false,
          r = false;
  bullet(float a) {
    bulpos = new PVector(p.pos.x + p.vx, p.pos.y + p.vy);
    ang = a;
    acc *= ts;
  }
  void update() {
    if (dist(p.pos.x, p.pos.y, bulpos.x,bulpos.y) >= playerSize / 2) {
      display();
    }
    bulpos.x += (cos(ang) * acc) * deltaTime;  
    bulpos.y += (sin(ang) * acc) * deltaTime; 
    remove = bulpos.x < 0 || bulpos.x > width || bulpos.y < 0 || bulpos.y > height;
  }
  void display() {
    pushMatrix();
      fill(255,0,0);
      translate(bulpos.x, bulpos.y);
      rotate(ang);
      ellipse(0,0,bulletSize,bulletSize);
    popMatrix();
  }
}
