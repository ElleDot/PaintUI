import controlP5.*;
import javax.swing.*;

int toolNumber = 0;
int brushSize = 15;
int clickState = 0;
int saturationValue;
int brightnessValue;
int gridLines = 3;
int filterIntensity;
int fromX;
int fromY;
int toX;
int toY;
int cappedMouseX = 0;
int cappedMouseY = 0;

boolean lineQueued = false;
boolean imageQueued = false;
boolean undoQueued = false;
boolean saveStateQueued = false;
boolean filterQueued = false;
boolean filterMenu = true;
boolean invertQueued = false;
boolean greyscaleQueued = false;
boolean gridActive = false;
boolean darkActive = false;
boolean retroActive = false;

PGraphics canvasLayer;
PGraphics GUI;
PGraphics drawLayer;
PGraphics lineLayer;
PGraphics gridLayer;
PGraphics cursorLayer;

ArrayList<ArrayList<PImage>> savedStates = new ArrayList<ArrayList<PImage>>();
PImage logoImage;

color currentBackground;
color targetBackground;
color currentTextColor;
color canvasColor = #ffffff;
color currentDrawColor = #000000;
color oppositeTextColor;

String fileName = "";
PImage imageToLoad;
float aspectRatio;
int widthToUse;
int heightToUse;

int frameCounter;

ControlP5 cp5;
ControlP5 filters;

void setup() {
  
  // The height of the window has a huge impact on performance. Width isn't as important.
  // P2D gets an extra boost in performance, but cannot work with java message boxes.
  
  //size(800, 565,P2D);                                                  // 640x480  - 120fps - 4:3  - 0.31MP  - perfect speed, too small
  //size(1000,706,P2D);                                                  // 800x600  - ~87fps - 4:3  - 0.48MP - perfect speed, too small
  size(1200,636);                                                        // 960x540  - ~80fps - 16:9 - 0.52MP - perfect speed, too short
  //size(1280,678,P2D);                                                  // 1024x576 - ~70fps - 16:9 - 0.59MP - great speed, decent size
  //size(1280,800,P2D);                                                  // 1024x680 - ~60fps - orig - 0.70MP - Original res :) slow though :(
  //size(1280,903,P2D);                                                  // 1024x768 - ~55fps - 4:3  - 0.79MP - 
  //size(1600,848,P2D);                                                  // 1280x720 - ~40fps - 16:9 - 0.92MP - too slow, great size
  noCursor();                                                        // Setting noCursor due to custom ones used by PaintUI
  //noSmooth();
  cp5 = new ControlP5(this);
  filters = new ControlP5(this);
  cp5.setAutoDraw(false);
  filters.setAutoDraw(false);
  frameRate(250);                                                  // Used to check how fast things actually can run
  
  frameCounter = millis();

  // Sliders for brush size, saturation and brightness of colour picker.
  cp5.addSlider("brushSize").setPosition(int(width*0.11), int(height*0.02)).setWidth(int(width*0.08)).setHeight(int(height*0.05)).setRange(1, 25).setValue(10).setSliderMode(Slider.FIX).setCaptionLabel("").setBroadcast(false);
  cp5.addSlider("saturationValue").setPosition(int(width*0.81), int(height*0.02)).setWidth(int(width*0.08)).setHeight(int(height*0.05)).setRange(0, 256).setValue(100).setSliderMode(Slider.FIX).setCaptionLabel("");
  cp5.addSlider("brightnessValue").setPosition(int(width*0.91), int(height*0.02)).setWidth(int(width*0.08)).setHeight(int(height*0.05)).setRange(0, 256).setValue(256).setSliderMode(Slider.FIX).setCaptionLabel("");

  // This is the bank of buttons for tool selection. (keyboard shortcuts still work)  
  cp5.addButton("buttonTwo").setBroadcast(false).setPosition(width*0.51, height*0.025).setSize(int(width*0.03), (int(height*0.05))).setCaptionLabel("").setBroadcast(true);
  cp5.addButton("buttonThree").setBroadcast(false).setPosition(width*0.56, height*0.025).setSize(int(width*0.03), (int(height*0.05))).setCaptionLabel("").setBroadcast(true);
  cp5.addButton("buttonFour").setBroadcast(false).setPosition(width*0.61, height*0.025).setSize(int(width*0.03), (int(height*0.05))).setCaptionLabel("").setBroadcast(true);
  cp5.addButton("buttonFive").setBroadcast(false).setPosition(width*0.66, height*0.025).setSize(int(width*0.03), (int(height*0.05))).setCaptionLabel("").setBroadcast(true);
  cp5.addButton("buttonOne").setBroadcast(false).setPosition(width*0.46, height*0.025).setSize(int(width*0.03), (int(height*0.05))).setCaptionLabel("").setBroadcast(true);
  
  // Button objects for right hand panel
  cp5.addButton("greyscaleCanvas").setBroadcast(false).setPosition(width*0.91, height*0.54).setSize(int(width*0.05), (int(height*0.05))).setCaptionLabel("Grey").setBroadcast(true);
  cp5.addButton("invertCanvas").setBroadcast(false).setPosition(width*0.91, height*0.62).setSize(int(width*0.05), (int(height*0.05))).setCaptionLabel("Invert").setBroadcast(true);
  cp5.addButton("queueUndo").setBroadcast(false).setPosition(width*0.84, height*0.54).setSize(int(width*0.05), (int(height*0.05))).setCaptionLabel("Undo").setBroadcast(true);
  cp5.addButton("clearCanvas").setBroadcast(false).setPosition(width*0.84, height*0.62).setSize(int(width*0.05), (int(height*0.05))).setCaptionLabel("Clear All").setBroadcast(true);
  cp5.addButton("loadFile").setBroadcast(false).setPosition(width*0.85, height*0.7).setSize(int(width*0.1), (int(height*0.05))).setCaptionLabel("Load Image").setBroadcast(true);
  cp5.addButton("saveImage").setBroadcast(false).setPosition(width*0.85, height*0.78).setSize(int(width*0.1), (int(height*0.05))).setCaptionLabel("save Image").setBroadcast(true);
  
  // Bottom Bar buttons/Sliders for dark mode, retro mode and grid
  cp5.addButton("darkMode").setPosition(width*0.025, height*0.96).setSize(int(width*0.05), int(height*0.03)).setValue(0).setCaptionLabel("");
  cp5.addButton("retroMode").setBroadcast(false).setPosition(width*0.728, height*0.96).setSize(int(width*0.05), int(height*0.03)).setCaptionLabel("").setBroadcast(true);
  cp5.addButton("gridVisible").setBroadcast(false).setPosition(width*0.325, height*0.96).setSize(int(width*0.05), int(height*0.03)).setCaptionLabel("").setBroadcast(true);
  cp5.addSlider("gridLines").setPosition(int(width*0.5), int(height*0.96)).setWidth(int(width*0.1)).setHeight(int(height*0.03)).setRange(2, 10).setValue(3).setSliderMode(Slider.FIX).setCaptionLabel("").setNumberOfTickMarks(9);
  
  // Some CP5 elements for the filter systems
  filters.addSlider("filterIntensity").setPosition(int(width*0.86), int(height*0.175)).setWidth(int(width*0.08)).setHeight(int(height*0.05)).setRange(0, 100).setValue(50).setSliderMode(Slider.FIX).setCaptionLabel("");
  filters.addButton("commitFilter").setBroadcast(false).setPosition(width*0.85, height*0.35).setSize(int(width*0.1), (int(height*0.05))).setValue(0).setCaptionLabel("Commit Filter").setColorBackground(color(0,128,0)).setBroadcast(true);
  cp5.addButton("toggleMenu").setPosition(int(width*0.03), height*0.0325).setSize(int(width*0.04), int(height*0.03)).setValue(0).setCaptionLabel("");
  
  // The three layers I'm using for the drawing of everything in PaintUI
  canvasLayer = createGraphics(int(width*0.8), int(height*0.95));
  GUI = createGraphics(width, height);
  drawLayer = createGraphics(int(width*0.8), int(height*0.95));
  cursorLayer = createGraphics(width, height);
  lineLayer = createGraphics(int(width*0.8), int(height*0.95));
  gridLayer = createGraphics(int(width*0.8), int(height*0.95));
  
  queueSaveState();
  
}

void draw() {
  
  startFrameCount();

  // Tries to make the UI panels match the current setting of light/dark
  if (targetBackground != currentBackground) {
    for (int i = 0; i < 10; i++) {
      currentBackground = lerpColor(currentBackground, targetBackground, i*0.01);
    }
  }
  
  canvasLayer.beginDraw();
  GUI.beginDraw();  
  drawLayer.beginDraw();
  gridLayer.beginDraw();
  lineLayer.beginDraw();
  cursorLayer.beginDraw();
  
  canvasLayer.background(canvasColor);
  
  drawGUI();
  
  attemptDraw();
  
  if (filterQueued) filterDraw();
  
  if (imageQueued) attemptImage();
  
  color fg,bg,ag;
  colorMode(HSB);
  
  if (hue(currentDrawColor) == 0 || saturation(currentDrawColor) == 0) {
    ag = color(currentTextColor);
    bg = color(hue(ag),saturation(ag),brightness(ag),128);
    fg = ag;
  } else {
    fg = color(currentDrawColor,128);
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
  
  if (undoQueued) {attemptUndo();}
  if (gridActive) {drawGrid();} else {gridLayer.clear();}
  
  canvasLayer.endDraw();
  GUI.endDraw();                                                                    // End drawing of layers all at once
  drawLayer.endDraw();
  gridLayer.endDraw();
  lineLayer.endDraw();
  cursorLayer.endDraw();
  
  // Draw the artwork next, with the Cursor on the very top.
  image(canvasLayer,0,0);
  image(drawLayer, 0, 0);
  if (gridActive) {image(gridLayer,0,0);}
  image(GUI, 0, 0);
  if(clickState == 1) { image(lineLayer, 0, 0);}
  cp5.draw();
  if (filterMenu) {filters.draw();}
  image(cursorLayer, 0, 0);
  
  if (saveStateQueued) {saveState();}                                               // Check if any savestates or undos are queued
  
}

void drawGUI() {

  GUI.noStroke();

  /* 
   This method of UI drawing uses boxes overlaid onto the drawing layer to bound the canvas better.
   The UI is redrawn on top of the current drawing every frame, so there's no spill over at all.
   I found this better than using a simple background, then bounding the mouse rigorously every frame.
   This was is way less computationally difficult in the end, if a little inelegant.
   */
  GUI.fill(currentBackground);
  GUI.rect(0, 0, width, height*0.1);                                                // The top bar of the GUI
  GUI.rect(width*0.8, height*0.1, width, height);                                   // The side bar on the right
  GUI.rect(0, height*0.95, width*0.8, height);                                      // The final part of the GUI Frame

  //now that the base is redrawn, everything else can be put on top of it

  GUI.fill(currentDrawColor,128);                                                   // Active tool indicator fill colour is the same as the brush
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
    case 5:
      GUI.rect(width*0.5, 0, width*0.05, height*0.1);
      break;
    case 6:
      GUI.rect(width*0.55, 0, width*0.05, height*0.1);
      break;
    case 7:
      GUI.rect(width*0.6, 0, width*0.05, height*0.1);
      break;
    case 8:
      GUI.rect(width*0.65, 0, width*0.05, height*0.1);
      break;
  }
  
  // test for active bools
  
  
  if (darkActive)
    GUI.rect(0,height*0.95,width*0.14,height*0.5);
  if (gridActive)
    GUI.rect(width*0.3,height*0.95,width*0.14,height*0.5);
  if (retroActive)
    GUI.rect(width*0.66, height*0.95, width*0.14, height*0.05);
  if (keyPressed && key == 'x')
    GUI.rect(width*0.8, height*0.605, width*0.1, height*0.08);
  if (keyPressed && key == 'z')
    GUI.rect(width*0.8, height*0.525, width*0.1, height*0.08);
  if (keyPressed && key == 'y')
    GUI.rect(width*0.9, height*0.525, width*0.1, height*0.08);
  if (keyPressed && key == 'v')
    GUI.rect(width*0.9, height*0.605, width*0.1, height*0.08);
    
  if (filterMenu) {
    GUI.fill(currentTextColor);
    GUI.rect(width*0.8, height*0.1, width*0.2, width*0.2);
    GUI.textAlign(CENTER,CENTER);
    GUI.fill(currentBackground);
    GUI.text("Filter Intensity", width*0.9,height*0.15);
  } else {
    int boxWidth = int(width*0.025);                                   // Define the standard box width, fitting 8 into the side-panel.
    for (int i = 0; i < 8; i++) {                                      // Loop for generating shades of black, grey and white
      for (int i2 = 0; i2 < 4; i2++) {
        GUI.fill((i+1)*(i2+1)*8-1);
        GUI.rect(width*0.8+(boxWidth)*i, (height*0.1)+(boxWidth*i2), width*0.025, width*0.025);
      }
    }
    GUI.colorMode(HSB, 256);                                           // Change to HSB from RGB for the colour picker
    for (int i = 0; i < 8; i++) {                                      // Loop for generating colours
      for (int i2 = 0; i2 < 4; i2++) {
        GUI.fill(i*8 + (i2*64), saturationValue, brightnessValue);
        GUI.rect(width*0.8+(boxWidth)*i, (height*0.1+boxWidth*4)+(boxWidth*i2), width*0.025, width*0.025);
      }
    }
  }

  modifierCheck();
  
  GUI.fill(currentDrawColor);                                       // sets preview to brushColor
  GUI.stroke(currentTextColor);

  // Checks to see if the brush is round or squared and displays preview of brush
if (retroActive == false) {
    GUI.ellipse(int(width*0.25), int(height*0.048-5), brushSize, brushSize);
  } else {
    GUI.rectMode(CENTER);
    GUI.rect(int(width*0.25), int(height*0.048-5), brushSize, brushSize);
  }
  
  cappedMouseX = mouseX;
  cappedMouseY = mouseY - int(height*0.1);
  
  if (mouseX > width*0.8) cappedMouseX = int(width*0.8);
  if (mouseY > height*0.95) cappedMouseY = int(height*0.85);
  if (cappedMouseY < 0) cappedMouseY = 0;
  
  if (!inBoundsCheck(true)) { GUI.fill(color(0,144,255)); } else {GUI.fill(color(100,100,255));}
  GUI.textAlign(RIGHT,CENTER);
  GUI.text("X: " + cappedMouseX, width*0.99, height*0.95);
  GUI.text("Y: " + cappedMouseY ,width*0.99, height*0.9725);
  GUI.fill(currentTextColor);
  GUI.text("Lines", width*0.49,height*0.9725);
  GUI.text("R", (width*0.792), (height*0.9725));
  GUI.text("Retro Brush", (width*0.722), (height*0.9725));
  
  GUI.textAlign(LEFT, CENTER);
  GUI.text("ElleDot 2020", width*0.818,height*0.95);
  GUI.text("v1.2.1 - 28/10/20", width*0.818,height*0.9725);
  GUI.text("Dark Mode", width*0.08,height*0.9725);                   // The actual drawing of all the labels
  GUI.text("Enable Grid", width*0.38,height*0.9725);
  
  GUI.textAlign(CENTER, CENTER);
  GUI.text("Toolbar",width*0.05,height*0.015);
  GUI.text("Current Colour",width*0.35,height*0.04);
  GUI.text("#"+hex(currentDrawColor).substring(2),width*0.35,height*0.06);
  
  if (!filterMenu) {
    GUI.fill(color(100,150,255));
    GUI.text("DRAW",width*0.05,height*0.075);
    GUI.fill(currentTextColor);
    GUI.text("Draw", width*0.525, height*0.085);
    GUI.text("Eraser", width*0.575, height*0.085);
    GUI.text("Line", width*0.625, height*0.085);
    GUI.text("Canvas", width*0.675, height*0.085);
    GUI.text("D", width*0.525, height*0.013);
    GUI.text("E", width*0.575, height*0.013);
    GUI.text("L", width*0.625, height*0.013);
    GUI.text("C", width*0.675, height*0.013);
  } else {
    GUI.fill(color(0,150,255));
    GUI.text("FILTER",width*0.05,height*0.075);
    GUI.fill(currentTextColor);
    GUI.text("Blur", width*0.525, height*0.085);
    GUI.text("Posterise", width*0.575, height*0.085);
    GUI.text("Dim", width*0.625, height*0.085);
    GUI.text("Illuminate", width*0.675, height*0.085);
    GUI.text("B", width*0.525, height*0.013);
    GUI.text("P", width*0.575, height*0.013);
    GUI.text("M", width*0.625, height*0.013);
    GUI.text("I", width*0.675, height*0.013);
  }
  GUI.text("Select", width*0.475, height*0.085);
  GUI.text("S", width*0.475, height*0.013);
  GUI.text("K", width*0.014, height*0.9725);
  GUI.text("G", width*0.314, height*0.9725);
  GUI.text("Z", width*0.825, height*0.5625);
  GUI.text("X", width*0.825, height*0.6425);
  GUI.text("Y", width*0.975,height*0.5625);
  GUI.text("V", width*0.975, height*0.6425);
  if (savedStates.size()-1 == 0) {
    GUI.text("No steps back available.",width*0.905, height*0.51);
  } else if (savedStates.size()-1 == 1) {
    GUI.text(savedStates.size()-1 + " step back available.",width*0.905, height*0.51);
  } else {
    GUI.text(savedStates.size()-1 + " steps back available.",width*0.905, height*0.51);
  }
  
  GUI.text("Saturation", width*0.85, height*0.08);
  GUI.text("Brightness", width*0.95, height*0.08);
  if (toolNumber == 2) {
    GUI.text("Eraser Size", (width*0.15), (height*0.08));
  } else if (toolNumber == 3) {
    GUI.text("Line Thickness", (width*0.15), (height*0.08));
  } else {
    GUI.text("Brush Size", (width*0.15), (height*0.08));
  }

  GUI.text(brushSize, (width * 0.25), (height*0.052)+(brushSize*0.5)); // Shows the value of the current brush size

  GUI.textAlign(LEFT, CENTER);
  //GUI.fill(canvasColor);                                             // Set fill back to white for draw environment
  GUI.rectMode(CORNER);
  GUI.image(logoImage, width*0.82, height*0.87, width*0.16, height*0.06);
  
  GUI.fill(currentDrawColor);
  GUI.noStroke();
  GUI.rect(width*0.3,0,width*0.1,height*0.02,0,0,10,10);
  GUI.rect(width*0.3,height*0.08,width*0.1,height*0.02,10,10,0,0);

}

void filterDraw() {
  
  PImage img = get(0,int(height*0.1),int(width*0.8),int(height*0.95));
  
  switch (toolNumber) {
   
    case 5:
      drawLayer.image(img,0,height*0.1);
      drawLayer.filter(BLUR,filterIntensity*0.1);
      break;
    case 6:
      drawLayer.image(img,0,height*0.1);
      drawLayer.filter(POSTERIZE,12-(filterIntensity*0.1));
      break;
    case 7:
      drawLayer.image(img,0,height*0.1);
      drawLayer.filter(ERODE);
      break;
    case 8:
      drawLayer.image(img,0,height*0.1);
      drawLayer.filter(DILATE);
      break;
    
  }
  
  if (invertQueued) {
    drawLayer.image(img,0,height*0.1);
    drawLayer.filter(INVERT);
    invertQueued = false;
  }
  if (greyscaleQueued) {
    drawLayer.image(img,0,height*0.1);
    drawLayer.filter(GRAY);
    greyscaleQueued = false;
  }
    
  queueSaveState();
  
  filterQueued = false;
}

void keyPressed() {

  switch (key) {
      
    case 's':
      buttonOne();                                                                  // Select tool
      break;
    case 'b':
      filterMenu = true;
      buttonTwo();
      break;
    case 'd':
      filterMenu = false;
      buttonTwo();
      break;
    case 'p':
      filterMenu = true;
      buttonThree();
      break;
    case 'e':
      filterMenu = false;
      buttonThree();
      break;
    case 'l':
      filterMenu = false;
      buttonFour();
      break;
    case 'm':
      filterMenu = true;
      buttonFour();
      break;
    case 'c':
      filterMenu = false;
      buttonFive();
      break;
    case 'i':
      filterMenu = true;
      buttonFive();
      break;
    case 'x':
      clearCanvas();
      break;
    case 'k':
      darkMode();
      break;
    case 'z':
      queueUndo();
      break;
    case 'g':
      gridVisible();
      break;
    case 'r':
      retroMode();
      break;
    case 'v':
      invertCanvas();
      break;
    case 'y':
      greyscaleCanvas();
      break;
  }
}

void buttonOne() {
  toolNumber = 0;
}

void buttonTwo() {
  if (!filterMenu) { drawPicked(); } else {blurPicked();}
}

void buttonThree() {
  if (!filterMenu) { eraserPicked(); } else {posterisePicked();}
}

void buttonFour() {
  if (!filterMenu) { linePicked(); } else {erodeCanvas();}
}

void buttonFive() {
  if (!filterMenu) { canvasPicked(); } else {illuminateCanvas();}
}

void drawPicked() {
  toolNumber = 1;
  drawLayer.fill(currentDrawColor);
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

void blurPicked() {
  toolNumber = 5;
}
void posterisePicked() {
  toolNumber = 6;
}
void erodeCanvas() {
  toolNumber = 7;
}

void illuminateCanvas() {
  toolNumber = 8;
}

void invertCanvas() {
  filterQueued = true;
  invertQueued = true;
}

void greyscaleCanvas() {
  greyscaleQueued = true;
  filterQueued = true;
}

void mousePressed() {
  
  if (toolNumber == 4 && (inBoundsCheck(true) || (mouseX > width*0.8 && mouseY > height*0.1 && mouseY < height*0.42))) {
    canvasColor = get(mouseX-1, mouseY-1);
    queueSaveState();
  } else if (mouseX > width*0.8 && mouseY > height*0.1 && mouseY < height*0.1+(width*0.2) && !filterMenu) {
    currentDrawColor = GUI.get(mouseX-1, mouseY-1); 
    drawLayer.fill(currentDrawColor);
    drawLayer.stroke(currentDrawColor);
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
    queueSaveState();
  }
  
}

void attemptImage() {
  
  fitNewImage();  
  drawLayer.imageMode(CENTER);
  drawLayer.image(imageToLoad,width*0.4,height*0.5+(height*0.025),widthToUse,heightToUse);
  drawLayer.imageMode(CORNER);
  imageQueued = false;
}

void queueSaveState() {
 saveStateQueued = true; 
}

void saveState() {
  // Grabs the current screen and saves a PImage of it.
  PImage autosave;
  autosave = get(0,int(height*0.1),int(width*0.8),int(height*0.85));
  autosave.save("data/saves/autosave.png");
  
  ArrayList<PImage> currentScene = new ArrayList<PImage>();
  PImage currentCanvas = canvasLayer.get(0,int(height*0.1),int(width*0.8),int(height*0.85));
  PImage currentDrawLayer = drawLayer.get(0,int(height*0.1),int(width*0.8),int(height*0.85));
  currentScene.add(currentCanvas);
  currentScene.add(currentDrawLayer);
  
  if (savedStates.size() > 10) {savedStates.remove(0);}
  savedStates.add(currentScene);
  saveStateQueued = false;
}

void queueUndo() {
  undoQueued = true;
}

void attemptUndo() {
  if (savedStates.size() > 1) {                                                     //size() starts at 1, where arrays start at 0...
    canvasLayer.clear();                                                            // Start by nuking the canvas and draw layers
    drawLayer.clear();
    
    ArrayList<PImage> loadedScene = savedStates.get(savedStates.size()-2);          // load Array of layers for the last scene
    canvasLayer.image(loadedScene.get(0),0,height*0.1);                             // set the canvas to the previous savestate
    canvasColor = canvasLayer.get(1,int(height*0.1+1));                             // set the canvas colour too, so it doesn't get reset next frame
    drawLayer.image(loadedScene.get(1),0,height*0.1);                               // redraw last savestate's drawlayer too
    
    savedStates.remove(savedStates.size()-1);                                       // Remove the now current state from the stack
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
  PImage imageToSave = get(0,int(height*0.1),int(width*0.8),int(height*0.85));
  imageToSave.save("data/saves/"+timeCode+".png");
  messageBox("Image successfully saved as\n" + timeCode + ".png","Save Complete");
  
}

void messageBox(String message, String title){
  // Display a message to the user, explaining something which may not be totally obvious
  javax.swing.JOptionPane.showMessageDialog (null, message, title, javax.swing.JOptionPane.INFORMATION_MESSAGE);
}

void errorBox(String message, String title) {
  // Show a warning, which isn't fatal for the application's processes.
  javax.swing.JOptionPane.showMessageDialog (null, message, title, javax.swing.JOptionPane.WARNING_MESSAGE);
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
  cursorLayer.fill(255);
  
  // Changing the fill colour of the cursor to highlight what tool is selected.
  switch (toolNumber) {

    case 1:
      //The brush tool
      if (inBoundsCheck(true)) {
        cursorLayer.noFill();
        if (retroActive == false) {
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
        if (retroActive == false) {
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
  
  drawLayer.strokeWeight(brushSize);
  if (toolNumber == 1) { 
    drawLayer.stroke(currentDrawColor);
  } else { 
    drawLayer.stroke(canvasColor);
  }

  if (inBoundsCheck(true) && mousePressed == true) {

    if (toolNumber == 1 || toolNumber == 2) {
      
      if (!retroActive) {
        drawLayer.strokeCap(ROUND);
      } else {
        drawLayer.strokeCap(PROJECT);
      }
      
      toX = retroActive == false ? pmouseX : mouseX;
      toY = retroActive == false ? pmouseY : mouseY;
      
      drawLayer.line(mouseX, mouseY, toX, toY);
      
    } else if (toolNumber == 3 && clickState == 1) {

      if (inBoundsCheck(true)) {
        toX = pmouseX;
        toY = pmouseY;
        lineLayer.clear();
        lineLayer.strokeWeight(brushSize);
        lineLayer.stroke(#ff00ff, 128);
        if (!retroActive) { 
          lineLayer.strokeCap(ROUND);
        } else {
          lineLayer.strokeCap(SQUARE);
        }
        lineLayer.line(fromX, fromY, toX, toY);
      }
    }
  }

  if (lineQueued) {
    if (!retroActive) { 
      drawLayer.strokeCap(ROUND);
    } else {
      drawLayer.strokeCap(SQUARE);
    }
    drawLayer.strokeWeight(brushSize);
    drawLayer.stroke(currentDrawColor);
    drawLayer.line(fromX, fromY, toX, toY); 
    lineQueued = false;
    lineLayer.clear();
  }
  
}

void modifierCheck() {

  if (keyPressed && key == CODED && keyCode == SHIFT) {
    brushSize = int(cp5.getController("brushSize").getValue())*2;
    GUI.fill(currentTextColor);
    GUI.text("x2", width*0.27+brushSize*0.25, height*0.05-5);
  } else {
    GUI.fill(currentBackground);
    GUI.text("x2", width*0.27+brushSize*0.25, height*0.05-5);
    brushSize = int(cp5.getController("brushSize").getValue());
  }
  return;
  
}

// Loads a file given the input from the message box, then passes it through to the content fitter
void loadFile() {
  
  String rawInput = JOptionPane.showInputDialog(
    frame,
    "Please enter the file name to import onto the canvas.", 
    "Import Image", 
    JOptionPane.INFORMATION_MESSAGE
    );
    
    fileName = rawInput != null ? rawInput : "";
  
  // do check for special extensions here
  String[] possibleExtensions = {".jpg",".jpeg",".png",".gif",".bmp"};
  
  if (fileName.contains(".")) {
    
    // Given filename probably has an extension in it, try loading it.
    imageToLoad = loadImage(fileName);
    
    if (imageToLoad != null) {
      queueSaveState();
      messageBox("Image " + fileName + " pasted onto the canvas!","Success");
      imageQueued = true;
    }
    
  } else {
    
    // Given doesn't have an extension. Try common ones
    for (int i = 0; i < possibleExtensions.length; i++) {
      
      String fullFileName = fileName + possibleExtensions[i];
      imageToLoad = loadImage(fullFileName);
        
      if (imageToLoad != null) {
        queueSaveState();
        messageBox("Image " + fileName + " pasted onto the canvas!","Success");
        imageQueued = true;
        break;
      }
    }   
  }
  
  if (imageToLoad == null) errorBox("File not found.","Error");
  
}

// Uses image height and width, gets a ratio, then fits it nicely to the canvas
void fitNewImage() {
  
  // Properly fit the loaded image to the frame.
  // Gets the ratio of width/height
  aspectRatio = float(imageToLoad.width)/float(imageToLoad.height);
  
  // Caps the width if it's over the window width
  // Then keeps the height within the aspect ratio
  if (imageToLoad.width > width*0.8) {
    widthToUse = int(width*0.8);
    
  } else {
    widthToUse = imageToLoad.width;
  }
  heightToUse = int(widthToUse/aspectRatio);
  
  // Caps the height, then the width afterwards
  // Leaving a properly fitted image.
  if (imageToLoad.height > height*0.85) {
    heightToUse = int(height*0.85);
  } else {
    heightToUse = imageToLoad.height;
  }
  widthToUse = int(heightToUse*aspectRatio);
  
}

//Whenever ANY GUI event is called, this fires
public void controlEvent(ControlEvent theEvent) {}

// Clears the canvas, then queues a savestate to prevent undo from going wrong
void clearCanvas() {
  drawLayer.clear();
  //canvasColor=#ffffff;
  queueSaveState();
}

// erodes the boolean for the retro brush mode
void retroMode() {
  retroActive = !retroActive;
}

// The toggle function for the dark mode feature, handling UI text colour as well
void darkMode() {
  darkActive = !darkActive;
  if (darkActive) {
    logoImage = loadImage("logol.png");
    targetBackground = #3c3c3c;
    currentTextColor = #d2d2d2;
    oppositeTextColor = #3c3c3c;
  } else {
    logoImage = loadImage("logod.png");
    targetBackground = #d2d2d2;
    currentTextColor = #3c3c3c;
    oppositeTextColor = #d2d2d2;
  }
}

void gridVisible() {
  gridActive = !gridActive;
}

void startFrameCount() {
  int timeNow = millis();
  if (timeNow - frameCounter > 1000) {
    surface.setTitle("PaintUI - " + int(frameRate) + " fps");
    frameCounter = millis();
  }
  return;
}

void toggleMenu() {
  filterMenu = !filterMenu;
  toolNumber = 0;
}

void commitFilter() {

  filterQueued = true;
  println("Filter Queued!");
  
}
