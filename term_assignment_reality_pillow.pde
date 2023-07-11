// import processing.opengl.*;
// import peasy.*;
// import com.hamoid.*;
// import gifAnimation.*;

// PeasyCam _cam;
// CameraState _camstate;
// VideoExport _videoExport;
// GifMaker _gifExport;
// boolean _isExport = false;
// int _exportingMs = 10000;
int _frameRate = 30;

void setup()
{
    size(512, 512);
    smooth();
    frameRate(_frameRate);
    // peasySettings();
    initialize();
    // if (_isExport) { exportStart(); }
}

void initialize()
{
    // _cam.setState(_camstate, 1000);
}

void draw()
{
    clearScene();
    
    // if (_isExport) { exportFrame(_exportingMs); }
}

void keyPressed()
{
    if (key == 's' || key == 'S') { saveImage(); }
    else if (key == 'r' || key == 'R') { initialize(); redraw(); }
    // else if ((key == 'e' || key == 'E') && _isExport) { exportFinish(); }
}

String timestamp()
{
    String timestamp = year() + nf(month(), 2) + nf(day(), 2) 
        + "_"  + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
    return timestamp;
}

void clearScene() { background(#222244); }

void saveImage() { saveFrame(timestamp() + "_####.png"); }