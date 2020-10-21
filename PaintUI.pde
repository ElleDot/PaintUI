import controlP5.*;

int toolNumber = 0;
int brushSize = 15;
int clickState = 0;
int saturationValue = 100;
int brightnessValue = 255;
int gridLines = 3;

int fromX;
int fromY;
int toX;
int toY;

boolean lineQueued = false;
boolean undoQueued = false;
boolean saveStateQueued = false;
boolean gridActive = true;                                           // For some reason, I can't stop the CP5 objects from
boolean darkActive = true;                                           // Firing on launch. true gets inverted to false at start
boolean isSquare = true;

PGraphics GUI;
PGraphics drawLayer;
PGraphics lineLayer;
PGraphics gridLayer;
PGraphics cursorLayer;
PImage logoImage;
ArrayList<PImage> savedStates = new ArrayList<PImage>();
PImage currentState;

color currentBackground;
color targetBackground;
color currentTextColor;
color canvasColor;
color currentBrushColor = #000000;
color oppositeTextColor;

ControlP5 cp5;

void setup() {

  //size(800, 600);                                                  // Lower screen sizes actually run significantly faster...
  size(1280,800);
  noCursor();                                                        // Setting noCursor due to custom ones used by PaintUI
  canvasColor = #ffffff;
  background(canvasColor);
  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);

  // Creates an 'on/off' style switch for dark mode
  cp5.addButton("darkMode")
    .setPosition(int(width*0.025), height*0.96)
    .setSize(int(width*0.05), int(height*0.03))
    .setValue(0)
    .setCaptionLabel("")
    ;
    
  // Creates an 'on/off' style switch for the grid
  cp5.addButton("gridVisible")
    .setPosition(int(width*0.325), height*0.96)
    .setSize(int(width*0.05), int(height*0.03))
    .setValue(0)
    .setCaptionLabel("")
    ;

  // Another on/off switch for square brushes.
  cp5.addButton("squareBrush")
    .setPosition(width*0.85, height*0.65)
    .setSize(int(width*0.05), (int(height*0.05)))
    .setValue(0)
    .setCaptionLabel("")
    ;

  // The slider for changing brush size/thickness
  cp5.addSlider("brushSize")
    .setPosition(int(width*0.11), int(height*0.02))
    .setWidth(int(width*0.08))
    .setHeight(int(height*0.05))
    .setRange(1, 30)                                                 // The thickness value of the brush
    .setValue(15)                                                    // Default value on app launch                         
    .setSliderMode(Slider.FIX)                                       // Use FLEXIBLE as an alternative slider style
    .setCaptionLabel("")
    .setBroadcast(false)
    ;

  // slider for Saturation of colours
  cp5.addSlider("saturationValue")
    .setPosition(int(width*0.81), int(height*0.02))
    .setWidth(int(width*0.08))
    .setHeight(int(height*0.05))
    .setRange(0, 255)                                                // The thickness value of the brush
    .setValue(100)                                                   // Default value on app launch                         
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
    .setSliderMode(Slider.FIX)                                        // Use FLEXIBLE as an alternative slider style
    .setCaptionLabel("")
    ;
    
  // slider for rows and columns of grid
  cp5.addSlider("gridLines")
    .setPosition(int(width*0.55), int(height*0.96))
    .setWidth(int(width*0.1))
    .setHeight(int(height*0.03))
    .setRange(2, 10)                                                  // The thickness value of the brush
    .setValue(3)                                                      // Default value on app launch                         
    .setSliderMode(Slider.FIX)                                        // Use FLEXIBLE as an alternative slider style
    .setCaptionLabel("")
    .setNumberOfTickMarks(9)
    ;

  // This is the bank of buttons for tool selection. (keyboard shortcuts still work)  
  cp5.addButton("brushPicked").setBroadcast(false).setPosition(width*0.51, height*0.025).setSize(int(width*0.03), (int(height*0.05))).setCaptionLabel("").setBroadcast(true);
  cp5.addButton("eraserPicked").setBroadcast(false).setPosition(width*0.56, height*0.025).setSize(int(width*0.03), (int(height*0.05))).setCaptionLabel("").setBroadcast(true);
  cp5.addButton("linePicked").setBroadcast(false).setPosition(width*0.61, height*0.025).setSize(int(width*0.03), (int(height*0.05))).setCaptionLabel("").setBroadcast(true);
  cp5.addButton("canvasPicked").setBroadcast(false).setPosition(width*0.66, height*0.025).setSize(int(width*0.03), (int(height*0.05))).setCaptionLabel("").setBroadcast(true);
  cp5.addButton("clearCanvas").setBroadcast(false).setPosition(width*0.71, height*0.025).setSize(int(width*0.03), (int(height*0.05))).setCaptionLabel("").setBroadcast(true);
  cp5.addButton("selectPicked").setBroadcast(false).setPosition(width*0.46, height*0.025).setSize(int(width*0.03), (int(height*0.05))).setCaptionLabel("").setBroadcast(true);

  // The undo button
  cp5.addButton("queueUndo")
    .setBroadcast(false)
    .setPosition(width*0.85, height*0.55)
    .setSize(int(width*0.05), (int(height*0.05)))
    .setCaptionLabel("")
    .setBroadcast(true);
    
  // The save button!
  cp5.addButton("saveImage")
    .setBroadcast(false)
    .setPosition(width*0.85, height*0.75)
    .setSize(int(width*0.1), (int(height*0.05)))
    .setCaptionLabel("save Image")
    .setBroadcast(true);
  
  // The three layers I'm using for the drawing of everything in PaintUI
  GUI = createGraphics(width, height);
  drawLayer = createGraphics(width, height);
  cursorLayer = createGraphics(width, height);
  lineLayer = createGraphics(width, height);
  gridLayer = createGraphics(width, height);
  
  saveState();
}

void draw() {

  // Tries to make the UI panels match the current setting of light/dark
  currentBackground = lerpColor(currentBackground, targetBackground, 0.1);
  background(canvasColor);
  
  GUI.beginDraw();  
  drawLayer.beginDraw();
  gridLayer.beginDraw();
  cursorLayer.beginDraw();
  
  GUI.noStroke();

  /* 
   This method of UI drawing uses boxes overlaid onto the drawing layer to bound the canvas better.
   The UI is redrawn on top of the current drawing every frame, so there's no spill over at all.
   I found this better than using a simple background, then bounding the mouse rigorously every frame.
   This was is way less computationally difficult in the end, if a little inelegant.
   */
  GUI.fill(currentBackground);                                       //
  GUI.rect(0, 0, width, height*0.1);                                 // The top bar of the GUI
  GUI.rect(width*0.8, height*0.1, width, height);                    // The side bar on the right
  GUI.rect(0, height*0.95, width*0.8, height);                       // The final part of the GUI Frame

  //now that the base is redrawn, everything else can be put on top of it

  GUI.fill(currentBrushColor,128);                                       // Active tool indicator fill colour is the same as the brush
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
  
  // test for active bools
  if (darkActive || (keyPressed && key == 'd'))
    GUI.rect(0,height*0.95,width*0.14,height*0.5);
  if (gridActive || (keyPressed && key == 'g'))
    GUI.rect(width*0.3,height*0.95,width*0.14,height*0.5);
  if (isSquare || (keyPressed && key == 'r'))
    GUI.rect(width*0.8, height*0.625, width*0.2, height*0.1);
  if (keyPressed && key == 'x')
    GUI.rect(width*0.7, 0, width*0.05, height*0.1);
  if (keyPressed && key == 'z')
    GUI.rect(width*0.8, height*0.525, width*0.2, height*0.1);
  
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
  
  GUI.fill(currentBrushColor);                                       // sets preview to brushColor
  GUI.stroke(currentTextColor);

  // Checks to see if the brush is round or squared and displays preview of brush
if (isSquare == false) {
    GUI.ellipse(int(width*0.25), int(height*0.048-5), brushSize, brushSize);
  } else {
    GUI.rectMode(CENTER);
    GUI.rect(int(width*0.25), int(height*0.048-5), brushSize, brushSize);
  }

  GUI.fill(currentTextColor);                                        // sets text labels to correct contrasting colour
  GUI.stroke(currentTextColor);
  GUI.textAlign(LEFT, CENTER);
  GUI.text("Dark Mode", width*0.08,height*0.9725);            // The actual drawing of all the labels
  GUI.text("Enable Grid", width*0.38,height*0.9725);
  GUI.text("Grid Lines", width*0.5,height*0.9725);
  GUI.text("Undo Action", (width*0.91), (height*0.575));
  GUI.text("Retro Brush", (width*0.91), (height*0.675));             // 
  GUI.textAlign(CENTER, CENTER);
  GUI.text("Select", width*0.475, height*0.085);
  GUI.text("Brush", width*0.525, height*0.085);
  GUI.text("Eraser", width*0.575, height*0.085);
  GUI.text("Line", width*0.625, height*0.085);
  GUI.text("Canvas", width*0.675, height*0.085);
  GUI.text("Clear", width*0.725, height*0.085);
  GUI.text("D", width*0.014, height*0.9725);
  GUI.text("G", width*0.314, height*0.9725);
  GUI.text("S", width*0.475, height*0.013);
  GUI.text("B", width*0.525, height*0.013);
  GUI.text("E", width*0.575, height*0.013);
  GUI.text("L", width*0.625, height*0.013);
  GUI.text("C", width*0.675, height*0.013);
  GUI.text("X", width*0.725, height*0.013);
  GUI.text("Z", width*0.84, height*0.575);
  GUI.text("R", width*0.84, height*0.675);
  GUI.text("Saturation", width*0.85, height*0.08);
  GUI.text("Brightness", width*0.95, height*0.08);
  if (toolNumber == 2) {
    GUI.text("Eraser Size", (width*0.15), (height*0.08));
  } else if (toolNumber == 3) {
    GUI.text("Line Thickness", (width*0.15), (height*0.08));
  } else {
    GUI.text("Brush Size", (width*0.15), (height*0.08));
  }

  GUI.text(brushSize, (width * 0.25), (height*0.052)+(brushSize/2)); // Shows the value of the current brush size

  GUI.textAlign(LEFT, CENTER);
  GUI.text("Selected Tool", (width*0.01), (height*0.03));            // "Selected Tool:"
  GUI.text(getToolName(toolNumber), (width*0.01), (height*0.06));    // Current tool label update
  GUI.fill(canvasColor);                                             // Set fill back to white for draw environment
  GUI.rectMode(CORNER);
  GUI.image(logoImage, width*0.82, height*0.87, width*0.16, height*0.06);
  
  // The end of the GUI layer commands

  drawLayer.strokeWeight(brushSize);
  if (toolNumber == 1) { 
    drawLayer.stroke(currentBrushColor);
  } else { 
    drawLayer.stroke(canvasColor);
  }
  
  attemptDraw();
  
  // The end of the drawLayer commands
  
  color fg,bg,ag;
  colorMode(HSB);
  
  if (hue(currentBrushColor) == 0 && saturation(currentBrushColor) == 0) {
    ag = color(currentTextColor);
    bg = color(hue(ag),saturation(ag),brightness(ag),128);
    fg = ag;
  } else {
    fg = color(currentBrushColor,128);
    bg = color(hue(fg),saturation(fg),brightness(fg)*0.5);
    ag = color(hue(fg),saturation(fg),brightness(fg)*1.5);
  }
  
  cp5.setColorForeground(fg);
  cp5.setColorBackground(bg);
  cp5.setColorActive(ag);
  cp5.setColorCaptionLabel(currentTextColor);
  cp5.setColorValueLabel(oppositeTextColor);
  // The end of the cp5 commands
  
  drawCursor();
  // The end of the cursorLayer commands
  
  if (saveStateQueued) {saveState();}                                // Check if any savestates or undos are queued
  if (undoQueued) {attemptUndo();}
  if (gridActive) {drawGrid();} else {gridLayer.clear();}
  
  GUI.endDraw();                                                     // End drawing of layers all at once
  drawLayer.endDraw();
  gridLayer.endDraw();
  cursorLayer.endDraw();
  
  // Draw the artwork next, with the Cursor on the very top.
  image(drawLayer, 0, 0);
  image(gridLayer,0,0);
  image(GUI, 0, 0);
  image(lineLayer, 0, 0);
  cp5.draw();
  image(cursorLayer, 0, 0);
  
}

void keyPressed() {

  switch (key) {
    case 's':
      selectPicked();
      break;
    case 'b':
      brushPicked();
      break;
    case 'e':
      eraserPicked();
      break;
    case 'l':
      linePicked();
      break;
    case 'c':
      canvasPicked();
      break;
    case 'x':
      clearCanvas();
      break;
    case 'z':
      queueUndo();
      break;
    case 'd':
      darkMode();
      break;
    case 'g':
      gridVisible();
      break;
    case 'r':
      squareBrush();
      break;
  }
}

void mousePressed() {

  if (toolNumber == 4 && (inBoundsCheck(true) || (mouseX > width*0.8 && mouseY > height*0.1 && mouseY < height*0.42))) {
    canvasColor = get(mouseX-1, mouseY-1);
    saveState();
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
  
  if (toolNumber > 0 && toolNumber < 5 && inBoundsCheck(true)) {
    saveState();
  }
  
}

void queueSaveState() {
 saveStateQueued = true; 
}

void saveState() {
  // Grabs the current screen and saves a PImage of it.
  currentState = get(0,int(height*0.1),int(width*0.8),int(height*0.85));
  currentState.save("data/saves/autosave.png");
  if (savedStates.size() > 10) {savedStates.remove(0);}
  savedStates.add(currentState);
  println(savedStates.size() + " items in the savestate array");
  saveStateQueued = false;
}

void queueUndo() {
  //clearCanvas();
  undoQueued = true;
  
}

void attemptUndo() {
  cursorLayer.clear();
  if (savedStates.size() > 1) {                                      //size() starts at 1, where arrays start at 0...
    drawLayer.image(savedStates.get(savedStates.size() - 2),0,height*0.1);
    savedStates.remove(savedStates.size()-1);
    println(savedStates.size() + " items in the savestate array");
  }
  undoQueued = false;
}

void saveImage() {
 
  int y = year();
  String mo = "";
  switch (month()) {
    case 1:
      mo = "January";
      break;
    case 2:
    mo = "February";
      break;
    case 3:
    mo = "March";
      break;
    case 4:
    mo = "April";
      break;
    case 5:
    mo = "May";
      break;
    case 6:
    mo = "June";
      break;
    case 7:
    mo = "July";
      break;
    case 8:
    mo = "August";
      break;
    case 9:
    mo = "September";
      break;
    case 10:
    mo = "October";
      break;
    case 11:
    mo = "November";
      break;
    case 12:
    mo = "December";
      break;
  }
  int d = day();
  int h = hour();
  int m = minute();
  int s = second();
  
  String timeCode = y + "_" + mo + "_" + d + "_" + h + "-" + m + "-" + s; 
  currentState = get(0,int(height*0.1),int(width*0.8),int(height*0.85));
  currentState.save("data/saves/"+timeCode+".png");
  
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

void drawGrid() {
 
  gridLayer.clear();
  int canvasWidth = int(width*0.8);
  int canvasHeight = int(height*0.85);
  
  for (int i = 1; i < 10; i++) {
    gridLayer.stroke(255-red(canvasColor),255-green(canvasColor),255-blue(canvasColor));
    gridLayer.line((i*canvasWidth/gridLines), 0, (i*canvasWidth/gridLines), height);
    gridLayer.line(0, (i*canvasHeight/gridLines)+height*0.1, width, (i*canvasHeight/gridLines)+height*0.1);
  }
  
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
      if (isSquare == false) {
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
      if (isSquare == false) {
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
      
      if (!isSquare) {
        drawLayer.strokeCap(ROUND);
      } else {
        drawLayer.strokeCap(PROJECT);
        println("bruh");
      }
      
      toX = isSquare == false ? pmouseX : mouseX;
      toY = isSquare == false ? pmouseY : mouseY;
      
      drawLayer.line(mouseX, mouseY, toX, toY);
      
    } else if (toolNumber == 3 && clickState == 1) {

      if (inBoundsCheck(true)) {
        toX = pmouseX;
        toY = pmouseY;
        lineLayer.clear();
        lineLayer.strokeWeight(brushSize);
        lineLayer.stroke(#ff00ff, 128);
        if (!isSquare) { 
          lineLayer.strokeCap(ROUND);
        } else {
          lineLayer.strokeCap(SQUARE);
        }
        lineLayer.line(fromX, fromY, toX, toY);
      }
    }
  }

  if (lineQueued) {
    if (!isSquare) { 
      drawLayer.strokeCap(ROUND);
    } else {
      drawLayer.strokeCap(SQUARE);
    }
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

void selectPicked() {
  toolNumber = 0;
}

void brushPicked() {
  toolNumber = 1;
  drawLayer.fill(currentBrushColor);
  drawLayer.rectMode(CENTER);
}

void eraserPicked() {
  toolNumber = 2;
  drawLayer.fill(canvasColor);
  drawLayer.stroke(255);
  drawLayer.rectMode(CENTER);
}

void linePicked() {
  toolNumber = 3;
}

void canvasPicked() {
  toolNumber = 4;
}

void clearCanvas() {
  drawLayer.clear();
  println("Canvas cleared!");
  canvasColor=#ffffff;
  saveState();
}

// handles whether or not the retro brush shall be used.
void squareBrush() {
  isSquare = !isSquare;
}

// The toggle function for the dark mode feature.
void darkMode() {
  
  darkActive = !darkActive;
  
  if (darkActive) {
    logoImage = loadImage("logol.png");
    targetBackground=#3c3c3c;
    currentTextColor=#d2d2d2;
    oppositeTextColor=#3c3c3c;
  } else {
    logoImage = loadImage("logod.png");
    targetBackground=#d2d2d2;
    currentTextColor=#3c3c3c;
    oppositeTextColor = #d2d2d2;
  }
}

void gridVisible() {
  gridActive = !gridActive;
}
