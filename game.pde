import controlP5.*;
import android.util.DisplayMetrics;

ControlP5 menuController, settingsController;
Button play, settings, back;

player p;
float ts = 0, 
      playerSize = 64, 
      asteroidSize = 48, 
      btnSize = 80, 
      bulletSize = 8,
      currentTime = 0, 
      lastTime = 0, 
      deltaTime = 0;     
PVector shootPos, movePos;
double spawnRate = 25; //Every 30 frames
String gameState = "menu"; //Gamestate (ingame;menu;settings)
ArrayList<button> btn = new ArrayList<button>();
ArrayList<asteroid> a = new ArrayList<asteroid>();

PFont fnt;
void settings(){
  fullScreen(JAVA2D);
}
void setup(){
  //Setup scaling
  orientation(LANDSCAPE); 
  DisplayMetrics metrics = new DisplayMetrics();    
  getActivity().getWindowManager().getDefaultDisplay().getMetrics(metrics); 
  
  int screenDensity = metrics.densityDpi; 
  ts = screenDensity/160;
  ts = ts > 2 ? ts - 0.5 : ts;
  
  bulletSize *= ts;
  asteroidSize *= ts;
  playerSize *= ts;
  btnSize *= ts;
  
  menuController = new ControlP5(this);
  settingsController = new ControlP5(this);
  
  //Settings menu
  back = settingsController.addButton("Back").setSize((int)(125 * ts),(int)(25 * ts))
    .setPosition(75 * ts, height - (100 * ts))
    .setSwitch(false)
    .setId(0)
    .setVisible(false);
    
  //Main menu  
  play = menuController.addButton("Play").setSize((int)(225 * ts),(int)(35 * ts))
    .setPosition(width / 1.5f, height / 1.75f)
    .setSwitch(false)
    .setId(1)
    .setVisible(true);
  settings = menuController.addButton("Settings").setSize((int)(225 * ts),(int)(35 * ts))
    .setPosition(width / 1.5f, (height / 1.75f) + (50 * ts))
    .setSwitch(false)
    .setId(2)
    .setVisible(true);
  
  
  textAlign(CENTER,CENTER);
  rectMode(CENTER);
  movePos = new PVector(int(width - (100*ts)),int(height - (100*ts)));
  shootPos = new PVector(int(50*ts), int(height - (50*ts)));
  p = new player(width >> 2, width >> 2);
  createButtons();
  fnt = createFont("Monospaced",32);
}
 
void draw(){
  background(0);
  if (gameState.equals("play")) {
    p = p.HP <= 0 ? new player(width >> 2, width >> 2) : p;
    p.update();
    
    if (a.size() > 0) {
      for (int i  = 0; i < a.size(); i++) {
        if (a.get(i).remove) {
          a.remove(i);
          continue;
        }
        a.get(i).update();
      }
    }
    
    if (frameCount % spawnRate == 0) {
      switch(int(random(0,3))) {
        case 0 : {
          a.add(new asteroid(int(random(-asteroidSize, -asteroidSize / 4)), int(random(-asteroidSize, height + asteroidSize)), random(360), asteroidSize));
          break;
        }
        case 1 : {
          a.add(new asteroid(int(random(-asteroidSize, width + asteroidSize)), int(random(-asteroidSize, -asteroidSize / 4)), random(360), asteroidSize));
          break;
        }
        case 2 : {
          a.add(new asteroid(int(random(width + asteroidSize / 4, width + asteroidSize)), int(random(-asteroidSize, height + asteroidSize)), random(360), asteroidSize));
          break;
        }
        case 3 : {
          a.add(new asteroid(int(random(-asteroidSize, width + asteroidSize)), int(random(height + asteroidSize / 4, height + asteroidSize)), random(360), asteroidSize));
          break;
        }
      }
    }
    
    thread("checkButtons");    
        
    deltaTime();
    textSize(12 * ts);
    fill(255);
    text("FPS: " + int(frameRate),20 * ts, height - (18 * ts));
  }  
}
void checkButtons() {
  for (int i = 0; i < btn.size(); i++) {
    btn.get(i).update();
  }  
}
void controlEvent(ControlEvent theEvent) {
  if (!gameState.equals("play")) {
    switch(theEvent.getController().getId()){
       case 0: {
         gameState = "menu";
         play.setVisible(true);
         settings.setVisible(true);
         back.setVisible(false);
         break;
       }
       case 1: {
         gameState = "play";
         play.setVisible(false);
         settings.setVisible(false);
         menuController.setAutoDraw(false);
         settingsController.setAutoDraw(false);
         break; 
       }
       case 2: {
         gameState = "settings";
         play.setVisible(false);
         settings.setVisible(false);
         back.setVisible(true);
         break;
       }
    }
  }
}
void createButtons() {
  for (int i = 0; i < 5; i++) {
    switch(i) {
      case 0 : {
       btn.add(new button("right", (int) (movePos.x + (50 * ts)), (int) movePos.y, int(50 * ts), true)); 
        break;
      }
      case 1 : {
        btn.add(new button("left", (int) (movePos.x - (50 * ts)), (int) movePos.y, int(50 * ts), true)); 
        break;
      }
      case 2 : {
        btn.add(new button("down", (int) movePos.x, (int) (movePos.y + (50 * ts)), int(50 * ts), true)); 
        break;
      }
      case 3 : {
        btn.add(new button("up", (int) movePos.x, (int) (movePos.y - (50 * ts)), int(50 * ts), true)); 
        break;
      }
      case 4 : {
        btn.add(new button("shoot", (int) shootPos.x, (int) shootPos.y, int(50*ts), true)); 
        break;  
      }
    }
  }
}
float deltaTime() {
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
boolean returnButton(float xpos, float ypos) {
  for (int i = 0; i < touches.length; i++) {
    if (dist(xpos, ypos, touches[i].x, touches[i].y) <= btnSize / 1.5) {
      return true;  
    } else continue;
  }
  return false;
}
