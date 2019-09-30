class asteroid {
  PVector pos;
  float acc = 0.1,
        HP = 100,
        ang = 0;
  boolean remove = false;
  asteroid(float xpos, float ypos) {
    pos = new PVector(xpos, ypos);
    acc *= ts;
    ang = random(360);
  }
  void update() {
    display();
    remove = (pos.x <= -asteroidSize * 2) || (pos.x >= width + asteroidSize * 2) || (pos.y <= -asteroidSize * 2) || (pos.y >= height + asteroidSize * 2);  
    if (dist(pos.x, pos.y, p.pos.x, p.pos.y) <= (asteroidSize / 2) + (playerSize / 2)) {
      dealDamage();
    }
    pos.x += (acc * cos(ang)) * deltaTime;
    pos.y += (acc * sin(ang)) * deltaTime;
  }
  void dealDamage() {
    p.HP -= p.staticDamage *0.75;
    remove = true;
    return;
  }
  void display() {
    strokeWeight(2);
    noFill();
    ellipse(pos.x, pos.y, asteroidSize, asteroidSize);
    if (HP != 100) {
      noStroke();
      fill(255,0,0);
      rect(pos.x, pos.y + 25 * ts, asteroidSize, 10 * ts);
      fill(0,255,0);
      rectMode(CORNER);
      rect(pos.x - asteroidSize / 2, pos.y + 20 * ts, asteroidSize * (HP / 100), 10 * ts);
      rectMode(CENTER);
      stroke(255);
    }
  }
}
