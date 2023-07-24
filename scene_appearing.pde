class SceneAppearing extends Scene
{
    PGraphics _pg;
    PShader _glitch;
    CircleManager _cm;
    int[] _createNum = {8, 24, 48, 128};
    int _createIndex;
    
    SceneAppearing(Camera camera, float totalSceneSec)
    {
        super(camera, totalSceneSec);
    }

    @Override
    void initialize()
    {
        _pg = createGraphics(width, height, P3D);
        _glitch = _dm.getGlitchShader();
        _glitch.set("resolution", (float)width, (float)height);
        _cm = new CircleManager(.6, .75, 1.3);
    }

    @Override
    void update()
    {
        _glitch.set("time", _curSec*16);
        if (_cm.isUpdateEnd() && _createIndex < _createNum.length)
        {
            _cm.createCircles(_createNum[_createIndex++]);
        }
        _cm.updateCircles();
        _pg.beginDraw();
        _pg.background(#000000);
        _cm.drawCircles(_pg);
        _pg.filter(_glitch);
        _pg.endDraw();
        image(_pg, 0, 0);
    }

    class AppearingCircle extends Circle
    {
        final float _maxRadius;
        float _appearSec, _vanishSec;

        AppearingCircle(PVector center, float maxRadius)
        {
            super(center, maxRadius, new Attribution(#ffffff, DrawStyle.FILLONLY));
            _maxRadius = maxRadius;
        }

        void appear(float totalSec)
        {
            float r = _util.easeOutCubic(_appearSec/totalSec);
            _radius = _maxRadius * r;
            _appearSec += 1./_frameRate;
        }

        void vanish(float totalSec)
        {
            float r = _util.easeInQuad(_vanishSec/totalSec);
            setAttribution(new Attribution(lerpColor(#ffffff, #000000, r), DrawStyle.FILLONLY));
            _vanishSec += 1./_frameRate;
        }
    }

    class CircleManager
    {
        ArrayList<AppearingCircle> _circleList;
        final float _appearSec, _vanishSec, _waitSec;
        float _stepSec;

        CircleManager(float appearSec, float vanishSec, float waitSec)
        {
            _appearSec = appearSec;
            _vanishSec = vanishSec;
            _waitSec = waitSec;
            _stepSec = appearSec+vanishSec+waitSec+1;
        }

        void createCircles(int n)
        {
            _stepSec = 0;
            _circleList = new ArrayList<AppearingCircle>();
            for (int i = 0; i < n; i++)
            {
                if (!addCircle(128)) { break; }
            }
        }

        boolean addCircle(int maxTrialIterations)
        {
            for (int i = 0; i < maxTrialIterations; i++)
            {
                float r = sq(random(.3, 1))*width*.08;
                PVector c = new PVector(random(width), random(height));
                AppearingCircle circle = new AppearingCircle(c, r);
                if (!isOverlap(circle))
                {
                    _circleList.add(circle);
                    return true;
                }
            }
            return false;
        }

        boolean isOverlap(AppearingCircle circle)
        {
            for (AppearingCircle other : _circleList)
            {
                float d = PVector.dist(other._center, circle._center);
                if (d < other._radius + circle._radius)
                {
                    return true;
                }
            }
            return false;
        }

        void updateCircles()
        {
            for (AppearingCircle circle : _circleList)
            {
                if (_stepSec < _appearSec) { circle.appear(_appearSec); }
                else if (_stepSec > _appearSec+_waitSec) { circle.vanish(_vanishSec); }
            }
            _stepSec += 1./_frameRate;
        }

        void drawCircles(PGraphics pg)
        {
            for (AppearingCircle circle : _circleList) { circle.drawMeAttr(pg); }
        }

        boolean isUpdateEnd() { return _stepSec > _appearSec+_vanishSec+_waitSec; }
    }
}