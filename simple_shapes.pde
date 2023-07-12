class Triangle
{
    final PVector _v1, _v2, _v3;

    Triangle(PVector v1, PVector v2, PVector v3)
    {
        _v1 = v1;
        _v2 = v2;
        _v3 = v3;
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
    { // get the center of gravity
        return PVector.add(_v1, _v2).add(_v3).div(3);
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

    void createFace()
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

    void drawMe()
    {
        for (Triangle face : _faceList) { face.drawMe(); }
    }
}