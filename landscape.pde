class Landscape
{
    final float _totalSize; // edge length of this total object
    final float _faceSize; // edge length of one face
    final PVector _center;
    final int _res;
    ArrayList<Triangle> _faceList;
    ArrayList<Cone> _coneList;

    Landscape(float totalSize, float faceSize, PVector center)
    {
        _totalSize = totalSize;
        _faceSize = faceSize;
        _center = center;
        _res = (int)(totalSize / faceSize);
    }

    void createFaces()
    {
        PVector[][] vertices = new PVector[_res][_res];
        float noiseScale = .1;
        for (int i = 0; i < _res; i++)
        {
            for (int j = 0; j < _res; j++)
            {
                float x = map(i, 0, _res, -_totalSize/2, _totalSize/2);
                float y = map(j, 0, _res, -_totalSize/2, _totalSize/2);
                float z = 0;//(1 - noise(i*noiseScale, j*noiseScale)*2) * _totalSize * .2;
                PVector offset = PVector.random3D();
                offset.x *= _totalSize/_res*.5; offset.y *= _totalSize/_res*.5; offset.z = 0;
                vertices[i][j] = new PVector(x, y, z)/*.add(offset)*/.add(_center);
            }
        }

        _faceList = new ArrayList<Triangle>();
        _coneList = new ArrayList<Cone>();
        for (int i = 0; i < _res-1; i++)
        {
            for (int j = 0; j < _res-1; j++)
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
        pushStyle();
        //noStroke();
        stroke(255);
        // for (Triangle face : _faceList) { face.drawMe(); }
        // for (Cone cone : _coneList) { cone.drawMe(); }
        int n = _faceList.size();
        for (int i = 0; i < n; i++)
        {
            Triangle face = _faceList.get(i);
            Cone cone = _coneList.get(i);
            int alpha = (int)(constrain(_totalSize / (1+PVector.dist(face.getCenter(), _center)) - 1.8, 0, 1)*255);
            //if (alpha == 0) { println(alpha); }
            fill(#987666, /*alpha*/255);
            face.drawMe();
            //cone.drawMe();
        }
        popStyle();
    }
}