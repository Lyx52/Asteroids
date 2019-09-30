class menu {
  ArrayList<sqbtn> b = new ArrayList<sqbtn>();
  menu() {
    for (int i = 0; i < 3; i++) {
      switch(i) {
        case 0 : {
          b.add(new sqbtn("Play",(float) width / 2,(float) height / 2,150 * ts, 20 * ts, color(200,200,0)));
          break;
        }
      }
    }
  }
  void update() {
    b.get(0).update();  
  }
}
class sqbtn {
  PVector pos;
  String title = "";
  float w = 0, h = 0;
  color col = 0;
  sqbtn(String t, float xpos, float ypos, float btnWidth, float btnHeight, color c) {
    title = t;
    pos = new PVector(xpos, ypos);
    w = btnWidth;
    h = btnHeight;
    col = c;
  }
  void update() {
    display();
    if ((pos.x - (w / 2)) >= mouseX && (pos.x + (w / 2)) <= mouseX) {
      println("t");
    }
  }
  void onPress() {
    if (title.equals("Play")) {
      println("test"); 
    }
  }
  void display() {
    fill(col);
    stroke(255);
    rect(pos.x, pos.y, w * ts, h * ts);
    fill(255);
    textSize(13 * ts);
    text(title, pos.x, pos.y);
  }
}
