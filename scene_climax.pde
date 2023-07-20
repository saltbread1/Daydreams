class SceneClimax extends Scene
{
    FloatingTriangle _triangle;
    ReactShapeManager _cm;

    SceneClimax(float totalSceneSec)
    {
        super(totalSceneSec);
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
        // _triangle.drawLight();
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

        void drawLight()
        {
            pushStyle();
            noStroke();
            fill(#ffffff, 30);
            getReactionableRange().drawMe();
            popStyle();
        }
    }

    class ReactCircle extends Circle implements ReactShape
    {
        final float _maxRadius;
        final float _appearTotalSec;
        float _appearSec;
        boolean _isSwell;

        ReactCircle(PVector center, float maxRadius, Attribution attr)
        {
            super(center, 0, attr);
            _maxRadius = maxRadius;
            _appearTotalSec = .3;
        }

        @Override
        void updateMe()
        {
            float r = 0;
            if (isInReactionableRange() || _isSwell)
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
            changeAlpha();
        }

        boolean isInReactionableRange()
        {
            Circle range = _triangle.getReactionableRange();
            float d = PVector.dist(_center, range._center);
            return d < range._radius;
        }

        void changeAlpha()
        {
            Circle range = _triangle.getReactionableRange();
            int alpha = (int)(constrain(pow(sq(range._radius)/(1+PVector.sub(_center, _triangle.getCenter()).magSq()), 3), .24, 1)*255);
            color c = _attr._cFill;
            c = color(red(c), green(c), blue(c), alpha);
            setAttribution(new Attribution(c, _attr._style));
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
            return false;
        }
    }

    class ReactRect extends Rect2 implements ReactShape
    {
        final float _maxWidth, _maxHeight;
        final float _appearTotalSec;
        float _appearSec;
        boolean _isSwell;

        ReactRect(PVector center, float maxWidth, float maxHeight, Attribution attr)
        {
            super(center, 0, 0, attr);
            _maxWidth = maxWidth;
            _maxHeight = maxHeight;
            _appearTotalSec = .3;
        }

        @Override
        void updateMe()
        {
            float r = 0;
            if (isInReactionableRange() || _isSwell)
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
            changeAlpha();
        }

        boolean isInReactionableRange()
        {
            Circle range = _triangle.getReactionableRange();
            float d = PVector.dist(_center, range._center);
            return d < range._radius;
        }

        void changeAlpha()
        {
            Circle range = _triangle.getReactionableRange();
            int alpha = (int)(constrain(pow(sq(range._radius)/(1+PVector.sub(_center, _triangle.getCenter()).magSq()), 3), .24, 1)*255);
            color c = _attr._cFill;
            c = color(red(c), green(c), blue(c), alpha);
            setAttribution(new Attribution(c, _attr._style));
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
            if (other instanceof ReactRect)
            {
                ReactRect rect = (ReactRect)other;
                float dx = abs(_center.x - rect._center.x);
                float lx = (_maxWidth + rect._maxWidth)/2;
                float dy = abs(_center.y - rect._center.y);
                float ly = (_maxHeight + rect._maxHeight)/2;
                if (dx < lx && dy < ly) { return true; }
            }
            return false;
        }
    }

    class ReactShapeManager
    {
        ArrayList<ReactShape> _shapeList;

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
                Attribution attr = random(1) < .5
                        ? new Attribution(#000000, random(1) < .5 ? DrawStyle.FILLONLY : DrawStyle.STROKEONLY)
                        : new Attribution(#900000, random(1) < .5 ? DrawStyle.FILLONLY : DrawStyle.STROKEONLY);
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
                Attribution attr = random(1) < .5
                        ? new Attribution(#000000, random(1) < .5 ? DrawStyle.FILLONLY : DrawStyle.STROKEONLY)
                        : new Attribution(#900000, random(1) < .5 ? DrawStyle.FILLONLY : DrawStyle.STROKEONLY);
                ReactRect rect = new ReactRect(c, w, h, attr);
                if (!isOverlap(rect))
                {
                    _shapeList.add(rect);
                    return true;
                }
            }
            return false;
        }

        boolean isOverlap(ReactShape shape)
        {
            for (ReactShape other : _shapeList)
            {
                if (shape.isOverlap(other)) { return true; }
            }
            return false;
        }

        void updateShapes()
        {
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
            while (addCircle(3));
            while (addRect(3));
        }

        void drawShapes()
        {
            for (ReactShape shape : _shapeList)
            {
                shape.drawMeAttr();
            }
        }
    }
}

interface ReactShape
{
    void updateMe();

    void drawMe();

    void drawMeAttr();

    boolean isDestroy();

    boolean isOverlap(ReactShape other);
}