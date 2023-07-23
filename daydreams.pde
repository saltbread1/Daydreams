// import com.hamoid.*;
import quaternion.*;
import java.util.Comparator;
import java.util.Arrays;
import java.util.ArrayDeque;
import java.util.HashMap;

// VideoExport _videoExport;
// boolean _isExport = false;
// int _exportingMs = 10000;
int _frameRate = 30;
SceneManager _sm;
DataManager _dm;
Utility _util;
TestHUD _hud;
Scene[] _scenes;

void setup()
{
    //size(1920, 1080, P3D); // full HD
    size(800, 450, P3D);
    smooth();
    frameRate(_frameRate);
    background(#000000);
    textureMode(NORMAL);

    _sm = new SceneManager();
    _dm = new DataManager();
    _util = new Utility();
    _hud = new TestHUD();
    _scenes = new Scene[]{
            // new SceneAppearing(2.65*4),
            // new SceneLandscape(13, 9.5),
            // new SceneTunnel(11),
            // new SceneRecursiveRect(11.5, 5.5),
            // new SceneImageConvert(22, 5, 10.5),
            // new SceneTrianglesRotation(3),
            // new SceneArcsRotation(3),
            // new SceneDistortedGrid(3),
            // new SceneIcosphere(3),
            new SceneQuadDivision(3),
            new SceneKaleidoscope(3),
            new SceneAbsorption(this, 3),
            new SceneReversingRects(3)
            //new SceneExploring(12, 3)
    };
}

void draw()
{
    // preprocessing
    if (frameCount == 1) { _dm.preprocessing(); }
    else if (frameCount < _scenes.length+2) { _sm.addScene(_scenes[frameCount-2]); }

    if (frameCount == _scenes.length+2)
    {
        println("The movie has just started.");
        // if (_isExport) { exportStart(); }
    }
    if (frameCount >= _scenes.length+2)
    {
        // println("FPS: "+_hud.getFPS());
        _sm.advanceOneFrame();
        // if (_isExport) { exportFrame(_exportingMs); }
    }
}

void keyPressed()
{
    if (key == 's' || key == 'S') { saveImage(); }
}

String timestamp()
{
    String timestamp = year() + nf(month(), 2) + nf(day(), 2) 
        + "_"  + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
    return timestamp;
}

void saveImage() { saveFrame(timestamp() + "_####.png"); }
