class Landscape
{
    final float _totalSize; // edge length of this total object
    final float _faceSize; // edge length of a face
    final PVector _center;
    final int _res; // resolution: the number of faces at a edge
    final RectCollider _range, _collider, _nextVerticesMemory;
    ArrayList<LandFace> _faceList;

    PVector _dir;
    float _stepCurSec, _stepTotalSec, _speed;

    Landscape(float totalSize, float faceSize, PVector center)
    {
        _totalSize = totalSize;
        _faceSize = faceSize;
        _center = center;
        _res = (int)(totalSize / faceSize);
        PVector rangeUL = new PVector(-_totalSize/2, -_totalSize/2).add(_center);
        PVector rangeLR = new PVector(_totalSize/2, _totalSize/2).add(_center);
        _range = new RectCollider(rangeUL.copy(), rangeLR.copy());
        _nextVerticesMemory = new RectCollider(rangeUL.copy(), rangeLR.copy());
        PVector offset = new PVector(_faceSize, _faceSize);
        rangeUL.add(offset);
        rangeLR.sub(offset);
        _collider = new RectCollider(rangeUL, rangeLR);
    }

    class RectCollider
    {
        final PVector _upperLeft, _lowerRight;

        RectCollider(PVector upperLeft, PVector lowerRight)
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

    class LandFace
    {
        final PVector _vUL, _vUR, _vLL, _vLR;
        final Triangle _tri1, _tri2;
        final Cone _cone1, _cone2;

        LandFace(PVector vUL, PVector vUR, PVector vLL, PVector vLR)
        {
            _vUL = vUL;
            _vUR = vUR;
            _vLL = vLL;
            _vLR = vLR;

            _tri1 = new Triangle(vUL.copy(), vUR.copy(), vLR.copy());
            _tri2 = new Triangle(vUL.copy(), vLR.copy(), vLL.copy());
            _cone1 = createCone(_tri1);
            _cone1.createFaces();
            _cone2 = createCone(_tri2);
            _cone2.createFaces();
        }

        Cone createCone(Triangle triangle)
        {
            PVector v1 = triangle._v1;
            PVector v2 = triangle._v2;
            PVector v3 = triangle._v3;

            float a = PVector.dist(v2, v3);
            float b = PVector.dist(v3, v1);
            float c = PVector.dist(v1, v2);
            float s = (a+b+c)/2;
            float area = sqrt(s*(s-a)*(s-b)*(s-c));
            float r = area*2/(a+b+c);
            PVector inn = PVector.mult(v1, a).add(PVector.mult(v2, b)).add(PVector.mult(v3, c)).div(a+b+c);
            PVector normal = PVector.sub(v1, v2).cross(PVector.sub(v2, v3)).normalize();
            float h = sqrt(area);

            return new Cone(inn, normal, r*.88, h, 8);
        }

        void translate(PVector dv)
        {
            _tri1.translate(dv);
            _tri2.translate(dv);
            _cone1.translate(dv);
            _cone2.translate(dv);
        }

        void drawMe()
        {
            _tri1.drawMe();
            _tri2.drawMe();
            _cone1.drawMe();
            _cone2.drawMe();
        }

        PVector getCenter()
        {
            return PVector.add(_vUL, _vUR).add(_vLL).add(_vLR).div(4);
        }
    }

    void createFaces()
    {
        PVector[][] vertices = new PVector[_res][_res];
        float noiseScale = .1;
        for (int i = 0; i < _res; i++)
        {
            for (int j = 0; j < _res; j++)
            {
                float x = map(i, -1, _res, -_totalSize/2, _totalSize/2);
                float y = map(j, -1, _res, -_totalSize/2, _totalSize/2);
                float z = 0;//(1 - noise(i*noiseScale, j*noiseScale)*2) * _totalSize * .2;
                PVector offset = PVector.random3D().mult(_faceSize*.5);
                offset.z = 0;
                vertices[i][j] = new PVector(x, y, z)/*.add(offset)*/.add(_center);
            }
        }

        _faceList = new ArrayList<LandFace>();
        for (int i = 0; i < _res-1; i++)
        {
            for (int j = 0; j < _res-1; j++)
            {
                LandFace face = new LandFace(vertices[i][j], vertices[i+1][j], vertices[i][j+1], vertices[i+1][j+1]);
                _faceList.add(face);
            }
        }
    }

    // void addLeft()
    // {
    //     for (int i = 0; i < )
    // }

    void setStepParameters()
    {
        _dir = PVector.random2D();
        _stepCurSec = 0;
        _stepTotalSec = 3;
        _speed = 1;
    }

    void updateMe()
    {
        if (_stepCurSec >= _stepTotalSec) { setStepParameters(); }

        PVector dv = PVector.mult(_dir, _speed);
        for (int i = 0; i < _faceList.size(); i++)
        {
            LandFace face = _faceList.get(i);
            face.translate(dv);
            // if (face.getCenter().x < _rangeUL.x)
            // {

            // }
        }
        _collider.translate(dv);
        _nextVerticesMemory.translate(dv);
        _stepCurSec += 1./_frameRate;
    }

    void drawMe()
    {
        pushStyle();
        noStroke();
        //stroke(255);
        int n = _faceList.size();
        for (LandFace face : _faceList)
        {
            //int alpha = (int)(constrain(_totalSize / (1+PVector.dist(face.getCenter(), _center)) - 1.8, 0, 1)*255);
            int alpha = 255;
            //if (alpha == 0) { println(alpha); }
            fill(#987666, alpha);
            face.drawMe();
        }

        noFill();
        stroke(#ff0000);
        _range.drawMe();
        stroke(#00ff00);
        _collider.drawMe();
        stroke(#0000ff);
        _nextVerticesMemory.drawMe();
        popStyle();
    }
}