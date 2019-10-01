class button {
  PVector pos;
  boolean visible = false;
  String title = "";
  int d = 0, touchCount = 0;
  button(String t, int xpos, int ypos, int diam, boolean v) {
    visible = v;
    title = t;
    d = diam;
    pos = new PVector(xpos, ypos);
  }
  boolean setVisible(boolean b) {
    return visible = b;  
  }
  void update() {
    display();
    if (touches.length > 0) {
      setKey(returnButton(pos.x, pos.y));
    } else setKey(false);
  }
  void setKey(boolean b) {
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
  void display() {
    fill(255);
    textFont(fnt);
    textSize(13 * ts);
    text(title, pos.x, pos.y);
    noFill();
    stroke(255);
    strokeWeight(1);
    ellipse(pos.x, pos.y, d, d);
  }
}
