class SceneLandscape extends Scene
{
    Landscape _landscape;

    SceneLandscape(float totalSceneSec)
    {
        super(totalSceneSec);
    }

    @Override
    void initialize()
    {
        _landscape = new Landscape(width, 16, new PVector());
        _landscape.createFaces();
        camera(0, -height, height/2, 0, 0, 0, 0, -1, -1);
    }

    @Override
    void update()
    {
        ambientLight(32, 32, 32);
        directionalLight(255, 255, 255, -.5, 0, -1);
        _landscape.drawMe();
        //println(_curSec);
    }

    @Override
    void postProcessing()
    {
        super.postProcessing();
        resetCamera();
    }
}