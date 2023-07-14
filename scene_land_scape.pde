class SceneLandscape extends Scene
{
    Landscape _landscape;
    Camera _camera;

    SceneLandscape(float totalSceneSec)
    {
        super(totalSceneSec);
    }

    @Override
    void initialize()
    {
        _landscape = new Landscape(width*10, 40, new PVector(), width);
        _landscape.createFaces();
        _camera = new Camera(
                new PVector(0, height, height/2),
                width, height,
                _landscape.getRange());
        _camera.update(0); // initialize camera position
    }

    @Override
    void update()
    {
        ambientLight(32, 32, 32);
        directionalLight(255, 255, 255, -.5, 0, -1);
        _camera.update(_curSec);
        //_camera.rangeCheck();
        //_camera.drawRange();
        _landscape.drawMe(_camera.getCenter());
        //println(_curSec);
    }

    @Override
    void postProcessing()
    {
        super.postProcessing();
        resetCamera();
    }

    // @Override
    // void clearScene() { background(#ffffff); }

    class Camera
    {
        final PVector _center2eye;
        final Rect _limit;
        PVector _center, _dir;
        float _stepCurSec, _stepTotalSec, _speed;

        Camera(PVector center2eye, float width, float height, Rect range)
        {
            _center2eye = center2eye;
            PVector halfCameraSize = new PVector(width, height).div(2);
            _limit = new Rect(
                    PVector.add(range._upperLeft, halfCameraSize),
                    PVector.sub(range._lowerRight, halfCameraSize));
        }

        PVector getCenter() { return _center; }

        void update(float sec)
        {
            float x = map(noise(sec*.05, 10), 0, 1, _limit._upperLeft.x, _limit._lowerRight.x);
            float y = map(noise(sec*.05, 20), 0, 1, _limit._upperLeft.y, _limit._lowerRight.y);
            _center = new PVector(x, y);
            PVector eye = PVector.add(_center, _center2eye);
            camera(eye.x, eye.y, eye.z, _center.x, _center.y, _center.z, 0, 1, 0);
        }

        // void update()
        // {
        //     PVector c = new PVector(mouseX-width/2, mouseY-height/2);
        //     PVector dv = PVector.sub(c, _center);
        //     _center.add(dv);
        //     _eye.add(dv);
        //     _size.translate(dv);
        //     updateCamera();
        // }

        void setStepParameters()
        {
            _dir = PVector.random2D();
            _stepCurSec = 0;
            _stepTotalSec = 3;
            _speed = 1;
        }

        // void update()
        // {
        //     if (_stepCurSec >= _stepTotalSec) { setStepParameters(); }

        //     PVector dv = PVector.mult(_dir, _speed);
        //     _stepCurSec += 1./_frameRate;
        // }

        // void rangeCheck()
        // {
        //     PVector sul = _size._upperLeft;
        //     PVector slr = _size._lowerRight;
        //     PVector rul = _limit._upperLeft;
        //     PVector rlr = _limit._lowerRight;
        //     PVector offset = new PVector();
        //     if (sul.x < rul.x) { offset.x = rul.x - sul.x; } // left
        //     else if (slr.x > rlr.x) { offset.x = rlr.x - slr.x; } // right
        //     if (sul.y < rul.y) { offset.y = rul.y - sul.y; } // up
        //     else if (slr.y > rlr.y) { offset.y = rlr.y - slr.y; } // down
        //     update(offset);
        // }

        void drawRange()
        {
            pushStyle();
            stroke(#0000ff);
            noFill();
            _limit.drawMe();
            popStyle();
        }
    }
}