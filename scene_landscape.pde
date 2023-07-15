class SceneLandscape extends Scene
{
    Landscape _landscape;
    Camera _camera;
    float _visualChangeSec;

    SceneLandscape(float totalSceneSec, float visualChangeSec)
    {
        super(totalSceneSec);
        _visualChangeSec = visualChangeSec;
    }

    @Override
    void initialize()
    {
        _landscape = new Landscape(width*6, 40, new PVector(), width);
        _landscape.createFaces();

        PVector offset = new PVector(width, width).div(2);
        Rect range = _landscape.getRange();
        Rect limit = new Rect(
                PVector.add(range._upperLeft, offset),
                PVector.sub(range._lowerRight, offset));
        _camera = new Camera(new PVector(0, height, height/2), limit);
    }

    @Override
    void start()
    {
        _camera.initialize();
    }

    @Override
    void update()
    {
        ambientLight(32, 32, 32);
        directionalLight(255, 255, 255, -.5, 0, -1);
        _camera.update();
        if (_curSec > _visualChangeSec) { _camera.addVibration(.14); }
        _camera.updateCamera();
        LandscapeStyle type = _curSec < _visualChangeSec ? LandscapeStyle.NORMAL : LandscapeStyle.VIRTUAL;
        _landscape.drawMe(_camera.getCenter(), type);
    }

    @Override
    void postProcessing()
    {
        super.postProcessing();
        _util.resetCamera();
    }

    class Camera
    {
        final PVector _center2eye;
        final Rect _limit;
        PVector _centerPos, _startPos, _goalPos;
        float _preStepRad, _stepCurSec, _stepTotalSec, _stepEndSec;
        PVector _vibDir;
        float _vibCurSec;

        Camera(PVector center2eye, Rect limit, PVector initCenterPos)
        {
            _center2eye = center2eye;
            _limit = limit;
            _centerPos = initCenterPos;
        }

        Camera(PVector center2eye, Rect range)
        {
            this(center2eye, range, new PVector());
        }

        void initialize()
        {
            _preStepRad = random(TAU);
            setStepParameters();
            setVibrationParameters();
            updateCamera();
        }

        void setStepParameters()
        {
            PVector virtualGoalPos;
            float rad;

            _startPos = _centerPos.copy();
            do
            {
                float d = width + sqrt(random(1))*width*2;
                rad = _preStepRad + random(-1,1)*PI*.8;
                //PVector dir = PVector.random2D();
                PVector dir = PVector.fromAngle(rad);
                _stepTotalSec = d*.0018;
                _stepEndSec = _stepTotalSec * sq(random(.44, .82));//random(.2,.9);
                _goalPos = PVector.add(_startPos, dir.mult(d));
                float r = _util.easeOutQuad(_stepEndSec/_stepTotalSec);
                virtualGoalPos = PVector.mult(_startPos, 1-r).add(PVector.mult(_goalPos, r));
            }
            while (!isInIimitRange(virtualGoalPos));
            
            _preStepRad = rad;
            _stepCurSec = 0;
        }

        void setVibrationParameters()
        {
            _vibDir = PVector.random2D();
            _vibCurSec = 0;
        }

        void update()
        {
            if (_stepCurSec >= _stepEndSec) { setStepParameters(); }
            float r = _util.easeOutQuad(_stepCurSec/_stepTotalSec);
            _centerPos = PVector.mult(_startPos, 1-r).add(PVector.mult(_goalPos, r));
            _stepCurSec += 1./_frameRate;
        }

        void addVibration(float vibTotalSec)
        {
            if (_vibCurSec >= vibTotalSec) { setVibrationParameters(); }
            float r = _util.easeReturnLiner(_vibCurSec/vibTotalSec);
            _centerPos.add(PVector.mult(_vibDir, width*.08*r));
            _vibCurSec += 1./_frameRate;
        }

        void updateCamera()
        {
            PVector eye = PVector.add(_centerPos, _center2eye);
            camera(eye.x, eye.y, eye.z, _centerPos.x, _centerPos.y, _centerPos.z, 0, 1, 0);
        }

        boolean isInIimitRange(PVector pos)
        {
            PVector ul = _limit._upperLeft;
            PVector lr = _limit._lowerRight;
            if (pos.x > ul.x && pos.x < lr.x && pos.y > ul.y && pos.y < lr.y)
            {
                return true;
            }
            return false;
        }

        PVector getCenter() { return _centerPos; }
    }
}