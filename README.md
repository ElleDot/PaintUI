# PaintUI
 An artwork package written in Processing 3. Draw images, import pictures or just scribble notes. It's up to you!
 
 >Compatible on 64-bit Windows (8, 8.1, 10) and MacOS (10.7+) installations

 With functionality for touchscreens and tablet pens (inc. other styluses)
 
 Navigate the UI with either your mouse, or the hotkeys shown on screen.
 
## Key binds and tools:
* (**S**) Select         - No drawing capability, 'safe' tool.
* (**D**) Draw           - Drag Mouse1 to draw
* (**E**) Eraser         - Drag Mouse1 to erase any existing paint.
* (**L**) Line           - Drag Mouse1 to start a line, then let go to end the line. See the preview in real time!
* (**C**) Canvas         - Select a colour with this tool to set the canvas to that colour.
* (**B**) Blur Filter    - A simple blur over the entire canvas. Stackable!
* (**P**) Posteriser     - Bottlenecks colours using the intensity value given.
* (**E**) Eroder         - Darkens the lighter areas of the canvas.
* (**I**) Illuminator    - Heightens the light areas of the canvas.

### Alternative Features:
* (**X**) Clear          - Wipes the entire canvas and sets it to white.
* (**V**) Invert         - Inverts the colours for every pixel on the canvas.
* (**Y**) Greyscaler     - Converts the canvas to black and white.
* (**Z**) Undo stack     - Undo up to 10 of your last actions.
 
### Toggleable Features:
* (**R**) Retro brush    - Toggle a square brush + older draw mode (not as smooth as regular draw mode)
* (**D**) Dark Mode      - Toggle a darker UI mode (on by default)
* (**G**) Grid           - Activates a grid overlay to help align any artwork. configurable up to 10x10.

* (**auto**) Autosave    - Every change to the scene triggers an autosave.

You can find the autosave file within the /data folder of PaintUI. It's saved as a PNG.

If you're using canvas filters, make sure to commit them using the big green button, or nothing will actually change.
This also triggers an autosave, and adds your scene to the cached undo stack.
