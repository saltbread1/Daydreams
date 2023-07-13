abstract class Scene
{
    final float _totalSceneSec;
    float _curSec;

    Scene(float totalSceneSec) { _totalSceneSec = totalSceneSec; }
    
    abstract void initialize();

    abstract void update();

    void timeCount() { _curSec += 1./_frameRate; }

    boolean isEnd() { return _curSec > _totalSceneSec; }

    void postProcessing() { println("End \""+this.getClass().getSimpleName()+"\"."); }

    void clearScene() { background(#000000); }
}

class SceneManager
{
    ArrayList<Scene> _sceneList;

    SceneManager() { _sceneList = new ArrayList<Scene>(); }

    void addScene(Scene scene)
    {
        float t = millis();
        scene.initialize();
        println("Initialization of \""+scene.getClass().getSimpleName()+"\": "+(millis()-t)+" ms.");
        _sceneList.add(scene);
    }

    void advanceOneFrame()
    {
        if (isFinish()) { return; }
        Scene scene = _sceneList.get(0);
        scene.clearScene();
        scene.update();
        scene.timeCount();
        if (scene.isEnd())
        {
            scene.postProcessing();
            _sceneList.remove(0);
        }
    }

    boolean isFinish() { return _sceneList.size() == 0; }
}