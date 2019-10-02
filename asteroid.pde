class asteroid {
  PVector pos;
  PVector[] points = new PVector[6];
  float acc = 0.05,
        HP = 100,
        ang = 0,
        rotSpeed = 0.05,
        rad = 0;
  boolean remove = false;
  asteroid(float xpos, float ypos, float angle, float s) {
    pos = new PVector(xpos, ypos);
    acc *= ts;
    acc += random(-0.01f,0.02f);
    ang = angle;
    rotSpeed = random(0.005,0.015);
    rad = s;
    makeAsteroid();
  }
  void makeAsteroid() {
    for (int i = 0; i < 6; i++) {
      if (i == 6) {
        points[i] = points[0];     
      } else {
        points[i] = new PVector(sin(i) * (rad / random(1,2)), cos(i) * (rad / random(1,2))); 
      }
    }
  }
  void update() {
    display();
    remove = (pos.x <= -rad * 2) || (pos.x >= width + rad * 2) || (pos.y <= -rad * 2) || (pos.y >= height + rad * 2);  
    pos.x += (acc * cos(ang)) * deltaTime;
    pos.y += (acc * sin(ang)) * deltaTime;
    if (dist(pos.x, pos.y, p.pos.x, p.pos.y) <= (rad / 2) + (playerSize / 2)) {
      p.HP -= p.staticDamage;
      remove = true;
    } else if (p.bul.size() > 0) {
      for (int b = 0; b < p.bul.size(); b++) {
        if (dist(p.bul.get(b).bulpos.x, p.bul.get(b).bulpos.y, pos.x, pos.y) <= (bulletSize / 2 + rad / 2)) {
          p.bul.get(b).remove = true;
          HP -= p.staticDamage + random(p.maxCritDamage);
          if (HP <= 0) {
            splitAsteroid();
            highscore += 1600 / (rad / ts);
          }
        }
      }
    }
  }
  void splitAsteroid() {
    if (rad > (8 * ts)) {
      a.add(new asteroid(pos.x, pos.y,ang + random(0.5), rad / 1.5f));
      a.add(new asteroid(pos.x, pos.y,ang + random(-0.5), rad / 1.5f));
    }
    remove = true;
  }
  void display() {
    strokeWeight(1);
    noFill();
    pushMatrix();
    translate(pos.x, pos.y);
    for (int i = 0; i < points.length; i++) {
      points[i].rotate(rotSpeed);
      if (i + 1 < points.length) {
        line(points[i].x, points[i].y, points[i + 1].x, points[i + 1].y);    
      } else line(points[i].x, points[i].y, points[0].x, points[0].y);  
    }
    popMatrix();
  displayHealth(pos.x, pos.y, rad, HP);
  }
}
