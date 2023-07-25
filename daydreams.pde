import com.hamoid.*;
import quaternion.*;
import java.util.Comparator;
import java.util.Arrays;
import java.util.ArrayDeque;
import java.util.HashMap;

VideoExport _videoExport;
boolean _isExport = false;
SceneManager _sm;
DataManager _dm;
Utility _util;
Scene[] _scenes;
int _frameRate = 30;

void setup()
{
    //size(1920, 1080, P3D); // full HD
    size(800, 450, P3D);
    smooth();
    frameRate(_frameRate);
    background(#000000);
    textureMode(NORMAL);

    _sm = new SceneManager(true);
    _dm = new DataManager();
    _util = new Utility();
    _scenes = new Scene[]{
            new SceneAppearing(new Camera(
                        null,
                        null),
                    11.4, 1, .85, 1), // total: 11.4 sec
            new SceneLandscape(
                    new LandscapeCamera(
                        new PVector(0, 1, .6).normalize().mult((height/2)/tan(PI/6)*1.5),
                        new PVector(),
                        new TransitionFadeOut(2, #000000),
                        new TransitionFadeIn(1, #ffffff)),
                    14.1, 11.3), // total; 25.5 sec
            new SceneTunnel(new Camera(
                        new PVector(0, 0, (height/2)/tan(PI/6)),
                        new PVector(),
                        new TransitionFadeOut(1, #ffffff),
                        new TransitionBlinkAlternating(.5, 1, #000000)),
                    11.6), // total: 37.1 sec
            new SceneRecursiveRect(new Camera(
                        null,
                        new TransitionFadeIn(.3, #ffffff)),
                    11.8, 5.9) // total: 48.9 sec
            new SceneImageConvert(new Camera(
                        new TransitionFadeOut(.3, #ffffff),
                        new TransitionBlinkOnce(1.5, .3, #ffffff)),
                    25.3, 6.1, 12.1), // total: 74.2 sec    48.9, 55, 61, 72.7, 74.2
            new SceneTrianglesRotation(new Camera(
                        new TransitionFadeOut(.35, #ffffff),
                        new TransitionBlinkAlternating(.35, 1, #000000)),
                    2.95),
            new SceneArcsRotation(new Camera(
                        null,
                        new TransitionBlinkAlternating(.35, 1, #000000)),
                    2.95),
            new SceneDistortedGrid(new Camera(
                        null,
                        new TransitionBlinkAlternating(.35, 1, #000000)),
                    2.95),
            new SceneIcosphere(new Camera(
                        new PVector(0, 0, (height/2)/tan(PI/6)),
                        new PVector(),
                        null,
                        new TransitionRecursive(1.4, 7, .8)),
                    2.95),
            new SceneQuadDivision(new Camera(
                        new TransitionFadeOut(.7, #000000),
                        new TransitionBlinkAlternating(.35, 1, #000000)),
                    2.95),
            new SceneKaleidoscope(new Camera(
                        new TransitionFadeOut(.7, #000000),
                        new TransitionBlinkAlternating(.35, 1, #000000)),
                    2.95),
            new SceneAbsorption(new Camera(
                        new TransitionFadeOut(.7, #000000),
                        new TransitionBlinkAlternating(.35, 1, #000000)),
                    2.95),
            new SceneReversingRects(new Camera(
                        new TransitionFadeOut(.7, #000000),
                        null),
                    2.95),
            new SceneExploring(new ExploringCamera(
                        new PVector(0, 0, (height/2)/tan(PI/6)),
                        new PVector(),
                        new TransitionFadeOut(2, #ffffff),
                        new TransitionDivision(.8, 3)),
                    11.8, 2.95), // total: 109.8 sec
            new SceneSlidingCircles(new Camera(
                        new TransitionFadeOut(1, #000000),
                        new TransitionSlide(11.8, #000000)),
                    2.95*8, 2.95), // total: 133.4 sec
            new SceneLogo(new Camera(
                        null,
                        null),
                    8.9, 6.1) // total: 142.3 sec
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
        if (_isExport)
        {
            _videoExport = new VideoExport(this, "daydreams.mp4");
            _videoExport.startMovie();
        }
    }
    if (frameCount >= _scenes.length+2)
    {
        _sm.advanceOneFrame();
        if (_isExport) { _videoExport.saveFrame(); }
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

void exportFinish()
{
    _videoExport.endMovie();
    exit();
}