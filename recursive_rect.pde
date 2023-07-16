class RecursiveRect extends Rect
{
    RecursiveRect _parent;
    final int _rotType, _stepTypeNum;
    int _stepTypeIndex;
    //PVector _magDir;
    float _stepSec, _stepTotalSec;

    RecursiveRect(float width, float height, RecursiveRect parent)
    {
        super(0, 0, width, height);
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
        // _magDir = _type.getDirection().copy();
        // _magDir.x *= _parent._width -  _width;
        // _magDir.y *= _parent._height - _height;
        _stepSec = 0;
        _stepTotalSec = random(.18, .76);
    }

    void updateMe()
    {
        if (_parent == null) { return; }
        if (_stepSec >= _stepTotalSec) { setParameters(); }
        _stepSec += 1./_frameRate;
        
        float r = _util.easeInQuart(_stepSec/_stepTotalSec);
        //_upperLeft = PVector.mult(_magDir, r).add(getStartPosition(_type));
        _upperLeft = PVector.mult(getStartPosition(_stepTypeIndex), 1-r).
                add(PVector.mult(getGoalPosition(_stepTypeIndex), r));
        _lowerRight = new PVector(_width, _height).add(_upperLeft);
    }

    void updateSize(float dh)
    {
        //if (_parent == null) { return; }
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