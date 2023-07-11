interface IScene
{
    void nextFrame();

    boolean isEnd();
}

class SceneManager
{
    ArrayList<IScene> _sceneList;

    SceneManager() { _sceneList = new ArrayList<IScene>(); }

    void addScene(IScene scene) { _sceneList.add(scene); }

    void advanceOneFrame()
    {
        if (isFinish()) { return; }
        IScene scene = _sceneList.get(0);
        scene.nextFrame();
        if (scene.isEnd()) { _sceneList.remove(0); }
    }

    boolean isFinish() { return _sceneList.size() == 0; }
}