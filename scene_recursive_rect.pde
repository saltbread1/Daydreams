class SceneRecursiveRect extends Scene
{
    PGraphics _pg;
    PShader _glitch;
    ArrayDeque<RecursiveRect> _rectQueue;
    RecursiveRect _latest;
    FloatingCircleManager _cm;
    final float _scalingStartSec;
    final float _scale = .5;

    SceneRecursiveRect(Camera camera, float totalSceneSec, float scalingStartSec)
    {
        super(camera, totalSceneSec);
        _scalingStartSec = scalingStartSec;
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

        _latest = new RecursiveRect(width, height);
        _rectQueue = new ArrayDeque<RecursiveRect>();
        _rectQueue.add(_latest);
        float w = width * _scale;
        float h = height * _scale;
        while (w*h > 80)
        {
            RecursiveRect rect = new RecursiveRect(w, h, _latest);
            _rectQueue.add(rect);
            _latest = rect;
            w *= _scale; h *= _scale;
        }
        _cm = new FloatingCircleManager();
        _cm.createCircles(16);
    }

    void addNewRect()
    {
        RecursiveRect rect = new RecursiveRect(_latest.getWidth()*_scale, _latest.getHeight()*_scale, _latest);
        _rectQueue.add(rect);
        _latest = rect;
    }

    @Override
    void update()
    {
        _glitch.set("time", _curSec*16);
        updateShapes();
        drawShapes();
        image(_pg, 0, 0);
    }

    void updateShapes()
    {
        float dh = 8;
        if (_curSec > _scalingStartSec)
        {
            if (_rectQueue.peek().getWidth() > width)
            {
                _rectQueue.poll();
                addNewRect();
            }
            for (RecursiveRect rect : _rectQueue)
            {
                rect.updateSize(dh);
                dh *= _scale;
            }
        }

        for (RecursiveRect rect : _rectQueue)
        {
            rect.updateMe();
            _cm.updateCirclesSize(rect);
        }
        _cm.updateCircles(_curSec*.6);
    }

    void drawShapes()
    {
        _pg.beginDraw();
        _pg.pushStyle();
        _pg.noStroke();
        _pg.fill(#000000, 80);
        _pg.rect(0, 0, width, height);
        _pg.popStyle();
        for (RecursiveRect rect : _rectQueue)
        {
            if (rect._parent != null) { rect.drawMeAttr(_pg); }
        }
        _cm.drawCircles(_pg);
        //if (_curSec > _scalingStartSec) { _pg.filter(_glitch); }
        _pg.filter(_glitch);
        _pg.endDraw();
    }

    class RecursiveRect extends Rect
    {
        float _width, _height;
        final RecursiveRect _parent;
        final int _rotType, _stepTypeNum;
        int _stepTypeIndex;
        float _stepSec, _stepTotalSec;

        RecursiveRect(float width, float height, RecursiveRect parent)
        {
            super(0, 0, width, height, new Attribution(#ffffff, DrawStyle.STROKEONLY));
            _width = width;
            _height = height;
            _parent = parent;
            _rotType = 1-(int)random(2)*2;
            _stepTypeNum = DirectionType.values().length/2;
            _stepTypeIndex = (int)random(_stepTypeNum);
        }

        RecursiveRect(float width, float height)
        {
            this(width, height, null);
        }

        int getNextStepTypeIndex(int stepTypeIndex)
        {
            return (stepTypeIndex + _rotType + _stepTypeNum)%_stepTypeNum;
        }

        void setParameters()
        {
            _stepTypeIndex = getNextStepTypeIndex(_stepTypeIndex);
            _stepSec = 0;
            _stepTotalSec = map(sq(random(1)), 0, 1, .15, .76);
        }

        void updateMe()
        {
            if (_parent == null) { return; }
            if (_stepSec >= _stepTotalSec) { setParameters(); }
            _stepSec += 1./_frameRate;
            
            float r = _util.easeInQuart(_stepSec/_stepTotalSec);
            _upperLeft = PVector.mult(getStartPosition(_stepTypeIndex), 1-r).
                    add(PVector.mult(getGoalPosition(_stepTypeIndex), r));
            _lowerRight = new PVector(_width, _height).add(_upperLeft);
        }

        void updateSize(float dh)
        {
            float ratio = _width/_height;
            _width += dh*ratio;
            _height += dh;
            _lowerRight = new PVector(_width, _height).add(_upperLeft);
        }

        @Override
        void drawMe()
        {
            super.drawMe();
            _util.myLine(_upperLeft, _parent._upperLeft);
            _util.myLine(_lowerRight, _parent._lowerRight);
            line(_upperLeft.x, _lowerRight.y, _parent._upperLeft.x, _parent._lowerRight.y);
            line(_lowerRight.x, _upperLeft.y, _parent._lowerRight.x, _parent._upperLeft.y);
        }

        @Override
        void drawMe(PGraphics pg)
        {
            super.drawMe(pg);
            _util.myLine(_upperLeft, _parent._upperLeft, pg);
            _util.myLine(_lowerRight, _parent._lowerRight, pg);
            pg.line(_upperLeft.x, _lowerRight.y, _parent._upperLeft.x, _parent._lowerRight.y);
            pg.line(_lowerRight.x, _upperLeft.y, _parent._lowerRight.x, _parent._upperLeft.y);
        }

        PVector getStartPosition(int stepTypeIndex)
        {
            DirectionType type = DirectionType.values()[stepTypeIndex*2];
            PVector start = null;

            switch (type)
            {
                case RIGHT:
                    start = _rotType == 1
                        ? new PVector(0, _parent._height-_height)
                        : new PVector(0, 0);
                    break;
                case UP:
                    start = _rotType == 1
                        ? new PVector(_parent._width- _width, _parent._height-_height)
                        : new PVector(0, _parent._height-_height);
                    break;
                case LEFT:
                    start = _rotType == 1
                        ? new PVector(_parent._width- _width, 0)
                        : new PVector(_parent._width- _width, _parent._height-_height);
                    break;
                case DOWN:
                    start = _rotType == 1
                        ? new PVector(0, 0)
                        : new PVector(_parent._width- _width, 0);
                    break;
            }
            return start.add(_parent._upperLeft);
        }

        PVector getGoalPosition(int stepTypeIndex)
        {
            return getStartPosition(getNextStepTypeIndex(stepTypeIndex));
        }
    }

    class FloatingCircle extends Circle
    {
        final float _initRadius;
        final int _seed1, _seed2;

        FloatingCircle(float radius)
        {
            super(new PVector(), radius, new Attribution(color(#ffffff, 216), DrawStyle.FILLONLY));
            _initRadius = radius;
            _seed1 = (int)random(65536);
            _seed2 = (int)random(65536);
        }

        void updateMe(float t)
        {
            float x = _util.easeInOutCubic(noise(t, _seed1))*width;
            float y = _util.easeInOutCubic(noise(t, _seed2))*height;
            _center.set(x, y);
        }

        void updateSize(Rect rect)
        {
            if (!isInRect(rect)) { return; }
            float r = rect.getWidth() / width;
            _radius = _initRadius * r;
        }

        boolean isInRect(Rect rect)
        {
            return _center.x > rect._upperLeft.x && _center.x < rect._lowerRight.x
                && _center.y > rect._upperLeft.y && _center.y < rect._lowerRight.y;
        }
    }

    class FloatingCircleManager
    {
        ArrayList<FloatingCircle> _circleList;

        void createCircles(int n)
        {
            _circleList = new ArrayList<FloatingCircle>();
            for (int i = 0; i < n; i++)
            {
                float r = sq(random(.34, 1))*width*.06;
                _circleList.add(new FloatingCircle(r));
            }
        }

        void updateCircles(float t)
        {
            for (FloatingCircle circle : _circleList) { circle.updateMe(t); }
        }

        void updateCirclesSize(Rect rect)
        {
            for (FloatingCircle circle : _circleList) { circle.updateSize(rect); }
        }

        void drawCircles(PGraphics pg)
        {
            for (FloatingCircle circle : _circleList) { circle.drawMeAttr(pg); }
        }
    }
}