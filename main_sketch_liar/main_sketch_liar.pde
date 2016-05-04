//************* Listen, I'm a rectangle! ************* 
// Project by Antoine Puel, student @ ERG, http://antoine.cool
// If you use this code for a project, please mention my name and my website in the code. Thanks!
// Made with : Processing (2.2.1) and Kinect MODEL 1414
// Ressource : Daniel Shiffman & Greg Borenstein (Making Things See)
// Great help from François Zajéga (http://www.frankiezafe.org) 
// Arnaud Juracek (http://arnaudjuracek.fr) & Hugo Piquemal (http://hugopiquemal.com)


// Shapes variables
public static final int FORM_UNDEFINED = 0;
public static final int FORM_RECT = 1;
public static final int FORM_TRIANGLE = 2;
public static final int FORM_ELLIPSE = 3;
public static final int FORM_NUMBER = 4;

int[] userform;
boolean[] useractive;
int currentForm = FORM_RECT;

// Libraries importation
import SimpleOpenNI.*;
import geomerative.*;
import de.looksgood.ani.*;
import de.looksgood.ani.easing.*;
import themidibus.*;

SimpleOpenNI kinect;

// Create Rshape objects and textures
RShape circle;
RShape rectangle;
RShape triangle;
PImage tex;

// Create a MidiBus object
MidiBus mb;

// MIDI notes params
int channel = 1;
int pitch = 50;
int velocity = 90;

boolean sketchFullScreen() {
  return true;
}

// Width and Height variable of every shapes at "start"
float wr, hr, wt, ht, wc, hc = 0;


void setup() {
  size(displayWidth, displayHeight, P3D);
// New libraries object : openNI/Geomerative/Midibus/Ani
  kinect = new SimpleOpenNI(this); 
  kinect.enableDepth(); 
  kinect.enableUser();
  Ani.init(this);
  RG.init(this);
  
// Instantiate the texture
  tex = loadImage("degrad.png");
  textureMode(NORMAL);

// Instantiate the MidiBus
  mb = new MidiBus(this, -1, "Bus 1");

// Instantiation of userform & useractive arrays (16 users max)
  userform = new int[16];
  useractive = new boolean[16];

// At first, every shapes are "undefined"
  for (int i=0; i < 16; i++) {
    userform[i] = FORM_UNDEFINED;
  }
}

void draw() {
  kinect.update();
  image(kinect.depthImage(), 0, 0);
  background(0, 0, 30);

// IntVector is like an array, but add or delete elements if needed
  IntVector userList = new IntVector();
  kinect.getUsers(userList);

// At start, every users are inactive
  for (int i=0; i < 16; i++) {
    useractive[i] = false;
  }

// Search for an user and give him a UserId (based on his center of mass)
  for (int i=0; i<userList.size (); i++) {
    int userId = userList.get(i);
    PVector position = new PVector(); 
    kinect.getCoM(userId, position);

// Every geometric are differents when a user enter or re-enter the screen
    if ( position.z == 0 ) {
      println("That's not good!");
      continue;
    }

// If a user is detected, and his form is "undefined", it's give him a new form
    useractive[userId] = true;
    if (userform[userId] == FORM_UNDEFINED) {
      userform[userId] = currentForm;
      currentForm++;
// Shapes appear in a loop : rectangle -> triangle -> circle -> rectangle...etc
      if (currentForm >= FORM_NUMBER) {
        currentForm = FORM_RECT;
      }
      println("Putting a new shape!" + userform[userId] + " " + userId);
    }

    kinect.convertRealWorldToProjective(position, position);

    println(position.x);
    strokeWeight(5);
    translate(0, 0, 0);

// Translation of kinect proportion to fullscreen proportions
    float posx = map(position.x, 0, 640, width, 0);
    float posy = map(position.y, 0, 480, 0, height);
    float widthShape = map(position.z, 250, 3000, 1000, 50);
    float heightShape = map(position.z, 250, 3000, 700, 50)*1.5;

// Creation of geometric shapes     
    switch (userform[userId]) {
    case FORM_RECT :  
      rectangle = RShape.createRectangle((posx - widthShape / 2), (posy - heightShape/2), wr, hr);
      noFill();
      stroke(0, 0, 255);
      rectangle.draw();
// The shape appears with a "lerp" animation
      wr += (widthShape - wr)* 0.08;
      hr += (heightShape - hr) * 0.2;
// MIDI Channel is activate when the shape appears
      /*  mb.sendNoteOn(channel, pitch, velocity); */
      break;
    case FORM_ELLIPSE :
      circle = RShape.createEllipse(posx, posy, wc, hc);
      noFill();
      stroke(255, 0, 0);
      circle.draw();
// The shape appears with a "lerp" animation
      wc += (widthShape - wc)* 0.09;
      hc += (heightShape - hc) * 0.15;
      break;
    case FORM_TRIANGLE :
      triangle = RShape.createStar(posx, posy, wt, ht, 3);
// (PI/2)*3 is for a correct display of the triangle
      triangle.rotate((PI/2)*3, triangle.getCenter());
      noFill();
      stroke(255, 255, 0);
      triangle.draw();
// The shape appears with a "lerp" animation
      wt += (widthShape/2 - wt)* 0.09;
      ht += (widthShape - ht) * 0.3;
      break;
  }

// OPTIONAL : Display the userId (number) of each user
    /*  fill(0, 255, 0);
        textSize(60);
        text(userId, posx, posy);
        println(position.z); */
}

// Geomerative intersection (active only if shapes are displayed)
  
// Rectangle & circle
  if (rectangle != null && circle != null) {
    if (circle.intersects(rectangle)) {
      RShape diff = circle.intersection(rectangle);

// RPoint array to get the points area of "diff"
    RG.setPolygonizer(RG.UNIFORMLENGTH);
    RG.setPolygonizerLength(10);
    RPoint[] points = diff.getPoints();
    
// Create a shape equals to "diff shape"
 beginShape();
    texture(tex);
    for (int i=0; i<points.length; i++) {
      float x = points[i].x;
      float y = points[i].y;
      float u = norm(points[i].x, circle.getX(), circle.getWidth() + circle.getX());
      float v = norm(points[i].y, circle.getY(), circle.getHeight() + circle.getY());
      vertex(x, y, u, v);
    }
    endShape();
      mb.sendNoteOn(channel, pitch, velocity);
    }  
  } 

  if (rectangle != null && triangle != null) {
    if (rectangle.intersects(triangle)) {
      RShape diff = rectangle.intersection(triangle);
      fill( random(255), random(255), random(255));
      if (diff !=null)  diff.draw();
      mb.sendNoteOn(channel, pitch, velocity);
    }
  } 

  if (circle != null && triangle != null) {
    if (circle.intersects(triangle)) {
      RShape diff = circle.intersection(triangle);
      fill( random(255), random(255), random(255));
      if (diff !=null)  diff.draw();
      mb.sendNoteOn(channel, pitch, velocity);
    }
  } 

// Reload the "first apperance animation" of a shape
  if (rectangle == null && wr != 0) {
    wr = 0;
    hr = 0;
  }
  
    if (circle == null && wc != 0) {
    wc = 0;
    hc = 0;
  }
  
    if (triangle == null && wt != 0) {
    wt = 0;
    ht = 0;
  }

// If there is no more active users, but a shape is still assign to a user, the shape became "undefined" and disappear
// In case of new entry or exit of users, shapes in the array became "undefined"
  for (int i=0; i < useractive.length; i++) {
    if (!useractive[i] && userform[i] != FORM_UNDEFINED) {
      userform[i]= FORM_UNDEFINED;
      rectangle = null;
      circle = null;
      triangle = null;
    }
  }
}

// Test de trame au croisement de formes (ne marche pas)
     /* RPoint[] gi = circle.getIntersections(rectangle);

      for (int i = 0; i <= diff.width; i += 10) {
        stroke(255);
        line(gi[i].x, gi[i].y, gi[i].x, diff.height); 
        if (diff !=null)  diff.draw();
      } */

