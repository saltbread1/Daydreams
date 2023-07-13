class SceneLandscape extends Scene
{
    Landscape _landscape;
    //Camera _camera;

    SceneLandscape(float totalSceneSec)
    {
        super(totalSceneSec);
    }

    @Override
    void initialize()
    {
        _landscape = new Landscape(width, 40, new PVector());
        _landscape.createFaces();
        camera(0, -height, height/2, 0, 0, 0, 0, -1, 0); // to right-handed system
    }

    @Override
    void update()
    {
        ambientLight(32, 32, 32);
        directionalLight(255, 255, 255, -.5, 0, -1);
        _landscape.drawMe(new PVector());
        //println(_curSec);
    }

    @Override
    void postProcessing()
    {
        super.postProcessing();
        resetCamera();
    }

    class Camera
    {
        PVector _eye, _center, _dir;
        float _stepCurSec, _stepTotalSec, _speed;
        Rect _range;

        Camera(PVector eye, PVector center, float width, float height)
        {
            _eye = eye;
            _center = center;
            _range = new Rect(
                    new PVector(width/2, width/2).add(center),
                    new PVector(height/2, height/2).add(center));
        }

        void update()
        {
            camera(_eye.x, _eye.y, _eye.z, _center.x, _center.y, _center.z, 0, 0, -1);
        }

        // void setStepParameters()
        // {
        //     _dir = PVector.random2D();
        //     _stepCurSec = 0;
        //     _stepTotalSec = 3;
        //     _speed = 1;
        // }

        // void updateMe()
        // {
        //     if (_stepCurSec >= _stepTotalSec) { setStepParameters(); }

        //     PVector dv = PVector.mult(_dir, _speed);
        //     _stepCurSec += 1./_frameRate;
        // }
    }
}