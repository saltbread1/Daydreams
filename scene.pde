abstract class Scene
{
    final Camera _camera;
    final float _totalSceneSec;
    float _curSec;

    Scene(Camera camera, float totalSceneSec)
    {
        _camera = camera;
        _totalSceneSec = totalSceneSec;
    }
    
    abstract void initialize();

    void start() { _camera.setCamera(); }

    abstract void update();

    final void timeCount() { _curSec += 1./_frameRate; }

    final boolean isEnd() { return _curSec > _totalSceneSec; }

    void postProcessing() { println("End \""+this.getClass().getSimpleName()+"\"."); }

    void clearScene() { background(#000000); }

    final float getCurrentSecond() { return _curSec; }

    final float getTotalSecond() { return _totalSceneSec; }

    final Camera getCamera() { return _camera; }

    final void applyBeginTransitionEffect() { _camera.applyBeginTransitionEffect(); }
    
    final void applyEndTransitionEffect() { _camera.applyEndTransitionEffect(); }

    final float getBeginEffectTotalSecound() { return _camera.getBeginEffectTotalSecound(); }

    final float getEndEffectTotalSecound() { return _camera.getEndEffectTotalSecound(); }

    final void displayTimeInfo() { _camera.displayTimeInfo(); }
}

class SceneManager
{
    ArrayDeque<Scene> _sceneQueue;
    Scene _curScene;
    final boolean _isDisplayTime;

    SceneManager(boolean isDisplayTime)
    {
        _sceneQueue = new ArrayDeque<Scene>();
        _isDisplayTime = isDisplayTime;
    }

    SceneManager()
    {
        this(false);
    }

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
        }
        _curScene.update();
        if (_curScene.getCurrentSecond() < _curScene.getBeginEffectTotalSecound())
        {
            _curScene.applyBeginTransitionEffect();
        }
        if (_curScene.getCurrentSecond() > _curScene.getTotalSecond() - _curScene.getEndEffectTotalSecound())
        {
            _curScene.applyEndTransitionEffect();
        }
        if (_isDisplayTime) { _curScene.displayTimeInfo(); }
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
        if (_isExport) { exportFinish(); }
    }
}