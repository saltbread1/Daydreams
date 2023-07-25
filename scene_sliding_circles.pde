class SceneSlidingCircles extends Scene
{
    final float _epochSec;
    PGraphics _pg;
    PShader _glitch;
    SlidingType _type;
    SlidingStyle _style;
    CircleManager _cm;

    SceneSlidingCircles(Camera camera, float totalSceneSec, float epochSec)
    {
        super(camera, totalSceneSec);
        _epochSec = epochSec;
    }

    @Override
    void initialize()
    {
        _pg = createGraphics(width, height, P2D);
        _pg.beginDraw();
        _pg.background(#000000);
        _pg.endDraw();
        _glitch = _dm.getGlitchShader();
        _glitch.set("resolution", (float)width, (float)height);
        _type = SlidingType.LINER;
        _style = SlidingStyle.GLITCH1;
        _cm = new CircleManager(6, .32);
        _cm.initialize();
    }

    @Override
    void update()
    {
        changePhase();
        _glitch.set("time", _curSec*16);
        _cm.updateCircles();
        _pg.beginDraw();
        switch (_style)
        {
            case NOGLITCH:
                _pg.background(#000000);
                break;
            case GLITCH1: case GLITCH2:
                _pg.pushStyle();
                _pg.noStroke();
                _pg.fill(#000000, 96);
                _pg.rect(0, 0, width, height);
                _pg.popStyle();
                break;
        }
        _cm.drawCircles(_pg);
        if (_style != SlidingStyle.NOGLITCH) { _pg.filter(_glitch); }
        _pg.endDraw();
        image(_pg, 0, 0);
    }

    void changePhase()
    {
        if (_curSec < _epochSec)
        {
            _type = SlidingType.LINER;
            _style = SlidingStyle.GLITCH1;
        }
        else if (_curSec < _epochSec*2)
        {
            _type = SlidingType.BEZIER1;
            _style = SlidingStyle.GLITCH2;
        }
        else if (_curSec < _epochSec*3)
        {
            _type = SlidingType.BEZIER2;
            _style = SlidingStyle.GLITCH2;
        }
        else
        {
            _type = SlidingType.LINER;
            _style = SlidingStyle.NOGLITCH;
        }
    }

    class SlidingCircle extends Circle
    {
        PVector _start, _goal, _control1, _control2;
        final PVector _stepVec;
        final float _stepTotalSec;
        float _stepSec, _glitchSec, _glitchTotalSec;
        boolean _isGlitch;
        final color[] _glitchPalette = {#00ff00, #ff00ff, #000000, #ffffff};

        SlidingCircle(PVector center, float radius, PVector stepVec, float stepTotalSec)
        {
            super(center, radius, new Attribution(#ffffff, DrawStyle.FILLONLY));
            _stepVec = stepVec;
            _stepTotalSec = stepTotalSec;
            _stepSec = _stepTotalSec;
        }

        void setStepParameters()
        {
            _start = _center.copy();
            _goal = PVector.add(_start, _stepVec);
            float s1 = 0;
            float s2 = 0;
            float t1 = 0;
            float t2 = 0;
            switch (_type)
            {
                case BEZIER1:
                    s1 = random(.5);
                    s2 = 1-random(.5);
                    t1 = random(-.5, .5);
                    t2 = random(-.5, .5);
                    break;
                case BEZIER2:
                    s1 = random(-8, 8);
                    s2 = random(-8, 8)+1;
                    t1 = random(-8, 8);
                    t2 = random(-8, 8);
                    break;

            }
            PVector[] controls = _util.setCubicBezierControls(_start, _goal, s1, s2, t1, t2);
            _control1 = controls[0];
            _control2 = controls[1];
            _stepSec = 0;
        }

        void updateMe()
        {
            if (_glitchSec >= _glitchTotalSec)
            {
                _isGlitch = true;
                _glitchTotalSec = _type == SlidingType.LINER
                        ? sq(random(1))*.86
                        : sq(random(1))*.32;
                _glitchSec = 0;
            }
            if (_stepSec >= _stepTotalSec) { setStepParameters(); }
            float r = _util.easeOutCubic(_stepSec/_stepTotalSec);
            switch (_type)
            {
                case LINER:
                    _center = PVector.mult(_start, 1-r).add(PVector.mult(_goal, r));
                    break;
                case BEZIER1: case BEZIER2:
                    _center = _util.cubicBezierPath(_start, _control1, _control2, _goal, r);
                    break;
            }
            _stepSec += 1./_frameRate;
            _glitchSec += 1./frameRate;
        }

        boolean isDestroy()
        {
            return _stepVec.x < 0
                    ? _center.x + _radius < 0
                    : _center.x - _radius > width;
        }

        @Override
        void drawMe(PGraphics pg)
        {
            super.drawMe(pg);
            if (_isGlitch && _style == SlidingStyle.GLITCH2)
            {
                float thresh = .38;
                float rnd = random(1);
                PVector c = rnd < thresh
                        ? _center
                        : new PVector(random(-1, 1), random(-1, 1)).mult(_radius*1.4).add(_center);
                float r1 = rnd < thresh
                        ? _radius
                        : sq(random(1))*_radius*.8;
                float r2 = rnd < thresh
                        ? _radius
                        : sq(random(1))*_radius*.8;
                color col = rnd < thresh
                        ? #000000
                        : _glitchPalette[(int)random(_glitchPalette.length)];
                pg.rectMode(RADIUS);
                pg.pushStyle();
                pg.noStroke();
                pg.fill(col);
                pg.rect(c.x, c.y, r1, r2);
                pg.popStyle();
                if (rnd >= thresh) { _isGlitch = false; }
            }
        }
    }

    class CircleManager
    {
        final int _circleNum;
        final float _stepTotalSec;
        float _stepSec;
        ArrayList<SlidingCircle> _circleList;

        CircleManager(int circleNum, float stepSec)
        {
            _circleNum = circleNum;
            _stepTotalSec = stepSec;
        }

        void initialize()
        {
            _circleList = new ArrayList<SlidingCircle>();
            for (int i = 0; i < ceil((_circleNum+1)*_stepTotalSec*_frameRate); i++) { updateCircles(); }
        }

        void addCircle()
        {
            float r = width*.04;
            PVector stepVec = new PVector(-width/_circleNum, 0);
            PVector c = new PVector(width-stepVec.x, height/2);
            _circleList.add(new SlidingCircle(c, r, stepVec, _stepTotalSec));
        }

        void updateCircles()
        {
            for (int i = 0; i < _circleList.size(); i++)
            {
                SlidingCircle circle = _circleList.get(i);
                if (circle.isDestroy()) { _circleList.remove(i); }
            }
            if (_stepSec >= _stepTotalSec)
            {
                addCircle();
                _stepSec = 0;
            }
            for (SlidingCircle circle : _circleList) { circle.updateMe(); }
            _stepSec += 1./_frameRate;
        }

        void drawCircles(PGraphics pg)
        {
            for (SlidingCircle circle : _circleList)
            {
                circle.drawMeAttr(pg);
            }
        }
    }
}

enum SlidingType
{
    LINER,
    BEZIER1,
    BEZIER2,
}

enum SlidingStyle
{
    NOGLITCH,
    GLITCH1,
    GLITCH2,
}