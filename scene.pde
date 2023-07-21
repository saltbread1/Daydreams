abstract class Scene
{
    final float _totalSceneSec;
    float _curSec;

    Scene(float totalSceneSec) { _totalSceneSec = totalSceneSec; }
    
    abstract void initialize();

    abstract void update();

    void start() {}

    void timeCount() { _curSec += 1./_frameRate; }

    boolean isEnd() { return _curSec > _totalSceneSec; }

    void postProcessing() { println("End \""+this.getClass().getSimpleName()+"\"."); }

    void clearScene() { background(#000000); }

    float getCurrentSecond() { return _curSec; }
}

class SceneManager
{
    ArrayDeque<Scene> _sceneQueue;
    Scene _curScene;

    SceneManager() { _sceneQueue = new ArrayDeque<Scene>(); }

    void addScene(Scene scene)
    {
        float t = millis();
        scene.initialize();
        println("Initialization of \""+scene.getClass().getSimpleName()+"\": "+(millis()-t)+" ms.");
        _sceneQueue.add(scene);
    }

    void advanceOneFrame()
    {
        if (_curScene == null) { _curScene = _sceneQueue.poll(); }

        _curScene.clearScene();
        if (_curScene.getCurrentSecond() == 0)
        {
            float t = millis();
            _curScene.start();
            println("Start of \""+_curScene.getClass().getSimpleName()+"\": "+(millis()-t)+" ms.");
            _curScene.timeCount();
            return;
        }
        _curScene.update();
        _curScene.timeCount();
        if (_curScene.isEnd())
        {
            _curScene.postProcessing();
            if (isFinish())
            {
                postProcessing();
                return;
            }
            _curScene = _sceneQueue.poll();
        }
    }

    boolean isFinish() { return _sceneQueue.size() == 0; }

    void postProcessing()
    {
        println("The movie has just finished.");
        noLoop();
    }
}

abstract class Camera
{
    final PVector _center2eye;
    PVector _centerPos, _vibOffset;
    float _vibRotRad, _vibCurSec;

    Camera(PVector center2eye, PVector centerPos)
    {
        _center2eye = center2eye;
        _centerPos = centerPos;
        _vibOffset = new PVector();
        _vibRotRad = random(TAU);
    }

    Camera(PVector center2eye)
    {
        this(center2eye, new PVector());
    }

    abstract void update();

    void updateCamera()
    {
        PVector c = PVector.add(_centerPos, _vibOffset);
        PVector eye = PVector.add(c, _center2eye);
        camera(eye.x, eye.y, eye.z, c.x, c.y, c.z, 0, 1, 0);
    }

    void addVibration(float vibPeriodSec, float vibScaleRadius, float vibRotMaxSpd)
    {
        float r = acos(cos(TAU*_vibCurSec/vibPeriodSec))/PI;
        _vibRotRad += vibRotMaxSpd * random(.36, 1);
        _vibOffset = PVector.fromAngle(_vibRotRad).mult(vibScaleRadius * r);
        _vibCurSec += 1./_frameRate;
    }

    PVector getCenter() { return _centerPos; }
}