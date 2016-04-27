/* USAGE :
 * call FULLSCREEN(monitor_index, renderer)
 * instead of
 * size(width, height, renderer);
 *
 * Due to limitations with the default renderer,
 * fullscreen() cannot be called without specifying
 * a renderer (OPENGL, P3D, P2D)
 */

import java.awt.*;

public void fullscreen(int monitor_index, String renderer){
  GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
  GraphicsDevice[] gs = ge.getScreenDevices();
  GraphicsDevice gd = gs[monitor_index];
  GraphicsConfiguration[] gc = gd.getConfigurations();
  Rectangle monitor = gc[0].getBounds();

  size(monitor.width, monitor.height, renderer);
  frame.setLocation(monitor.x, monitor.y);
  // frame.setAlwaysOnTop(true);
}

public void init(){
  frame.removeNotify();
  frame.setUndecorated(true);
  super.init();
}
