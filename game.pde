import controlP5.*;
import android.util.DisplayMetrics;

ControlP5 menuController, settingsController, ingameController;
Button play, settings, back, restart;
Toggle invCtrl;

player p;
float ts = 0, 
      playerSize = 64, 
      asteroidSize = 32, 
      btnSize = 80, 
      bulletSize = 8,
      currentTime = 0, 
      lastTime = 0, 
      deltaTime = 0;
int highscore = 0;
PVector shootPos, movePos;
double spawnRate = 90; //Every 60 frames
String gameState = "menu"; //Gamestate (ingame;menu;settings;highscores)
boolean inverseControls = false;

ArrayList<button> btn = new ArrayList<button>();
ArrayList<asteroid> a = new ArrayList<asteroid>();

XML highscoreFile, settingsFile;

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
  
  fnt = createFont("Monospaced",32 * ts);
  
  menuController = new ControlP5(this);
  settingsController = new ControlP5(this);
  ingameController = new ControlP5(this);
  
  //Settings menu
  back = settingsController.addButton("Back",20 * ts).setSize((int)(125 * ts),(int)(25 * ts))
    .setPosition(75 * ts, height - (100 * ts))
    .setSwitch(false)
    .setId(0)
    .setFont(fnt)
    .setVisible(false); 
    
  //Main menu  
  play = menuController.addButton("Play",20 * ts).setSize((int)(250 * ts),(int)(40 * ts))
    .setPosition(width / 1.5f, height / 1.75f)
    .setSwitch(false)
    .setId(1)
    .setFont(fnt)
    .setVisible(true);
  settings = menuController.addButton("Settings",20 * ts).setSize((int)(250 * ts),(int)(40 * ts))
    .setPosition(width / 1.5f, (height / 1.75f) + (50 * ts))
    .setSwitch(false)
    .setId(2)
    .setFont(fnt)
    .setVisible(true);
    
  //Ingame controls
  PFont temp = createFont("Monospace",13 * ts);
  restart = ingameController.addButton("Restart game....",20 * ts).setSize((int)(125 * ts),(int)(25 * ts))
    .setPosition(75 * ts, height - (100 * ts))
    .setSwitch(false)
    .setId(3)
    .setFont(temp)
    .setVisible(false);
  PFont temp1 = createFont("Monospace",16 * ts);  
  invCtrl = settingsController.addToggle("Enable Inverse controls",false).setSize((int)(125 * ts),(int)(25 * ts))
    .setPosition(width / 1.5f, height / 1.75f)
    .setId(4)
    .setMode(ControlP5.SWITCH)
    .setFont(temp1)
    .setVisible(false); 
  
  textAlign(CENTER,CENTER);
  rectMode(CENTER);
  movePos = new PVector(int(width - (100*ts)),int(height - (100*ts)));
  shootPos = new PVector(int(50*ts), int(height - (50*ts)));
  p = new player(width >> 2, width >> 2);
  createButtons();
  
  //Ingame settings
  if (!hasPermission("android.permission.READ_EXTERNAL_STORAGE")) {
    requestPermission("android.permission.READ_EXTERNAL_STORAGE");  
  } else if (!hasPermission("android.permission.WRITE_EXTERNAL_STORAGE")) {
    requestPermission("android.permission.WRITE_EXTERNAL_STORAGE");  
  } else {
    highscoreFile = loadXML(sketchPath + "/data/highscore.xml");
    settingsFile = loadXML("settings.xml");
    inverseControls = settingsFile.getChild("invertControls").getName().equals("true");
    invCtrl.setState(inverseControls);
  }
}
 
void draw(){
  background(0);
  if (gameState.equals("menu") || gameState.equals("settings")) {
    textSize(30 * ts);
  } else if (gameState.equals("highscores")) {
    displayScoreTable();
  } else if (gameState.equals("play")) {
    if (p.HP <= 0) {
      restartGame();  
    }
    spawnRate -= frameCount % 1200 == 0 && spawnRate >= 20 ? 1 : 0;
    highscore += frameCount % 3 == 0 ? 1 : 0;
    
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
          PVector temp = new PVector(random(-asteroidSize, -asteroidSize / 4), random(-asteroidSize, height + asteroidSize));
          float ang = atan2((p.pos.y + (random(-200,200) * ts)) - temp.y, (p.pos.x + (random(-200,200) * ts)) - temp.x);
          a.add(new asteroid(int(temp.x), int(temp.y), ang, asteroidSize));
          break;
        }
        case 1 : {
          PVector temp = new PVector(random(-asteroidSize, width + asteroidSize),random(-asteroidSize, -asteroidSize / 4));
          float ang = atan2((p.pos.y + (random(-200,200) * ts)) - temp.y, (p.pos.x + (random(-200,200) * ts)) - temp.x);
          a.add(new asteroid(int(temp.x), int(temp.y), ang, asteroidSize));
          break;
        }
        case 2 : {
          PVector temp = new PVector(random(width + asteroidSize / 4, width + asteroidSize),random(-asteroidSize, height + asteroidSize));
          float ang = atan2((p.pos.y + (random(-200,200) * ts)) - temp.y, (p.pos.x + (random(-200,200) * ts)) - temp.x);
          a.add(new asteroid(int(temp.x), int(temp.y), ang, asteroidSize));
          break;
        }
        case 3 : {
          PVector temp = new PVector(random(-asteroidSize, width + asteroidSize),random(height + asteroidSize / 4, height + asteroidSize));
          float ang = atan2((p.pos.y + (random(-200,200) * ts)) - temp.y, (p.pos.x + (random(-200,200) * ts)) - temp.x);
          a.add(new asteroid(int(temp.x), int(temp.y), ang, asteroidSize));
          break;
        }
      }
    }
    
    for (int i = 0; i < btn.size(); i++) {
      btn.get(i).update();
    }     
        
    deltaTime();
    textSize(12 * ts);
    fill(255);
    text("FPS: " + int(frameRate),20 * ts, height - (18 * ts));
  }  
}
void restartGame() {
  updateScoreTable();
  a.clear();
  gameState = "highscores";
  p = new player(width >> 2, width >> 2);
  spawnRate = 60;
}
void controlEvent(ControlEvent theEvent) {
  if (!gameState.equals("play")) {
    switch(theEvent.getController().getId()){
       case 0: {
         gameState = "menu";
         play.setVisible(true);
         settings.setVisible(true);
         invCtrl.setVisible(false);
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
         invCtrl.setVisible(true);
         back.setVisible(true);
         break;
       }
       case 3: {
         gameState = "play";
         highscore = 0;
         restart.setVisible(false);
         break;
       }
       case 4: {
         inverseControls = invCtrl.getBooleanValue();
         String temp = "";
         if (inverseControls) {
           temp = "true";    
         } else temp = "false";
         println(settingsFile.getChild("invertControls").getContent());
         settingsFile.getChild("invertControls").setContent(temp);
         println(settingsFile.getChild("invertControls").getContent());
         break;
       }
    }
  }
}
void backPressed() {
  if (gameState.equals("play")) {
    gameState.equals("menu");  
  } else exit();
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
void updateScoreTable() {
  IntList temp = new IntList();
  for (int i = 0; i < 10; i++) {
    temp.append(highscoreFile.getChild("score" + i).getIntContent());  
  }
  temp.append(highscore);
  temp.sortReverse();
  for (int i = 0; i < 10; i++) {
    highscoreFile.getChild("score" + i).setContent(str(temp.get(i))); 
  }
  saveXML(highscoreFile,sketchPath + "/data/highscore.xml");
  highscoreFile = loadXML(sketchPath + "/data/highscore.xml");
}

void displayScoreTable() {
  restart.setVisible(true);
  pushStyle();
  fill(255);
  textSize(40);
  int temp = 0;
  text("HIGHSCORES", width / 1.9f, 55 * ts);
  for (int i = 0; i < 10; i++) {
    if (highscoreFile.getChild("score" + i).getIntContent() == highscore) {
      text("Score: " + highscoreFile.getChild("score" + i).getContent() + " <-- Last score", width / 1.9f, (110 * ts) + temp);
    } else text("Score: " + highscoreFile.getChild("score" + i).getContent(), width / 1.9f, (110 * ts) + temp); 
    temp += 35 * ts;
  }
  popStyle();
}

void displayHealth(float xpos, float ypos, float size, float hp) {
  if (hp != 100) {
    pushStyle();
        noStroke();
        fill(255,0,0);
        rect(xpos, ypos + 35 * ts, size, 10 * ts);
        fill(0,255,0);
        rectMode(CORNER);
        rect(xpos - size / 2, ypos + 30 * ts, size * (hp / 100), 10 * ts);
        rectMode(CENTER);
        stroke(255);
    popStyle();
  }
  return;
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
