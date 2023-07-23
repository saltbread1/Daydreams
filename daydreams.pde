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
    // if (_isExport) { exportStart(); }
}

void draw()
{
    switch (frameCount)
    {
        case 1:
            _dm.preprocessing();
            break;
        case 2:
            // _sm.addScene(new SceneLandscape(13, 9.5));
            // _sm.addScene(new SceneTunnel(11));
            // _sm.addScene(new SceneRecursiveRect(11.5, 5.5));
            // _sm.addScene(new SceneImageConvert(22, 5, 10.5));
            break;
        case 3:
            // _sm.addScene(new SceneTrianglesRotation(3));
            // _sm.addScene(new SceneArcsRotation(3));
            // _sm.addScene(new SceneDistortedGrid(3));
            // _sm.addScene(new SceneIcosphere(3));
            break;
        case 4:
            // _sm.addScene(new SceneQuadDivision(3));
            // _sm.addScene(new SceneKaleidoscope(3));
            // _sm.addScene(new SceneAbsorption(this, 3));
            // _sm.addScene(new SceneReversingRects(3));
            // _sm.addScene(new SceneStereographicProjection(3));
            break;
        case 5:
            _sm.addScene(new SceneExploring(12, 3));
            break;
        default:
            if (frameCount < 1) { break; }
            // println("FPS: "+_hud.getFPS());
            _sm.advanceOneFrame();
            // if (_isExport) { exportFrame(_exportingMs); }
            break;
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
