class player {
  PVector pos;
  float vx = 0, vy = 0, ang = 0,
        acc = 0.007, rotAcc = 0.07,
        defacc = 0, staticDamage = 20, maxCritDamage = 4,
        HP = 100;
        
  int bulletLastFrame = 0;
  boolean left = false, right = false, up = false, down = false, shoot = false,
          inverseControls = false;
          
  ArrayList<bullet> bul = new ArrayList<bullet>();
  player(int xpos, int ypos) {
    pos = new PVector(xpos, ypos); 
    acc *= ts;
    defacc = acc;
  }
  void update() {
    if (bul.size() > 0) {
      for (int i = 0; i < bul.size(); i++) {
        if (bul.get(i).remove) {
          bul.remove(i);
          continue;
        }
        bul.get(i).update();  
      }
    }
    display();
        
    shoot();
    ang += inverseControls ? (int(left) - int(right)) * rotAcc : (int(right) - int(left)) * rotAcc;    
    vx += (cos(ang) * acc * (int(up) - int(down)) * deltaTime);
    vy += (sin(ang) * acc * (int(up) - int(down)) * deltaTime);
    pos.x = constrain(pos.x + vx, playerSize / 2, width - (playerSize / 2));
    pos.y = constrain(pos.y + vy, playerSize / 2, height - (playerSize / 2));
    vx *= vx > -0.01 && vx < 0 || vx < 0.01 && vx > 0 ? 0 : 0.97;
    vy *= vy > -0.01 && vy < 0 || vy < 0.01 && vy > 0 ? 0 : 0.97;
    
  }
  void shoot() {
    if (frameCount - bulletLastFrame > 10 && shoot){
      bul.add(new bullet(ang)); 
      bulletLastFrame = frameCount;
    }
  }
  void display() {
    pushMatrix();
      translate(pos.x, pos.y);
      rotate(ang + HALF_PI);
      noFill();
      stroke(255);
      strokeWeight(1);
      triangle(-playerSize / 2, playerSize / 2,playerSize / 2, playerSize / 2,0, - playerSize / 2);
      fill(255,0,0);
    popMatrix();
    if (HP != 100) {
      noStroke();
      fill(255,0,0);
      rect(pos.x, pos.y + 35 * ts, playerSize, 10 * ts);
      fill(0,255,0);
      rectMode(CORNER);
      rect(pos.x - playerSize / 2, pos.y + 20 * ts, playerSize * (HP / 100), 10 * ts);
      rectMode(CENTER);
      stroke(255);
    }
  }
}
