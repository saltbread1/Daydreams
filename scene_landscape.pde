class SceneLandscape extends Scene
{
    Landscape _landscape;
    LandscapeCamera _camera;
    final float _visualChangeSec;
    LandscapeStyle _style;
    LandscapeType _type;

    SceneLandscape(TransitionEffect beginEffect, TransitionEffect endEffect, float totalSceneSec, float visualChangeSec)
    {
        super(beginEffect, endEffect, totalSceneSec);
        _visualChangeSec = visualChangeSec;
        _style = LandscapeStyle.NORMAL;
        _type = LandscapeType.PHASE1;
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
        _camera = new LandscapeCamera(new PVector(0, height, height*.49), limit);
    }

    @Override
    void update()
    {
        ambientLight(32, 32, 32);
        directionalLight(255, 255, 255, -.5, 0, -1);
        changePhase();
        _camera.update();
        if (_type == LandscapeType.PHASE2) { _camera.addVibration(.12, width*.22, PI*.3); }
        _camera.updateCamera();
        _landscape.drawMe();
    }

    @Override
    void postProcessing()
    {
        super.postProcessing();
        _util.resetCamera();
    }

    @Override
    PVector getCameraCenter() { return _camera.getCenter(); }

    void changePhase()
    {
        if (_type == LandscapeType.PHASE1 && _curSec > _visualChangeSec)
        {
            _type = LandscapeType.PHASE2;
            _style = LandscapeStyle.VIRTUAL;
        }
    }

    @Override
    void applyBeginTransitionEffect()
    {
        if (_beginEffect == null) { return; }
        pushMatrix();
        translate(getCameraCenter().x, getCameraCenter().y, getCameraCenter().z);
        rotateX(-PVector.angleBetween(_camera.getCenter2Eye(), new PVector(0, 0, 1)));
        hint(DISABLE_DEPTH_TEST);
        _beginEffect.applyEffect();
        hint(ENABLE_DEPTH_TEST);
        popMatrix();
        _beginEffect.timeCount();
    }
    
    @Override
    void applyEndTransitionEffect()
    {
        if (_endEffect == null) { return; }
        pushMatrix();
        translate(getCameraCenter().x, getCameraCenter().y, getCameraCenter().z);
        rotateX(-PVector.angleBetween(_camera.getCenter2Eye(), new PVector(0, 0, 1)));
        hint(DISABLE_DEPTH_TEST);
        _endEffect.applyEffect();
        hint(ENABLE_DEPTH_TEST);
        popMatrix();
        _endEffect.timeCount();
    }

    class LandscapeCamera extends Camera
    {
        final Rect _limit;
        PVector _startPos, _goalPos;
        float _preStepRad, _stepCurSec, _stepTotalSec, _stepEndSec;

        LandscapeCamera(PVector center2eye, PVector centerPos, Rect limit)
        {
            super(center2eye, centerPos);
            _limit = limit;
            _preStepRad = random(TAU);
        }

        LandscapeCamera(PVector center2eye, Rect limit)
        {
            this(center2eye, new PVector(), limit);
        }

        void setStepParameters()
        {
            PVector virtualGoalPos;
            float rad;
            int c = 0;

            _startPos = _centerPos.copy();
            do
            {
                float d = width + sqrt(random(1))*width*2;
                rad = ++c < 20 ? _preStepRad + random(-1,1)*PI*.4 : _preStepRad + random(-1,1)*PI*.8;
                PVector dir = PVector.fromAngle(rad);
                _stepTotalSec = _type == LandscapeType.PHASE1 ? d*.0013 : d*.0004;
                _stepEndSec = _stepTotalSec * sq(random(.44, .82));
                _goalPos = PVector.add(_startPos, dir.mult(d));
                float r = _util.easeOutQuad(_stepEndSec/_stepTotalSec);
                virtualGoalPos = PVector.mult(_startPos, 1-r).add(PVector.mult(_goalPos, r));
            }
            while (!isInIimitRange(virtualGoalPos));
            
            _preStepRad = rad;
            _stepCurSec = 0;
        }

        void update()
        {
            if (_stepCurSec >= _stepEndSec) { setStepParameters(); }
            float r = _util.easeOutQuad(_stepCurSec/_stepTotalSec);
            _centerPos = PVector.mult(_startPos, 1-r).add(PVector.mult(_goalPos, r));
            _stepCurSec += 1./_frameRate;
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

        void drawMe()
        {
            pushStyle();
            noStroke();
            int n = _faceList.size();
            for (LandFace face : _faceList)
            {
                int alpha = (int)(constrain(_visibleSize / (1+PVector.dist(face.getCenter(), _camera.getCenter())) - 1.8, 0, 1)*255);
                if (alpha == 0) { face.reset(); continue; }
                if (alpha - 250 > 0) { face.updateCones(.36); }
                setDrawStyle(_style, alpha);
                face.drawMe();
            }
            popStyle();
        }

        void setDrawStyle(LandscapeStyle style, int alpha)
        {
            switch (style)
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

enum LandscapeType
{
    PHASE1,
    PHASE2,
}