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
            // new SceneAppearing(new Camera(
            //             null,
            //             null),
            //         11.6, 1, .9, 1),
            new SceneLandscape(
                    new LandscapeCamera(
                        new PVector(0, 1, .6).normalize().mult((height/2)/tan(PI/6)*1.5),
                        new PVector(),
                        new TransitionFadeOut(2, #000000),
                        new TransitionFadeIn(1, #ffffff)),
                    25.644-11.6, 22.771-11.6),
            new SceneTunnel(new Camera(
                        new PVector(0, 0, (height/2)/tan(PI/6)),
                        new PVector(),
                        new TransitionFadeOut(1, #ffffff),
                        new TransitionBlink(37.2-36.45, 1, #000000)),
                    37.2-25.664)
            // new SceneRecursiveRect(new Camera(
            //             null,
            //             new TransitionFadeIn(.3, #ffffff)),
            //         11.5, 5.5),
            // new SceneImageConvert(new Camera(
            //             new TransitionFadeOut(.3, #ffffff),
            //             null),
            //         22, 5, 10.5),
            // new SceneTrianglesRotation(new Camera(
            //             null,
            //             new TransitionBlink(.33, 1, #000000)),
            //         3),
            // new SceneArcsRotation(new Camera(
            //             null,
            //             new TransitionBlink(.33, 1, #000000)),
            //         3),
            // new SceneDistortedGrid(new Camera(
            //             null,
            //             new TransitionBlink(.33, 1, #000000)),
            //         3),
            // new SceneIcosphere(new Camera(
            //             new PVector(0, 0, (height/2)/tan(PI/6)),
            //             new PVector(),
            //             null,
            //             new TransitionRecursive(.8, 5, .8)),
            //         3),
            // new SceneQuadDivision(new Camera(
            //             new TransitionFadeOut(.6, #000000),
            //             new TransitionBlink(.33, 1, #000000)),
            //         3),
            // new SceneKaleidoscope(new Camera(
            //             new TransitionFadeOut(.6, #000000),
            //             new TransitionBlink(.33, 1, #000000)),
            //         3),
            // new SceneAbsorption(new Camera(
            //             new TransitionFadeOut(.6, #000000),
            //             new TransitionBlink(.33, 1, #000000)),
            //         3),
            // new SceneReversingRects(new Camera(
            //             new TransitionFadeOut(.6, #000000),
            //             null),
            //         3),
            // new SceneExploring(new ExploringCamera(
            //             new PVector(0, 0, (height/2)/tan(PI/6)),
            //             new PVector(),
            //             new TransitionFadeOut(2, #ffffff),
            //             new TransitionDivision(.8, 3)),
            //         12, 3),
            // new SceneSlidingCircles(new Camera(
            //             new TransitionFadeOut(1, #000000),
            //             new TransitionSlide(12, #000000)),
            //         24, 3),
            // new SceneLogo(new Camera(
            //             null,
            //             null),
            //         300, 3)
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