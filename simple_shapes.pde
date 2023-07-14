class Triangle
{
    final PVector _v1, _v2, _v3;
    final float _e12, _e23, _e31;
    PVector _cGravity, _cInner;
    float _area, _innerRadius;

    Triangle(PVector v1, PVector v2, PVector v3)
    {
        _v1 = v1;
        _v2 = v2;
        _v3 = v3;

        _e23 = PVector.dist(v2, v3);
        _e31 = PVector.dist(v3, v1);
        _e12 = PVector.dist(v1, v2);
    }

    void translate(PVector dv)
    {
        _v1.add(dv);
        _v2.add(dv);
        _v3.add(dv);
    }

    void drawMe()
    {
        beginShape();
        myVertex(_v1);
        myVertex(_v2);
        myVertex(_v3);
        endShape(CLOSE);
    }

    PVector getCenter()
    {
        if (_cGravity == null)
        {
            _cGravity = PVector.add(_v1, _v2).add(_v3).div(3);
        }
        return _cGravity;
    }

    PVector getInner()
    {
        if (_cInner == null)
        {
            _cInner = PVector.mult(_v1, _e23).add(PVector.mult(_v2, _e31)).add(PVector.mult(_v3, _e12)).div(_e12+_e23+_e31);
        }
        return _cInner;
    }

    float getArea()
    {
        if (_area <= 0) { calcAreaAndInnerRadius(); }
        return _area;
    }

    float getInnerRadius()
    {
        if (_innerRadius <= 0) { calcAreaAndInnerRadius(); }
        return _innerRadius;
    }

    void calcAreaAndInnerRadius()
    {
        float s = (_e23+_e31+_e12)/2;
        _area = sqrt(s*(s-_e23)*(s-_e31)*(s-_e12));
        _innerRadius = _area/s;
    }
}

class Rect
{
    final PVector _upperLeft, _lowerRight;

    Rect(PVector upperLeft, PVector lowerRight)
    {
        _upperLeft = upperLeft;
        _lowerRight = lowerRight;
    }

    void drawMe()
    {
        rectMode(CORNERS);
        rect(_upperLeft.x, _upperLeft.y, _lowerRight.x, _lowerRight.y);
    }

    void translate(PVector dv)
    {
        _upperLeft.add(dv);
        _lowerRight.add(dv);
    }
}

class Cone
{
    final PVector _bottomCenter, _centerAxis;
    final float _radius, _height;
    final int _res;
    ArrayList<Triangle> _faceList;

    Cone(PVector bottomCenter, PVector centerAxis, float radius, float height, int res)
    {
        _bottomCenter = bottomCenter;
        _centerAxis = centerAxis;
        _radius = radius;
        _height = height;
        _res = res;
    }

    void createFaces()
    {
        _faceList = new ArrayList<Triangle>();
        float dtheta = TAU/_res;
        for (int i = 0; i < _res; i++)
        {
            float theta1 = dtheta*i;
            float theta2 = dtheta*(i+1);
            float x1 = _radius * cos(theta1);
            float x2 = _radius * cos(theta2);
            float y1 = _radius * sin(theta1);
            float y2 = _radius * sin(theta2);
            PVector ez = new PVector(0, 0, 1);
            PVector dir = ez.cross(_centerAxis);
            float phi = PVector.angleBetween(ez, _centerAxis);
            PVector v1 = rotate3d(new PVector(x1, y1, 0), dir, phi).add(_bottomCenter);
            PVector v2 = rotate3d(new PVector(x2, y2, 0), dir, phi).add(_bottomCenter);
            PVector v3 = rotate3d(new PVector(0, 0, _height), dir, phi).add(_bottomCenter);
            _faceList.add(new Triangle(v1, v2, v3));
        }
    }

    void translate(PVector dv)
    {
        for (Triangle face : _faceList) { face.translate(dv); }
    }

    void drawMe()
    {
        for (Triangle face : _faceList) { face.drawMe(); }
    }
}