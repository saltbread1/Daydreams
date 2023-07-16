// import processing.opengl.*;
// import com.hamoid.*;
import quaternion.*;
import java.util.Comparator;
import java.util.Arrays;
import java.util.ArrayDeque;

// VideoExport _videoExport;
// boolean _isExport = false;
// int _exportingMs = 10000;
int _frameRate = 30;
SceneManager _sm;
Utility _util;
TestHUD _hud;

void setup()
{
    //size(1920, 1080, P3D); // full HD
    size(800, 450, P3D); // for test
    smooth();
    frameRate(_frameRate);
    background(#000000);
    initialize();
    // if (_isExport) { exportStart(); }
}

void initialize()
{
    _util = new Utility();
    _hud = new TestHUD();
    _sm = new SceneManager();
    // _sm.addScene(new SceneLandscape(13, 9.5));
    // _sm.addScene(new SceneTunnel(11));
    // _sm.addScene(new SceneImageConvert(10.5, 11.5));
    _sm.addScene(new SceneRandomWalk(100));
}

void draw()
{
    //println("FPS: "+_hud.getFPS());
    _sm.advanceOneFrame();
    // if (_isExport) { exportFrame(_exportingMs); }
}

void keyPressed()
{
    if (key == 's' || key == 'S') { saveImage(); }
    //else if (key == 'r' || key == 'R') { initialize(); }
}

String timestamp()
{
    String timestamp = year() + nf(month(), 2) + nf(day(), 2) 
        + "_"  + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
    return timestamp;
}

void saveImage() { saveFrame(timestamp() + "_####.png"); }
