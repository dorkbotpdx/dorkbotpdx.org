/**

<h1>DorkbotPDX invites you to "Processing Fundamentals". <br>A free workshop at Flux</h1>

<p>
<a href="http://dorkbotpdx.org">DorkbotPDX</a> is happy to offer a 4-hour intro to Processing --
a graphics programming environment.  Students will learn the basics of Processing.  No prior programming experience required!
<p>
When:  Sunday, April 27. 1-5pm<br>
Where:  <a href="http://fluxlab.io/welcome-to-flux/">Flux Hackerspace</a> (412 NW Couch #222, Portland, OR)<br>
Cost: FREE!!!<br>
Bring: A laptop with Processing 2.0 installed (if you can)<br>

 */

// Sorry about the state of this code, they are called sketches for a reason. ;) -- (bzzt@knowhere.net)

ArrayList<linestate> lines = new ArrayList<linestate>();
PGraphics textGraphics;

void setup() {
  size(750, 533);

  textGraphics = createGraphics(width, height);
  textGraphics.beginDraw();
  textGraphics.background(189,183,107);  
  drawType(width * 0.99);

  textGraphics.endDraw();

  image(textGraphics, 0, 0);
}

color[] tempColor;
int amt = 12;

void dilateRows(int startY, int endY)
{
  for (int dy = startY; dy < endY - amt; dy++)
  {
    for (int dx = amt; dx < width - amt; dx++)
    {
      color orig_color = textGraphics.pixels[dy*width+dx];
      float redAmt = red(orig_color);
      for (int sy = -amt/2; sy < amt/2; sy++)
      {
        for (int sx = -amt/2; sx < amt/2; sx++)
        {
          float searchAmt = red(textGraphics.pixels[(dy+sy)*width+(dx+sx)]);
          if (searchAmt < redAmt)
            redAmt = searchAmt;
        }
      }
      if (redAmt == 0)
      {
        tempColor[dy*width+dx] = color(0);
      } else {
        tempColor[dy*width+dx] = orig_color;
      }
    }
  }  
}

void dilateText()
{
  tempColor = new color[width*height];  
  int offset = 0;
  for (int dy = 0; dy < height; dy++)
  {
    for (int dx = 0; dx < width; dx++)
    {
      tempColor[offset++] = color(255,255,255);
    }
  }

  dilateRows(amt, 175);
  dilateRows(375, 450);
  
  for (int dy = amt; dy < height - amt; dy++)
  {
    for (int dx = amt; dx < width - amt; dx++)
    {
      textGraphics.pixels[dy*width+dx] = tempColor[dy*width+dx];
    }
  }
  textGraphics.updatePixels();
}

// Delay this work until the first frame has rendered, allows text to appear while we
// do our dilation
void setup2()
{
  textGraphics.loadPixels();
  dilateText();
  textGraphics.updatePixels();

  colorMode(HSB, 255);

  for (int i = 0; i < 100; i++)
  {
    linestate ls = new linestate();
    ls.reset();
    stroke(128, 0, 0, 255);
    point(ls.xPos, ls.yPos);
    lines.add(ls);
  }
}  

boolean hasSetup = false;

void draw() {
  if (!hasSetup)
  {
    hasSetup = true;
    setup2();  
  }
  
  //textGraphics.loadPixels();
  
  for (int i = 0; i < lines.size(); i++)
  {
    linestate ls = lines.get(i);
    for (int steps = 0; steps < ls.steps; steps++)
    {
      if ((ls.xPos >= 0) && (ls.xPos < width) && (ls.yPos >= 0) && (ls.yPos < height))
      {
        //if (((textGraphics.pixels[ls.yPos*width+ls.xPos] >> 16) & 0xFF) != 0)
        //if (true)
        int yPos = (int) ls.yPos;
        if (red(textGraphics.pixels[yPos * width + ls.xPos]) != 0)
        {
          ls.xPos += 1;
          ls.yPos += random(4) - 2;
          stroke(ls.c);
          point(ls.xPos, ls.yPos);

          //ellipse(ls.xPos, ls.yPos, random(1)+1, random(1)+1);
        }
        else {
          ls.reset();
        }
      }
      else {
        ls.reset();
      }
    }
  }
 ///// image(textGraphics, 0, 0);
}

void mouseClicked()
{
  stroke(286, 72, 87);
  fill(286, 72, 87);
  ellipse(mouseX, mouseY, 25, 25);
  stroke(0);
  fill(0);
  textGraphics.beginDraw();
  textGraphics.ellipse(mouseX, mouseY, 40, 40);
  textGraphics.endDraw();
  textGraphics.loadPixels();  
}


int currY = 60;
PFont medFont = createFont("Verdana", 24);
int medFontHeight = 42;
PFont largeFont = createFont("Verdana", 36);
int largeFontHeight = 42;
PFont smallFont = createFont("Verdana", 16);
int smallFontHeight = 26;
int textX;

void anyText(PFont font, int fontHeight, String s)
{
  if (s.length() != 0)
  {
    textGraphics.textFont(font);
    textGraphics.text("◊ " + s, textX, currY);
//    float tw = textGraphics.textWidth(s);
//    float radius = fontHeight * 0.8;
//    float center = textX - tw - radius;
//
//    textGraphics.ellipse(center, currY - (radius / 2.0), radius, radius);
  }
  currY += fontHeight;
}

void largeText(String s)
{
  anyText(largeFont, largeFontHeight, s);
}

void medText(String s)
{
  anyText(medFont, medFontHeight, s);
}

void smallText(String s)
{
  anyText(smallFont, smallFontHeight, s);
}

void drawType(float x) {
  textGraphics.textAlign(RIGHT);
  textGraphics.fill(0);
  textX = (int) x;

  medText("DorkbotPDX invites you to");
  largeText("Processing Fundamentals");
  medText("A free workshop at Flux");
  largeText("");
//  smallText("DorkbotPDX is happy to offer a 4-hour intro to Processing --");
//  smallText("a graphics programming environment.  Students will learn the");
//  smallText("basics of Processing.  No prior programming experience required!");
//  largeText("");
//  smallText("Sunday, April 27. 1-5pm @ Flux Hackerspace");
//  smallText("412 NW Couch #222, Portland, OR");
//  smallText("Bring: A laptop w/ Processing 2.0 installed (if you can)");
//  smallText("RSVP: something@somewhere");
  medText("");
  medText("");
  medText("");
  medText("");
  medText("Click to create pixel barriers");
}

class linestate
{
  int xPos;
  int yPos;
  color c;
  int steps;

  void reset()
  {
    this.xPos = 0;
    //yPos = (int) random(4) * (height / 4) + (height / 8);
    this.yPos = (int) random(height);
    int divisions = 6;
    int base = second() / (60 / divisions);
    c = color((base*(256/divisions)) + random(8), random(255), 255);
    steps = 5;
  }  
}

