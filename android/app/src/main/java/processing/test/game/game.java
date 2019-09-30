package processing.test.game;

import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import android.util.DisplayMetrics; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class game extends PApplet {


player p;
float ts = 0, 
      playerSize = 64, 
      asteroidSize = 48, 
      btnSize = 80, 
      bulletSize = 8,
      currentTime = 0, 
      lastTime = 0, 
      deltaTime = 0;
double spawnRate = 30; //Every 30 frames
String gameState = "ingame"; //Gamestate (ingame;menu;settings)
ArrayList<button> btn = new ArrayList<button>();
ArrayList<asteroid> a = new ArrayList<asteroid>();

public void settings(){
  fullScreen(JAVA2D);
}
public void setup(){
  
  //Setup scaling
  orientation(LANDSCAPE); 
  DisplayMetrics metrics = new DisplayMetrics();    
  getActivity().getWindowManager().getDefaultDisplay().getMetrics(metrics); 
  
  int screenDensity = metrics.densityDpi; 
  ts = screenDensity/160;
  ts = ts > 2 ? ts - 0.5f : ts;
  
  bulletSize *= ts;
  asteroidSize *= ts;
  playerSize *= ts;
  btnSize *= ts;
  
  textAlign(CENTER,CENTER);
  rectMode(CENTER);
  
  p = new player(width / 2, width / 2);
  createButtons();
}
 
public void draw(){
  if (gameState.equals("ingame")) {
    background(0);
    
    p = p.HP <= 0 ? new player(width / 2, width / 2) : p;
    p.update();
    
    if (a.size() > 0) {
      for (int i  = 0; i < a.size(); i++) {
        a.get(i).update();
        if (p.bul.size() > 0) {
          for (int b = 0; b < p.bul.size(); b++) {
            if (dist(p.bul.get(b).bulpos.x, p.bul.get(b).bulpos.y, a.get(i).pos.x, a.get(i).pos.y) <= (bulletSize / 2 + asteroidSize / 2)) {
              p.bul.get(b).remove = true;
              a.get(i).HP -= p.staticDamage + random(p.maxCritDamage);
              if (a.get(i).HP <= 0) {
                a.remove(i);
                continue;
              }
            }
          }
        }
      }
    }
    
    if (touches.length < 0) {
      for (int i = 0; i< btn.size(); i++) {
        btn.get(i).pressed = false;  
      }
    }
    for (int i = 0; i < btn.size(); i++) {
      btn.get(i).update();
    }
    if (frameCount % spawnRate == 0) {
      switch(PApplet.parseInt(random(0,3))) {
        case 0 : {
          a.add(new asteroid(PApplet.parseInt(random(-asteroidSize, -asteroidSize / 4)), PApplet.parseInt(random(-asteroidSize, height + asteroidSize))));
          break;
        }
        case 1 : {
          a.add(new asteroid(PApplet.parseInt(random(-asteroidSize, width + asteroidSize)), PApplet.parseInt(random(-asteroidSize, -asteroidSize / 4))));
          break;
        }
        case 2 : {
          a.add(new asteroid(PApplet.parseInt(random(width + asteroidSize / 4, width + asteroidSize)), PApplet.parseInt(random(-asteroidSize, height + asteroidSize))));
          break;
        }
        case 3 : {
          a.add(new asteroid(PApplet.parseInt(random(-asteroidSize, width + asteroidSize)), PApplet.parseInt(random(height + asteroidSize / 4, height + asteroidSize))));
          break;
        }
      }
    }
    
    deltaTime();
    textSize(10 * ts);
    text("FPS: " + PApplet.parseInt(frameRate),15 * ts, height - (15 * ts));
  }  
}

public void createButtons() {
  for (int i = 0; i < 5; i++) {
    switch(i) {
      case 0 : {
        btn.add(new button("left", PApplet.parseInt(width - (150*ts)), PApplet.parseInt(height - (100*ts)), PApplet.parseInt(50 * ts), true)); 
        break;
      }
      case 1 : {
        btn.add(new button("right", PApplet.parseInt(width - (50*ts)), PApplet.parseInt(height - (100*ts)), PApplet.parseInt(50 * ts), true)); 
        break;
      }
      case 2 : {
        btn.add(new button("up", PApplet.parseInt(width - (100*ts)), PApplet.parseInt(height - (150*ts)), PApplet.parseInt(50 * ts), true)); 
        break;
      }
      case 3 : {
        btn.add(new button("down", PApplet.parseInt(width - (100*ts)), PApplet.parseInt(height - (50*ts)), PApplet.parseInt(50 * ts), true)); 
        break;
      }
      case 4 : {
        btn.add(new button("shoot", PApplet.parseInt(50*ts), PApplet.parseInt(height - (50*ts)), PApplet.parseInt(50*ts), true)); 
        break;  
      }
    }
  }
}

public float deltaTime() {
  float currentTime = millis();
  if (lastTime == 0) {
      lastTime = currentTime;
      deltaTime = 0;
  } else {
      deltaTime = currentTime - lastTime;
      lastTime = currentTime;
  }
  return deltaTime;
}
public boolean returnButton(float xpos, float ypos) {
  for (int i = 0; i < touches.length; i++) {
    if (dist(xpos, ypos, touches[i].x, touches[i].y) <= btnSize / 1.5f) {
      return true;  
    } else continue;
  }
  return false;
}
class asteroid {
  PVector pos;
  PVector[] points = new PVector[6];
  float acc = 0.1f,
        HP = 100,
        ang = 0,
        rotSpeed = 0.05f;
  boolean remove = false;
  asteroid(float xpos, float ypos) {
    pos = new PVector(xpos, ypos);
    acc *= ts;
    ang = random(360);
    rotSpeed = random(0.005f,0.015f);
    makeAsteroid();
  }
  public void makeAsteroid() {
    for (int i = 0; i < 6; i++) {
      if (i == 6) {
        points[i] = points[0];     
      } else {
        points[i] = new PVector(sin(i) * (asteroidSize / random(1,2)), cos(i) * (asteroidSize / random(1,2))); 
      }
    }
  }
  public void update() {
    display();
    remove = (pos.x <= -asteroidSize * 2) || (pos.x >= width + asteroidSize * 2) || (pos.y <= -asteroidSize * 2) || (pos.y >= height + asteroidSize * 2);  
    if (dist(pos.x, pos.y, p.pos.x, p.pos.y) <= (asteroidSize / 2) + (playerSize / 2)) {
      dealDamage();
    }
    pos.x += (acc * cos(ang)) * deltaTime;
    pos.y += (acc * sin(ang)) * deltaTime;
  }
  public void dealDamage() {
    p.HP -= p.staticDamage *0.75f;
    remove = true;
    return;
  }
  public void display() {
    strokeWeight(2);
    noFill();
    //ellipse(pos.x, pos.y, asteroidSize, asteroidSize);
    pushMatrix();
    translate(pos.x, pos.y);
    for (int i = 0; i < points.length; i++) {
      points[i].rotate(rotSpeed);
      if (i + 1 < points.length) {
        line(points[i].x, points[i].y, points[i + 1].x, points[i + 1].y);    
      } else line(points[i].x, points[i].y, points[0].x, points[0].y);  
    }
    popMatrix();
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
class bullet {
  PVector bulpos;
  float ang = 0;
  float acc = 0.3f;
  boolean remove = false,
          r = false;
  bullet(float a) {
    bulpos = new PVector(p.pos.x + p.vx, p.pos.y + p.vy);
    ang = a;
    acc *= ts;
  }
  public void update() {
    if (dist(p.pos.x, p.pos.y, bulpos.x,bulpos.y) >= playerSize / 2) {
      display();
    }
    bulpos.x += (cos(ang) * acc) * deltaTime;  
    bulpos.y += (sin(ang) * acc) * deltaTime; 
    remove = bulpos.x < 0 || bulpos.x > width || bulpos.y < 0 || bulpos.y > height;
  }
  public void display() {
    pushMatrix();
      fill(255,0,0);
      translate(bulpos.x, bulpos.y);
      rotate(ang);
      ellipse(0,0,bulletSize,bulletSize);
    popMatrix();
  }
}
class button {
  PVector pos;
  boolean visible = false, pressed = false;
  String title = "";
  int d = 0;
  button(String t, int xpos, int ypos, int diam, boolean v) {
    visible = v;
    title = t;
    d = diam;
    pos = new PVector(xpos, ypos);
  }
  public boolean setVisible(boolean b) {
    return visible = b;  
  }
  public void update() {
    display();
    pressed = returnButton(pos.x, pos.y);  
    setKey(pressed);
  }
  public void setKey(boolean b) {
    if (title.equals("left")) {
      p.left = b;   
    } else if (title.equals("right")) {
      p.right = b;   
    } 
    if (title.equals("up")) {
      p.up = b;   
    } else if (title.equals("down")) {
      p.down = b;  
    }
    if (title.equals("shoot")) {
      p.shoot = b;  
    }
  }
  public void display() {
    fill(255);
    textSize(13 * ts);
    text(title, pos.x, pos.y);
    noFill();
    stroke(255);
    ellipse(pos.x, pos.y, d, d);
  }
}
class player {
  PVector pos;
  float vx = 0, vy = 0, ang = 0,
        acc = 0.009f, rotAcc = 0.05f,
        defacc = 0, staticDamage = 5, maxCritDamage = 3,
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
  public void update() {
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
    ang += inverseControls ? (PApplet.parseInt(left) - PApplet.parseInt(right)) * rotAcc : (PApplet.parseInt(right) - PApplet.parseInt(left)) * rotAcc;    
    vx += (cos(ang) * acc * (PApplet.parseInt(up) - PApplet.parseInt(down)) * deltaTime);
    vy += (sin(ang) * acc * (PApplet.parseInt(up) - PApplet.parseInt(down)) * deltaTime);
    pos.x = constrain(pos.x + vx, playerSize / 2, width - (playerSize / 2));
    pos.y = constrain(pos.y + vy, playerSize / 2, height - (playerSize / 2));
    vx *= vx > -0.01f && vx < 0 || vx < 0.01f && vx > 0 ? 0 : 0.97f;
    vy *= vy > -0.01f && vy < 0 || vy < 0.01f && vy > 0 ? 0 : 0.97f;
    
  }
  public void shoot() {
    if (frameCount - bulletLastFrame > 10 && shoot){
      bul.add(new bullet(ang)); 
      bulletLastFrame = frameCount;
    }
  }
  public void display() {
    pushMatrix();
      translate(pos.x, pos.y);
      rotate(ang + HALF_PI);
      noFill();
      stroke(255);
      strokeWeight(3);
      triangle(-playerSize / 2, playerSize / 2,playerSize / 2, playerSize / 2,0, - playerSize / 2);
      fill(255,0,0);
    popMatrix();
    if (HP != 100) {
      noStroke();
      fill(255,0,0);
      rect(pos.x, pos.y + 25 * ts, playerSize, 10 * ts);
      fill(0,255,0);
      rectMode(CORNER);
      rect(pos.x - playerSize / 2, pos.y + 20 * ts, playerSize * (HP / 100), 10 * ts);
      rectMode(CENTER);
      stroke(255);
    }
  }
}
}
