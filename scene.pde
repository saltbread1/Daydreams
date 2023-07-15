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