import controlP5.*;

int toolNumber = 0;
int brushSize;
int brushShape;
int clickState = 0;
int saturationValue = 100;
int brightnessValue = 255;

int fromX;
int fromY;
int toX;
int toY;
boolean lineQueued = false;

PGraphics GUI;
PGraphics drawLayer;
PGraphics lineLayer;
PGraphics cursorLayer;
PImage logoImage;

color currentBackground;
color targetBackground;
color currentTextColor;
color canvasColor;
color currentBrushColor = #000000;

ControlP5 cp5;

void setup() {

  size(1280, 800);
  noCursor();
  canvasColor = #ffffff;
  background(canvasColor);
  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);

  // Creates an 'on/off' style switch for dark mode
  cp5.addToggle("darkMode")
    .setPosition(int(height*0.01), height*0.96)
    .setSize(int(height*0.06), int(height*0.03))
    .setValue(false)
    .setMode(ControlP5.SWITCH)
    .setCaptionLabel("")
    ;

  // Another on/off switch for square brushes.
  cp5.addToggle("squareBrush")
    .setPosition(int(height*0.52), height*0.02)
    .setSize(int(width*0.05), int(width*0.025))
    .setValue(false)
    .setMode(ControlP5.SWITCH)
    .setCaptionLabel("")
    ;

  // The slider for changing brush size/thickness
  cp5.addSlider("brushSize")
    .setPosition(int(width*0.11), int(height*0.02))
    .setWidth(int(width*0.08))
    .setHeight(int(height*0.05))
    .setRange(1, 30)                                                 // The thickness value of the brush
    .setValue(15)                                                    // Default value on app launch                         
    //.setNumberOfTickMarks(39)                                      // Number of ticks on the slider. (Keeps things as ints)
    .setSliderMode(Slider.FIX)                                       // Use FLEXIBLE as an alternative slider style
    .setCaptionLabel("")
    ;

  // slider for Saturation of colours
  cp5.addSlider("saturationValue")
    .setPosition(int(width*0.81), int(height*0.02))
    .setWidth(int(width*0.08))
    .setHeight(int(height*0.05))
    .setRange(0, 255)                                                 // The thickness value of the brush
    .setValue(100)                                                    // Default value on app launch                         
    //.setNumberOfTickMarks(39)                                      // Number of ticks on the slider. (Keeps things as ints)
    .setSliderMode(Slider.FIX)                                       // Use FLEXIBLE as an alternative slider style
    .setCaptionLabel("")
    ;

  // slider for Brightness of colours
  cp5.addSlider("brightnessValue")
    .setPosition(int(width*0.91), int(height*0.02))
    .setWidth(int(width*0.08))
    .setHeight(int(height*0.05))
    .setRange(0, 255)                                                 // The thickness value of the brush
    .setValue(255)                                                    // Default value on app launch                         
    //.setNumberOfTickMarks(39)                                      // Number of ticks on the slider. (Keeps things as ints)
    .setSliderMode(Slider.FIX)                                       // Use FLEXIBLE as an alternative slider style
    .setCaptionLabel("")
    ;

  // This is the bank of buttons for tool selection. (keyboard shortcuts still work)  
  cp5.addButton("nothingSelected").setValue(0).setPosition(width*0.46, height*0.025).setSize(int(width*0.03), (int(height*0.05)));
  cp5.addButton("brushSelected").setValue(0).setPosition(width*0.51, height*0.025).setSize(int(width*0.03), (int(height*0.05)));
  cp5.addButton("eraserSelected").setValue(0).setPosition(width*0.56, height*0.025).setSize(int(width*0.03), (int(height*0.05)));
  cp5.addButton("lineSelected").setValue(0).setPosition(width*0.61, height*0.025).setSize(int(width*0.03), (int(height*0.05)));
  cp5.addButton("canvasSelected").setValue(0).setPosition(width*0.66, height*0.025).setSize(int(width*0.03), (int(height*0.05)));
  cp5.addButton("clearCanvas").setValue(0).setPosition(width*0.71, height*0.025).setSize(int(width*0.03), (int(height*0.05)));

  // The three layers I'm using for the drawing of everything in PaintUI
  GUI = createGraphics(width, height);
  drawLayer = createGraphics(width, height);
  cursorLayer = createGraphics(width, height);
  lineLayer = createGraphics(width, height);
}

void draw() {

  // Tries to make the UI panels match the current setting of light/dark
  currentBackground = lerpColor(currentBackground, targetBackground, 0.1);
  background(canvasColor);
  GUI.beginDraw();  
  GUI.noStroke();

  /* 
   This method of UI drawing uses boxes overlaid onto the drawing layer to bound the canvas better.
   The UI is redrawn on top of the current drawing every frame, so there's no spill over at all.
   I found this better than using a simple background, then bounding the mouse rigorously every frame.
   This was is way less computationally difficult in the end, if a little inelegant.
   */
  GUI.fill(currentBackground);                                       //
  GUI.rect(0, 0, width, height*0.1);                                    // The top bar of the GUI
  GUI.rect(width*0.8, height*0.1, width, height);                       // The side bar on the right
  GUI.rect(0, height*0.95, width*0.8, height);                          // The final part of the GUI Frame

  //now that the base is redrawn, everything else can be put on top of it

  GUI.fill(currentBrushColor, 128);                                   // Active tool indicator fill colour is the same as the brush
  switch(toolNumber) {
  case 0:
    GUI.rect(width*0.45, 0, width*0.05, height*0.1);
    break;
  case 1:
    GUI.rect(width*0.5, 0, width*0.05, height*0.1);
    break;
  case 2:
    GUI.rect(width*0.55, 0, width*0.05, height*0.1);
    break;
  case 3:
    GUI.rect(width*0.6, 0, width*0.05, height*0.1);
    break;
  case 4:
    GUI.rect(width*0.65, 0, width*0.05, height*0.1);
    break;
  }

  if (keyPressed && key== 'x') {
    GUI.rect(width*0.7, 0, width*0.05, height*0.1);
  }

  int boxWidth = int(width*0.025);                                   // Define the standard box width, fitting 8 into the side-panel.
  for (int i = 0; i < 8; i++) {                                      // Loop for generating shades of black, grey and white
    for (int i2 = 0; i2 < 4; i2++) {
      GUI.fill((i+1)*(i2+1)*8-1);
      GUI.rect(width*0.8+(boxWidth)*i, (height*0.1)+(boxWidth*i2), width/40, width/40);
    }
  }

  GUI.colorMode(HSB, 256);                                           // Change to HSB from RGB for the colour picker
  for (int i = 0; i < 8; i++) {                                      // Loop for generating colours
    for (int i2 = 0; i2 < 4; i2++) {
      GUI.fill(i*8 + (i2*64), saturationValue, brightnessValue);
      GUI.rect(width*0.8+(boxWidth)*i, (height*0.1+boxWidth*4)+(boxWidth*i2), width/40, width/40);
    }
  }

  modifierCheck();
  
  GUI.fill(currentBrushColor);                                        // sets preview to brushColor
  GUI.stroke(currentTextColor);
  
  

  // Checks to see if the brush is round or squared and displays preview of brush
  if (brushShape == 0) {
    GUI.ellipse(int(width*0.25), int(height*0.05-5), brushSize, brushSize);
  } else {
    GUI.rectMode(CENTER);
    GUI.rect(int(width*0.25), int(height*0.05-5), brushSize, brushSize);
  }

  GUI.fill(currentTextColor);                                        // sets text labels to correct contrasting colour
  GUI.stroke(currentTextColor);
  GUI.textAlign(CENTER, CENTER);
  GUI.text("Select", width*0.475, height*0.085);
  GUI.text("Brush", width*0.525, height*0.085);
  GUI.text("Eraser", width*0.575, height*0.085);
  GUI.text("Line", width*0.625, height*0.085);
  GUI.text("Canvas", width*0.675, height*0.085);
  GUI.text("Clear", width*0.725, height*0.085);
  GUI.text("S", width*0.475, height*0.013);
  GUI.text("B", width*0.525, height*0.013);
  GUI.text("E", width*0.575, height*0.013);
  GUI.text("L", width*0.625, height*0.013);
  GUI.text("C", width*0.675, height*0.013);
  GUI.text("X", width*0.725, height*0.013);
  GUI.text("Saturation", width*0.85, height*0.08);
  GUI.text("Brightness", width*0.95, height*0.08);
  if (toolNumber == 2) {
    GUI.text("Eraser Size", (width*0.15), (height*0.08));
  } else if (toolNumber == 3) {
    GUI.text("Line Thickness", (width*0.15), (height*0.08));
  } else {
    GUI.text("Brush Size", (width*0.15), (height*0.08));
  }

  GUI.text("Retro Brush", (width*0.35), (height*0.07));
  GUI.text(brushSize, (width * 0.25), (height*0.055)+(brushSize/2)); // Shows the value of the current brush size

  GUI.textAlign(LEFT, CENTER);
  GUI.text("Selected Tool", (width*0.01), (height*0.03));            // "Selected Tool:"
  GUI.text(getToolName(toolNumber), (width*0.01), (height*0.06));    // Current tool label update
  GUI.fill(canvasColor);                                             // Set fill back to white for draw environment
  GUI.rectMode(CORNER);
  GUI.image(logoImage, width*0.82, height*0.87, width*0.16, height*0.06);

  GUI.endDraw();

  drawLayer.beginDraw();
  drawLayer.strokeWeight(brushSize);
  if (toolNumber == 1) { 
    drawLayer.stroke(currentBrushColor);
  } else { 
    drawLayer.stroke(canvasColor);
  }
  attemptDraw();
  drawLayer.endDraw();

  cursorLayer.beginDraw();
  drawCursor();
  cursorLayer.endDraw();

  // Draw the artwork next, with the Cursor on the very top.
  image(drawLayer, 0, 0);
  image(GUI, 0, 0);
  image(lineLayer, 0, 0);
  cp5.draw();
  image(cursorLayer, 0, 0);

  // Uncomment to see lines every 10% of the inner window width and height
  for (int i = 0; i < 10; i++) {
    line((i*width/10), 0, (i*width/10), height);
    line(0, (i*height/10), width, (i*height/10));
  }
}

void keyPressed() {

  GUI.fill(216, 190, 216);

  switch (key) {

  case 's':
    nothingSelected();
    break;
  case 'b':
    brushSelected();
    break;
  case 'e':
    eraserSelected();
    break;
  case 'l':
    lineSelected();
    break;
  case 'c':
    canvasSelected();
    break;
  case 'x':
    clearCanvas();
    break;
  }
}

void brushSelected() {
  toolNumber = 1;
  drawLayer.fill(currentBrushColor);
  drawLayer.rectMode(CENTER);
}
void eraserSelected() {
  toolNumber = 2;
  drawLayer.fill(canvasColor);
  drawLayer.stroke(255);
  drawLayer.rectMode(CENTER);
}
void lineSelected() {
  toolNumber = 3;
}
void nothingSelected() {
  toolNumber = 0;
}
void canvasSelected() {
  toolNumber = 4;
}

void clearCanvas() {
  drawLayer.clear();
  println("Canvas cleared!");
  canvasColor=#ffffff;
}

void mousePressed() {

  if (toolNumber == 4 && (inBoundsCheck(true) || (mouseX > width*0.8 && mouseY > height*0.1 && mouseY < height*0.42))) {
    canvasColor = get(mouseX-1, mouseY-1);
  } else if (mouseX > width*0.8 && mouseY > height*0.1 && mouseY < height*0.42) {
    currentBrushColor = get(pmouseX-1, pmouseY-1); 
    drawLayer.fill(currentBrushColor);
    //println("Brush Colour changed");
  }

  if (toolNumber == 3) {

    if (inBoundsCheck(true)) {
      clickState = 1;
      fromX = pmouseX;
      fromY = pmouseY;
    } else {

      // This will draw a point line at 0,0, preventing any buggy messes from occuring when starting/ending a line out of bounds
      fromX = 0;
      fromY = 0;
      toX = 0;
      toY = 0;
    }
  }
}

void mouseReleased() {

  if (toolNumber == 3) {

    if (inBoundsCheck(true)) {
      clickState = 0;
      lineQueued = true;
    } else {
      clickState = 0;
      lineLayer.clear();
    }
  }
}

// Checks to see if the mouse is in the drawing box's bounds, allowing drawing
boolean inBoundsCheck(boolean mouseInBounds) {
  if ((pmouseX < ((width*0.8))) && (pmouseY > (height*0.1)) && (pmouseY < ((height*0.95)))) {
    mouseInBounds = true;
  } else {
    mouseInBounds = false;
  }
  return mouseInBounds;
}

String getToolName(int toolNumber) {

  String toolName = "";
  switch(toolNumber) {
  case 0:
    toolName = "Select";
    break;
  case 1:
    toolName = "Brush";
    break;
  case 2:
    toolName = "Eraser";
    break;
  case 3:
    toolName = "Line";
    break;
  case 4:
    toolName = "Canvas";
    break;
  }
  return toolName;
}

void drawCursor() {

  // Clear the last frame's cursor off the screen.
  cursorLayer.clear();

  // Changing the fill colour of the cursor to highlight what tool is selected.
  switch (toolNumber) {
  case 0:
    // Select tool, no drawing capability
    cursorLayer.fill(255);
    break;

  case 1:
    //The brush tool
    if (inBoundsCheck(true)) {
      cursorLayer.noFill();
      if (brushShape == 0) {
        cursorLayer.circle(pmouseX, pmouseY, brushSize);
      } else {
        cursorLayer.rectMode(CENTER);
        cursorLayer.rect(pmouseX, pmouseY, brushSize, brushSize);
      }
    }
    cursorLayer.fill(#ff0000);
    break;

  case 2:
    // The eraser tool
    if (inBoundsCheck(true)) {
      cursorLayer.noFill();
      if (brushShape == 0) {
        cursorLayer.circle(pmouseX, pmouseY, brushSize);
      } else {
        cursorLayer.rectMode(CENTER);
        cursorLayer.rect(pmouseX, pmouseY, brushSize, brushSize);
      }
    }
    cursorLayer.fill(#00ff00);
    break;

  case 3:
    cursorLayer.fill(#0000ff);
    break;

  case 4:
    cursorLayer.fill(#808080);
    break;
  }

  if (mousePressed == false) {
    cursorLayer.triangle(pmouseX, pmouseY, pmouseX, (pmouseY+16), (pmouseX+12), (pmouseY+10));
  } else {
    cursorLayer.triangle(pmouseX, pmouseY, pmouseX, (pmouseY+8), (pmouseX+6), (pmouseY+5));
  }
}

void attemptDraw() {

  lineLayer.beginDraw();

  if (inBoundsCheck(true) && mousePressed == true) {

    if (toolNumber == 1 || toolNumber == 2) {
      if (brushShape == 0) {
        //drawLayer.ellipse(pmouseX, pmouseY, brushSize, brushSize);    // Old method, lots of gaps but better bounding
        drawLayer.strokeCap(ROUND);
        //drawLayer.line(mouseX, mouseY, pmouseX, pmouseY);               // New method, looks great but gross bounding
      } else {
        drawLayer.strokeCap(SQUARE);
      }
      drawLayer.line(mouseX, mouseY, pmouseX, pmouseY);
    } else if (toolNumber == 3 && clickState == 1) {

      if (inBoundsCheck(true)) {
        toX = pmouseX;
        toY = pmouseY;
        lineLayer.clear();
        lineLayer.strokeWeight(brushSize);
        lineLayer.stroke(#ff00ff, 128);
        if (brushShape == 0) { 
          lineLayer.strokeCap(ROUND);
        } else {
          lineLayer.strokeCap(SQUARE);
        }
        lineLayer.line(fromX, fromY, toX, toY);
      }
    }
  }

  if (lineQueued) {
    drawLayer.strokeWeight(brushSize);
    drawLayer.stroke(currentBrushColor);
    drawLayer.line(fromX, fromY, toX, toY); 
    lineQueued = false;
    lineLayer.clear();
  }
  lineLayer.endDraw();
}

void modifierCheck() {

  if (keyPressed && key == CODED && keyCode == SHIFT) {
    brushSize = int(cp5.getController("brushSize").getValue())*2;
    GUI.fill(currentTextColor);
    GUI.text("x2", width*0.27+brushSize/4, height*0.05-5);
  } else {
    GUI.fill(currentBackground);
    GUI.text("x2", width*0.27+brushSize/4, height*0.05-5);
    brushSize = int(cp5.getController("brushSize").getValue());
  }
}

public void controlEvent(ControlEvent theEvent) {
  //Whenever ANY GUI event is called, this fires
}

// handles whether or not the retro brush shall be used.
void squareBrush(boolean isSquare) {
  if (isSquare==false) {
    brushShape = 0;
  } else {
    brushShape = 1;
  }
}

// The toggle function for the dark mode feature.
void darkMode(boolean isDark) {
  if (isDark==true) {
    logoImage = loadImage("logol.png");
    targetBackground=#3c3c3c;
    currentTextColor=#d2d2d2;
  } else {
    logoImage = loadImage("logod.png");
    targetBackground=#d2d2d2;
    currentTextColor=#3c3c3c;
  }
}
