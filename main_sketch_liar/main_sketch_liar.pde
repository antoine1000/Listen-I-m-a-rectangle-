//************* Listen, I'm a rectangle! ************* 
// Project by Antoine Puel, student @ ERG
// Ressource : Daniel Shiffman & Greg Borenstein (Making Things See)
// Great help from François Zajéga (http://www.frankiezafe.org) 
// & Arnaud Juracek (http://arnaudjuracek.fr)


// Définitions des variables de formes
public static final int FORM_UNDEFINED = 0;
public static final int FORM_RECT = 1;
public static final int FORM_TRIANGLE = 2;
public static final int FORM_ELLIPSE = 3;
public static final int FORM_NUMBER = 4;

int[] userform;
boolean[] useractive;
int currentForm = FORM_RECT;

// Importation des librairies
import SimpleOpenNI.*;
import geomerative.*;
import de.looksgood.ani.*;
import de.looksgood.ani.easing.*;
import themidibus.*;

SimpleOpenNI kinect;

// Create Rshape objects
RShape circle;
RShape rectangle;
RShape triangle;

// Create a MidiBus object
MidiBus mb;

// MIDI notes params
int channel = 1;
int pitch = 50;
int velocity = 90;

boolean sketchFullScreen() {
  return true;
}

   
float xr = 0;
float yr = 0;


void setup() {
  size(displayWidth, displayHeight, P3D);

// Création d'instances pour rendre disponible les librairies openNI/Geomerative/Midibus/Ani
  kinect = new SimpleOpenNI(this); 
  kinect.enableDepth(); 
  kinect.enableUser();
   
  Ani.init(this);
  RG.init(this);
  
// Instantiate the MidiBus
  mb = new MidiBus(this, -1, "Bus 1");

// Instantiation des tableaux userform & useractive (16 détection max.)
  userform = new int[16];
  useractive = new boolean[16];

// Au démarrage, toutes les formes sont "undefined"
  for (int i=0; i < 16; i++) {
    userform[i] = FORM_UNDEFINED;
  }
}

void draw() {
  kinect.update();
  image(kinect.depthImage(), 0, 0);
  background(0, 0, 30);

// IntVector marche comme un array, mais qui augmente ou réduit sa taille selon l'entrée ou la sortie des élements
  IntVector userList = new IntVector();
  kinect.getUsers(userList);

// De base, tous les utilisateurs sont déclarés comme inactifs
  for (int i=0; i < 16; i++) {
    useractive[i] = false;
  }

// Recherche un utilisateur et lui attribut un Id selon son center of mass
  for (int i=0; i<userList.size (); i++) {
    
     

    int userId = userList.get(i);

    PVector position = new PVector(); 
    kinect.getCoM(userId, position);

//Permet de changer de forme dès qu'un utilisateur rentre dans le cadre
    if ( position.z == 0 ) {
      println("Ce n'est pas bon !");
      continue;
    }


// Une fois un utilisateur actif repéré, si sa forme est undefined, lui attribuer une forme
    useractive[userId] = true;
    if (userform[userId] == FORM_UNDEFINED) {
      userform[userId] = currentForm;
      currentForm++;
    // Tourne en boucle, on revient au rectangle
      if (currentForm >= FORM_NUMBER) {
        currentForm = FORM_RECT;
      }
      println("On met une nouvelle forme!" + userform[userId] + " " + userId);
    }

    kinect.convertRealWorldToProjective(position, position);

    println(position.x);

    float mirrorx = (width)-position.x;
    stroke(245, 255, 100);
    strokeWeight(5);
    noFill();
    translate(0, 0, 0);
    
// Traduction des proportions kinect en proportions fullscreen
float posx = map(position.x, 0, 640, width, 0);
float posy = map(position.y, 0, 480, 0, height);
float widthShape = map(position.z, 250, 3000, 500, 50);
float heightShape = map(position.z, 250, 3000, 500, 50)*1.5;
    
// Création des formes géométriques      
  switch (userform[userId]) {
    case FORM_RECT :
// Animation de l'apparition de la forme
     
      rectangle = RShape.createRectangle((posx - widthShape / 2), (posy - heightShape/2), xr, yr);
      noFill();
      stroke(0, 0, 255);
      rectangle.draw();
      // lerp animation
      xr += (widthShape - xr)* 0.2;
      yr += (heightShape - yr) * 0.2;
      
  
// Active le channel midi à l'apparition de la forme
//  mb.sendNoteOn(channel, pitch, velocity);
      break;
    case FORM_ELLIPSE :
      circle = RShape.createEllipse(posx, posy, widthShape, heightShape);
      noFill();
      stroke(255, 0, 0);
      circle.draw();
    break;
    case FORM_TRIANGLE :
        triangle = RShape.createStar(posx, posy, map(position.z, 250, 3000, 500, 50)/2, map(position.z, 250, 3000, 500, 50), 3);
        // Rotate le triangle pour qu'il s'affiche dans le bon sens
        triangle.rotate((PI/2)*3, triangle.getCenter());
        noFill();
        stroke(255, 255, 0);
        triangle.draw();
    break;
  }
    
// Affiche l'ID de chaque utilisateur
//    fill(0, 255, 0);
//    textSize(60);
//    text(userId, posx, posy);
//println(position.z);

}
  
// GEOMERATIVE INTERSECTION, actif uniquement si les formes sont elles-même actives
  if(rectangle != null && circle != null){
     if(circle.intersects(rectangle)) {
    RShape diff = circle.intersection(rectangle);
//    fill( random(255), random(255), random(255));



RPoint[] gi = circle.getIntersections(rectangle);

for(int i = 0; i <= diff.width; i += 10) {
   stroke(255);
   line(gi[i].x, gi[i].y, gi[i].x, diff.height); 
   if(diff !=null)  diff.draw();
     }
    mb.sendNoteOn(channel, pitch, velocity);
  }
} 
  
   if(rectangle != null && triangle != null){
     if(rectangle.intersects(triangle)) {
    RShape diff = rectangle.intersection(triangle);
    fill( random(255), random(255), random(255));
    if(diff !=null)  diff.draw();
    mb.sendNoteOn(channel, pitch, velocity);
    }
  } 
  
  if(circle != null && triangle != null){
     if(circle.intersects(triangle)) {
    RShape diff = circle.intersection(triangle);
    fill( random(255), random(255), random(255));
    if(diff !=null)  diff.draw();
    mb.sendNoteOn(channel, pitch, velocity);
    }
  } 
  
  
// Si il n'y a plus d'utilisateur actif et qu'une forme est encore attribué à rect/ellipse..etc, alors lui attribuer une forme undefined
// Permet de remettre le tableau à undefined en cas de nouvelle entrée/sortie d'utilisateurs
  for (int i=0; i < useractive.length; i++) {

    if (!useractive[i] && userform[i] != FORM_UNDEFINED) {
      userform[i]= FORM_UNDEFINED;
      rectangle = null;
      circle = null;
      triangle = null;
    }
  }
  
}

      


