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

    class Landscape
    {
        final float _totalSize; // edge length of this total object
        final float _faceSize; // edge length of a face
        final PVector _center;
        final float _visibleSize;
        final int _res; // resolution: the number of faces at a edge
        ArrayList<LandFace> _faceList;

        Landscape(float totalSize, float faceSize, PVector center, float visibleSize)
        {
            _totalSize = totalSize;
            _faceSize = faceSize;
            _center = center;
            _visibleSize = visibleSize;
            _res = (int)(totalSize / faceSize);
        }

        class LandFace
        {
            final PVector _vUL, _vUR, _vLL, _vLR;
            final Triangle _tri1, _tri2;
            Cone _cone1, _cone2;
            float _curSec;
            boolean _isStatic;

            LandFace(PVector vUL, PVector vUR, PVector vLL, PVector vLR)
            {
                _vUL = vUL;
                _vUR = vUR;
                _vLL = vLL;
                _vLR = vLR;

                _tri1 = new Triangle(vUL.copy(), vUR.copy(), vLR.copy());
                _tri2 = new Triangle(vUL.copy(), vLR.copy(), vLL.copy());
            }

            Cone createCone(Triangle triangle, float height)
            {
                PVector inn = triangle.getInner();
                PVector normal = PVector.sub(triangle._v1, triangle._v2)
                                        .cross(PVector.sub(triangle._v2, triangle._v3))
                                        .normalize();
                float r = triangle.getInnerRadius();

                return new Cone(inn, normal, r*.88, height, 8);
            }

            void reset()
            {
                _cone1 = null;
                _cone2 = null;
                _curSec = 0;
                _isStatic = false;
            }

            void updateCones(float maxSec)
            {
                if (_isStatic) { return; }
                _curSec += 1./_frameRate;
                if (_curSec > maxSec) { _isStatic = true; }
                float maxH1 = sqrt(_tri1.getArea()*1.28);
                float maxH2 = sqrt(_tri2.getArea()*1.28);
                //float r = _util.easeOutElastic(_curSec/maxSec);
                float r = _util.easeOutBack(_curSec/maxSec, 16);
                float h1 = maxH1 * r;
                float h2 = maxH2 * r;
                _cone1 = createCone(_tri1, h1);
                _cone2 = createCone(_tri2, h2);
                _cone1.createFaces();
                _cone2.createFaces();
            }

            void drawMe()
            {
                _tri1.drawMe();
                _tri2.drawMe();
                if (_cone1 != null) { _cone1.drawMe(); }
                if (_cone2 != null) { _cone2.drawMe(); }
            }

            PVector getCenter()
            {
                return PVector.add(_vUL, _vUR).add(_vLL).add(_vLR).div(4);
            }
        }

        Rect getRange()
        {
            return new Rect(
                    new PVector(-_totalSize/2, -_totalSize/2).add(_center),
                    new PVector(_totalSize/2, _totalSize/2).add(_center));
        }

        void createFaces()
        {
            PVector[][] vertices = new PVector[_res+1][_res+1];
            float noiseScale = .1;
            for (int i = 0; i <= _res; i++)
            {
                for (int j = 0; j <= _res; j++)
                {
                    float x = map(i, 0, _res, -_totalSize/2, _totalSize/2);
                    float y = map(j, 0, _res, -_totalSize/2, _totalSize/2);
                    float z = (1 - noise(i*noiseScale, j*noiseScale)*2) * 290;
                    PVector offset = PVector.random3D().mult(_faceSize*.5);
                    offset.z = 0;
                    vertices[i][j] = new PVector(x, y, z).add(offset).add(_center);
                }
            }

            _faceList = new ArrayList<LandFace>();
            for (int i = 0; i < _res; i++)
            {
                for (int j = 0; j < _res; j++)
                {
                    LandFace face = new LandFace(vertices[i][j], vertices[i+1][j], vertices[i][j+1], vertices[i+1][j+1]);
                    _faceList.add(face);
                }
            }
        }

        void drawMe(PVector cameraCenter, LandscapeStyle type)
        {
            pushStyle();
            noStroke();
            int n = _faceList.size();
            for (LandFace face : _faceList)
            {
                int alpha = (int)(constrain(_visibleSize / (1+PVector.dist(face.getCenter(), cameraCenter)) - 1.8, 0, 1)*255);
                if (alpha == 0) { face.reset(); continue; }
                if (alpha - 250 > 0) { face.updateCones(.36); }
                setDrawStyle(type, alpha);
                face.drawMe();
            }
            popStyle();
        }

        void setDrawStyle(LandscapeStyle type, int alpha)
        {
            switch (type)
            {
                case NORMAL:
                    noStroke();
                    fill(#e0e0e0, alpha);
                    //fill(#987666, alpha);
                    break;
                case VIRTUAL:
                    stroke(#e00000, alpha);
                    fill(#000000, alpha);
                    break;
                default:
                    break;
            }
        }
    }
}

enum LandscapeStyle
{
    NORMAL,
    VIRTUAL,
}