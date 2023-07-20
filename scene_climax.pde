class SceneClimax extends Scene
{
    FloatingTriangle _triangle;
    ReactShapeManager _cm;
    final float _epochSec;

    SceneClimax(float totalSceneSec, float epochSec)
    {
        super(totalSceneSec);
        _epochSec = epochSec;
    }

    @Override
    void initialize()
    {
        _triangle = new FloatingTriangle(width*.02, width*.8);
        _cm = new ReactShapeManager();
        _cm.initialize();
    }

    @Override
    void update()
    {
        _triangle.updateMe();
        _triangle.updateCamera();

        _cm.updateShapes();
        _cm.drawShapes();

        _triangle.drawMeAttr();
        // drawDebugInfo();
    }

    @Override
    void postProcessing()
    {
        super.postProcessing();
        _util.resetCamera();
    }

    @Override
    void clearScene() { background(#e0e0e0); }

    void drawDebugInfo()
    {
        pushStyle();
        noFill();
        stroke(#00ff00);
        _triangle.drawDebugPath();
        _triangle.getReactionableRange().drawMe();
        popStyle();
    }

    class FloatingTriangle extends Triangle
    {
        final float _sizeRadius, _speed;
        PVector _center, _startPos, _controlPos1, _controlPos2, _goalPos, _magDir;
        float _stepRad;
        FloatList _bezierParams;

        FloatingTriangle(float sizeRadius, float speed)
        {
            super(null, null, null, new AttributionDetail(#ffffff, #000000, DrawStyle.STROKEANDFILL, 2, ROUND));
            _sizeRadius = sizeRadius;
            _speed = speed;
            _center = new PVector();
            _stepRad = random(TAU);
            _bezierParams = new FloatList();
        }

        void setVertices()
        {
            float rad1 = PVector.angleBetween(_magDir, new PVector(1, 0));
            if (_magDir.y < 0) { rad1 *= -1; }
            float rad2 = rad1 + PI - PI*.24;
            float rad3 = rad1 + PI + PI*.24;
            _v1 = PVector.fromAngle(rad1).mult(_sizeRadius).add(_center);
            _v2 = PVector.fromAngle(rad2).mult(_sizeRadius).add(_center);
            _v3 = PVector.fromAngle(rad3).mult(_sizeRadius).add(_center);
        }

        void setStepParameters()
        {
            float m = width*.4; // length of start to goal
            float k1 = random(m*.32, m*.48); // length of start to control1
            float k2 = random(k1*1.6, m*.81); // length of start to control2

            _stepRad += random(-1,1)*PI*.31;

            PVector d = PVector.fromAngle(_stepRad); // direction of start to goal
            _startPos = _center.copy(); // equals previous value of "_goalPos"
            _controlPos1 = _controlPos2 == null
                    ? PVector.mult(d, k1).rotate(random(PI*.16, PI*.41)*(1-(int)random(2)*2)).add(_startPos)
                    : PVector.sub(_startPos, _controlPos2).normalize().mult(k1).add(_startPos);
            
            float rad = PVector.angleBetween(d, PVector.sub(_controlPos1, _startPos));
            _controlPos2 = PVector.mult(d, k2).rotate(random(rad*.23, rad*.79)*(1-(int)random(2)*2)).add(_startPos);
            _goalPos = PVector.add(_startPos, PVector.mult(d, m));

            _bezierParams = _util.calcCubicBezierConstantParams(_startPos, _controlPos1, _controlPos2, _goalPos, _speed);
        }

        void updateMe()
        {
            if (_bezierParams.size() == 0) { setStepParameters(); }
            float r = _bezierParams.get(0);
            _bezierParams.remove(0);
            PVector nextCenter = _util.cubicBezierPath(_startPos, _controlPos1, _controlPos2, _goalPos, r);
            _magDir = PVector.sub(nextCenter, _center);
            _center = nextCenter;
            setVertices();
        }

        void updateCamera()
        {
            camera(_center.x, _center.y, (height/2)/tan(PI/6), _center.x, _center.y, 0, 0, 1, 0);
        }

        void drawDebugPath()
        {
            bezier(_startPos.x, _startPos.y, _controlPos1.x, _controlPos1.y, _controlPos2.x, _controlPos2.y, _goalPos.x, _goalPos.y);
        }

        @Override
        PVector getCenter() { return _center; }

        /**
        * get a circle: "ReactShape" will swell/shrink if its center is inside/outside this circle.
        */
        Circle getReactionableRange()
        {
            PVector c = PVector.mult(_magDir, 2.6).add(_center);
            return new Circle(c, width*.24);
        }

        /**
        * get a circle: "ReactShape" will destroy itself if it is outside this circle.
        */
        Circle getIgnoreRange()
        {
            PVector b = PVector.mult(_magDir, 2.6);
            PVector c = PVector.add(b, _center);
            return new Circle(c, width/2*1.8 + b.mag());
        }
    }

    class ReactUtility
    {
        boolean isInReactionableRange(PVector center)
        {
            Circle range = _triangle.getReactionableRange();
            float d = PVector.dist(center, range._center);
            return d < range._radius;
        }

        Attribution changeAlpha(PVector center, Attribution attr)
        {
            Circle range = _triangle.getReactionableRange();
            int alpha = (int)(constrain(pow(sq(range._radius)/(1+PVector.sub(center, _triangle.getCenter()).magSq()), 3), .24, 1)*255);
            color cStroke = attr._cStroke;
            color cFill = attr._cFill;
            cStroke = color(red(cStroke), green(cStroke), blue(cStroke), alpha);
            cFill = color(red(cFill), green(cFill), blue(cFill), alpha);
            return new Attribution(cStroke, cFill, attr._style);
        }
    }

    class ReactCircle extends Circle implements ReactShape
    {
        final float _maxRadius;
        final float _appearTotalSec;
        float _appearSec;
        boolean _isSwell;
        final ReactUtility _reactUtil;

        ReactCircle(PVector center, float maxRadius, Attribution attr)
        {
            super(center, 0, attr);
            _maxRadius = maxRadius;
            _appearTotalSec = .3;
            _reactUtil = new ReactUtility();
        }

        @Override
        void updateMe()
        {
            float r = 0;
            if (_reactUtil.isInReactionableRange(_center) || _isSwell)
            {
                r = _util.easeOutBack(_appearSec/_appearTotalSec, 8);
                _appearSec += 1./_frameRate;
                _isSwell = _appearSec < _appearTotalSec;
            }
            else
            {
                r = constrain(_appearSec/_appearTotalSec, 0, 1);
                _appearSec -= 1./_frameRate;
            }
            _appearSec = constrain(_appearSec, 0, _appearTotalSec);
            float t = .67;
            _radius = _maxRadius * ((1-t)+r*t);
            setAttribution(_reactUtil.changeAlpha(_center, _attr));
        }

        @Override
        boolean isDestroy()
        {
            Circle range = _triangle.getIgnoreRange();
            float d = PVector.dist(_center, range._center);
            return d > _maxRadius + range._radius;
        }

        @Override
        boolean isOverlap(ReactShape other)
        {
            if (other instanceof ReactCircle)
            {
                ReactCircle circle = (ReactCircle)other;
                float d = PVector.dist(_center, circle._center);
                if (d < _maxRadius + circle._maxRadius) { return true; }
            }
            if (other instanceof ReactRect)
            {
                ReactRect rect = (ReactRect)other;
                float dx = abs(_center.x - rect._center.x);
                float lx = _maxRadius + rect._maxWidth/2;
                float dy = abs(_center.y - rect._center.y);
                float ly = _maxRadius + rect._maxHeight/2;
                if (dx < lx && dy < ly) { return true; }
            }
            else if (other instanceof ReactCylinder)
            {
                ReactCylinder cylinder = (ReactCylinder)other;
                float d = PVector.dist(_center, cylinder._bottomCenter);
                if (d < _maxRadius + cylinder._maxRadius) { return true; }
            }
            return false;
        }
    }

    class ReactRect extends Rect2 implements ReactShape
    {
        final float _maxWidth, _maxHeight;
        final float _appearTotalSec;
        float _appearSec;
        boolean _isSwell;
        final ReactUtility _reactUtil;

        ReactRect(PVector center, float maxWidth, float maxHeight, Attribution attr)
        {
            super(center, 0, 0, attr);
            _maxWidth = maxWidth;
            _maxHeight = maxHeight;
            _appearTotalSec = .3;
            _reactUtil = new ReactUtility();
        }

        @Override
        void updateMe()
        {
            float r = 0;
            if (_reactUtil.isInReactionableRange(_center) || _isSwell)
            {
                r = _util.easeOutBack(_appearSec/_appearTotalSec, 8);
                _appearSec += 1./_frameRate;
                _isSwell = _appearSec < _appearTotalSec;
            }
            else
            {
                r = constrain(_appearSec/_appearTotalSec, 0, 1);
                _appearSec -= 1./_frameRate;
            }
            _appearSec = constrain(_appearSec, 0, _appearTotalSec);
            float t = .67;
            _width = _maxWidth * ((1-t)+r*t);
            _height = _maxHeight * ((1-t)+r*t);
            setAttribution(_reactUtil.changeAlpha(_center, _attr));
        }

        @Override
        boolean isDestroy()
        {
            Circle range = _triangle.getIgnoreRange();
            float d = PVector.dist(_center, range._center);
            return d > max(_maxWidth, _maxHeight) + range._radius;
        }

        @Override
        boolean isOverlap(ReactShape other)
        {
            if (other instanceof ReactCircle)
            {
                ReactCircle circle = (ReactCircle)other;
                float dx = abs(_center.x - circle._center.x);
                float lx = _maxWidth/2 + circle._maxRadius;
                float dy = abs(_center.y - circle._center.y);
                float ly = _maxHeight/2 + circle._maxRadius;
                if (dx < lx && dy < ly) { return true; }
            }
            else if (other instanceof ReactRect)
            {
                ReactRect rect = (ReactRect)other;
                float dx = abs(_center.x - rect._center.x);
                float lx = (_maxWidth + rect._maxWidth)/2;
                float dy = abs(_center.y - rect._center.y);
                float ly = (_maxHeight + rect._maxHeight)/2;
                if (dx < lx && dy < ly) { return true; }
            }
            else if (other instanceof ReactCylinder)
            {
                ReactCylinder cylinder = (ReactCylinder)other;
                float dx = abs(_center.x - cylinder._bottomCenter.x);
                float lx = _maxWidth/2 + cylinder._maxRadius;
                float dy = abs(_center.y - cylinder._bottomCenter.y);
                float ly = _maxHeight/2 + cylinder._maxRadius;
                if (dx < lx && dy < ly) { return true; }
            }
            return false;
        }
    }

    class ReactCylinder extends Cylinder implements ReactShape
    {
        final float _maxRadius, _maxHeight;
        final float _appearTotalSec;
        float _appearSec;
        boolean _isSwell;
        final ReactUtility _reactUtil;

        ReactCylinder(PVector bottomCenter, float maxRadius, float maxHeight, int res, Attribution attr)
        {
            super(bottomCenter, new PVector(0, 0, -1), 0, 0, res, attr);
            _maxRadius = maxRadius;
            _maxHeight = maxHeight;
            _appearTotalSec = .3;
            _reactUtil = new ReactUtility();
        }

        @Override
        void updateMe()
        {
            float r = 0;
            if (_reactUtil.isInReactionableRange(_bottomCenter) || _isSwell)
            {
                r = _util.easeOutBack(_appearSec/_appearTotalSec, 18);
                _appearSec += 1./_frameRate;
                _isSwell = _appearSec < _appearTotalSec;
            }
            else
            {
                r = constrain(_appearSec/_appearTotalSec, 0, 1);
                _appearSec -= 1./_frameRate;
            }
            _appearSec = constrain(_appearSec, 0, _appearTotalSec);
            float t = .67;
            _radius = _maxRadius * ((1-t)+r*t);
            _height = _maxHeight * r;
            setAttribution(_reactUtil.changeAlpha(_bottomCenter, _attr));
            createFaces();
        }

        @Override
        boolean isDestroy()
        {
            Circle range = _triangle.getIgnoreRange();
            float d = PVector.dist(_bottomCenter, range._center);
            return d > _maxRadius + range._radius;
        }

        @Override
        boolean isOverlap(ReactShape other)
        {
            if (other instanceof ReactCircle)
            {
                ReactCircle circle = (ReactCircle)other;
                float d = PVector.dist(_bottomCenter, circle._center);
                if (d < _maxRadius + circle._maxRadius) { return true; }
            }
            if (other instanceof ReactRect)
            {
                ReactRect rect = (ReactRect)other;
                float dx = abs(_bottomCenter.x - rect._center.x);
                float lx = _maxRadius + rect._maxWidth/2;
                float dy = abs(_bottomCenter.y - rect._center.y);
                float ly = _maxRadius + rect._maxHeight/2;
                if (dx < lx && dy < ly) { return true; }
            }
            else if (other instanceof ReactCylinder)
            {
                ReactCylinder cylinder = (ReactCylinder)other;
                float d = PVector.dist(_bottomCenter, cylinder._bottomCenter);
                if (d < _maxRadius + cylinder._maxRadius) { return true; }
            }
            return false;
        }
    }

    class ReactShapeManager
    {
        ArrayList<ReactShape> _shapeList;
        final color[] _palette = {#000000, #900000};

        void initialize()
        {
            _shapeList = new ArrayList<ReactShape>();
        }

        boolean addCircle(int maxTrialIterations)
        {
            float ro = _triangle.getIgnoreRange()._radius;
            float ri = _triangle.getReactionableRange()._radius;
            PVector ci = _triangle.getReactionableRange()._center;
            for (int i = 0; i < maxTrialIterations; i++)
            {
                PVector c = PVector.random2D().mult(random(ri, ro)).add(ci);
                float r = sq(random(1))*width*.055;
                Attribution attr = new Attribution(
                        _palette[(int)random(_palette.length)],
                        random(1) < .5 ? DrawStyle.FILLONLY : DrawStyle.STROKEONLY);
                ReactCircle circle = new ReactCircle(c, r, attr);
                if (!isOverlap(circle))
                {
                    _shapeList.add(circle);
                    return true;
                }
            }
            return false;
        }

        boolean addRect(int maxTrialIterations)
        {
            float ro = _triangle.getIgnoreRange()._radius;
            float ri = _triangle.getReactionableRange()._radius;
            PVector ci = _triangle.getReactionableRange()._center;
            for (int i = 0; i < maxTrialIterations; i++)
            {
                PVector c = PVector.random2D().mult(random(ri, ro)).add(ci);
                float w = sq(random(.2, 1))*width*.12;
                float h = sq(random(.2, 1))*width*.12;
                Attribution attr = new Attribution(
                        _palette[(int)random(_palette.length)],
                        random(1) < .5 ? DrawStyle.FILLONLY : DrawStyle.STROKEONLY);
                ReactRect rect = new ReactRect(c, w, h, attr);
                if (!isOverlap(rect))
                {
                    _shapeList.add(rect);
                    return true;
                }
            }
            return false;
        }

        boolean addCylinder(int maxTrialIterations)
        {
            float ro = _triangle.getIgnoreRange()._radius;
            float ri = _triangle.getReactionableRange()._radius;
            PVector ci = _triangle.getReactionableRange()._center;
            for (int i = 0; i < maxTrialIterations; i++)
            {
                PVector c = PVector.random2D().mult(random(ri, ro)).add(ci);
                float r = sq(random(1))*width*.055;
                float h = random(.8, 1)*width*.14;
                int res = (int)random(5, 9);
                Attribution attr = new Attribution(#ffffff, _palette[(int)random(_palette.length)]);
                ReactCylinder cylinder = new ReactCylinder(c, r, h, res, attr);
                if (!isOverlap(cylinder))
                {
                    _shapeList.add(cylinder);
                    return true;
                }
            }
            return false;
        }

        void addShapes(UpdateType type)
        {
            switch (type)
            {
                case PHASE1:
                    while (addCircle(3));
                    break;
                case PHASE2:
                    while (addCircle(3));
                    while (addRect(3));
                    break;
                case PHASE3:
                    while (addCylinder(3));
                    break;
                case PHASE4:
                    break;
            }
        }

        void updateShapes()
        {
            // if (_curSec < _epochSec) { addShapes(UpdateType.PHASE1); }
            // else if (_curSec < _epochSec*2) { addShapes(UpdateType.PHASE2); }
            // else if (_curSec < _epochSec*3) { addShapes(UpdateType.PHASE3); }
            // else { addShapes(UpdateType.PHASE4); }
            while (addCylinder(3));
            //while (addCircle(3));

            for (int i = 0; i < _shapeList.size(); i++)
            {
                ReactShape shape = _shapeList.get(i);
                if (shape.isDestroy())
                {
                    _shapeList.remove(i--);
                    continue;
                }
                shape.updateMe();
            }
        }

        void drawShapes()
        {
            for (ReactShape shape : _shapeList)
            {
                shape.drawMeAttr();
            }
        }

        boolean isOverlap(ReactShape shape)
        {
            for (ReactShape other : _shapeList)
            {
                if (shape.isOverlap(other)) { return true; }
            }
            return false;
        }
    }
}

interface ReactShape
{
    void updateMe();
    
    void drawMeAttr();

    boolean isDestroy();

    boolean isOverlap(ReactShape other);
}

enum UpdateType
{
    PHASE1,
    PHASE2,
    PHASE3,
    PHASE4,
}