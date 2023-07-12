class Landscape
{
    final float _lenX, _lenY;
    final int _resX, _resY;
    final PVector _center;
    ArrayList<Triangle> _faceList;
    ArrayList<Cone> _coneList;

    Landscape(float lenX, float lenY, int resX, int resY, PVector center)
    {
        _lenX = lenX;
        _lenY = lenY;
        _resX = resX;
        _resY = resY;
        _center = center;
    }

    void createFace()
    {
        PVector[][] vertices = new PVector[_resX][_resY];
        float noiseScale = .1;
        for (int i = 0; i < _resX; i++)
        {
            for (int j = 0; j < _resY; j++)
            {
                float x = map(i, 0, _resX, -_lenX, _lenX);
                float y = map(j, 0, _resY, -_lenY, _lenY);
                float z = (1 - noise(i*noiseScale, j*noiseScale)*2) * 350;
                PVector offset = PVector.random3D();
                offset.x *= _lenX/_resX*.5; offset.y *= _lenY/_resY*.5; offset.z = 0;
                vertices[i][j] = new PVector(x, y, z).add(offset).add(_center);
            }
        }

        _faceList = new ArrayList<Triangle>();
        _coneList = new ArrayList<Cone>();
        for (int i = 0; i < _resX-1; i++)
        {
            for (int j = 0; j < _resY-1; j++)
            {
                Triangle ff1 = new Triangle(vertices[i][j], vertices[i+1][j], vertices[i+1][j+1]);
                Triangle ff2 = new Triangle(vertices[i][j], vertices[i+1][j+1], vertices[i][j+1]);
                _faceList.add(ff1);
                _faceList.add(ff2);
                createShape(ff1);
                createShape(ff2);
            }
        }
    }

    void createShape(Triangle triangle)
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

        Cone cone = new Cone(inn, normal, r*.88, h, 32);
        cone.createFace();
        _coneList.add(cone);
    }

    void drawMe()
    {
        if (_faceList == null || _coneList == null) { exit(); return; }
        pushStyle();
        noStroke();
        fill(#987666);
        for (Triangle face : _faceList) { face.drawMe(); }
        for (Cone cone : _coneList) { cone.drawMe(); }
        popStyle();
    }
}