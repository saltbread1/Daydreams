// import processing.opengl.*;
// import com.hamoid.*;
import java.util.Comparator;
import java.util.Arrays;

// VideoExport _videoExport;
// boolean _isExport = false;
// int _exportingMs = 10000;
int _frameRate = 30;
SceneManager _sm;

void setup()
{
    //size(1920, 1080, P2D); // full HD
    size(800, 450, P2D); // for test
    smooth();
    frameRate(_frameRate);
    background(#000000);
    initialize();
    // if (_isExport) { exportStart(); }
}

void initialize()
{
    _sm = new SceneManager();
    _sm.addScene(new SceneImageConvert(10.5, 11.5));
}

void draw()
{
    // if (frameCount == 2) { initialize(); }
    // if (frameCount <= 2) { return; }
    
    _sm.advanceOneFrame();
    if (_sm.isFinish())
    {
        println("The movie has just finished.");
        noLoop();
    }
    // if (_isExport) { exportFrame(_exportingMs); }
}

void keyPressed()
{
    if (key == 's' || key == 'S') { saveImage(); }
    else if (key == 'r' || key == 'R') { initialize(); }
}

String timestamp()
{
    String timestamp = year() + nf(month(), 2) + nf(day(), 2) 
        + "_"  + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
    return timestamp;
}

void saveImage() { saveFrame(timestamp() + "_####.png"); }
