// import processing.opengl.*;
// import com.hamoid.*;

// VideoExport _videoExport;
// boolean _isExport = false;
// int _exportingMs = 10000;
int _frameRate = 30;
SceneManager _sm;

void setup()
{
    size(512, 512);
    smooth();
    frameRate(_frameRate);
    initialize();
    // if (_isExport) { exportStart(); }
}

void initialize()
{
    _sm = new SceneManager();
}

void draw()
{
    clearScene();
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
    else if (key == 'r' || key == 'R') { initialize(); redraw(); }
}

String timestamp()
{
    String timestamp = year() + nf(month(), 2) + nf(day(), 2) 
        + "_"  + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
    return timestamp;
}

void clearScene() { background(#000000); }

void saveImage() { saveFrame(timestamp() + "_####.png"); }