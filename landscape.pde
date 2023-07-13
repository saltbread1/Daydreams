class Landscape
{
    final float _totalSize; // edge length of this total object
    final float _faceSize; // edge length of a face
    final PVector _center;
    final int _res; // resolution: the number of faces at a edge
    final Rect _range;
    ArrayList<LandFace> _faceList;

    Landscape(float totalSize, float faceSize, PVector center)
    {
        _totalSize = totalSize;
        _faceSize = faceSize;
        _center = center;
        _res = (int)(totalSize / faceSize);
        _range = new Rect(
                    new PVector(-_totalSize/2, -_totalSize/2).add(_center),
                    new PVector(_totalSize/2, _totalSize/2).add(_center));
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

        void drawMe()
        {
            _tri1.drawMe();
            _tri2.drawMe();
            _cone1.drawMe();
            _cone2.drawMe();
        }
    }

    void createFaces()
    {
        PVector[][] vertices = new PVector[_res+1][_res+1];
        float noiseScale = .1;
        for (int i = 0; i <= _res; i++)
        {
            for (int j = 0; j <= _res; j++)
            {
                float x = map(i, 0, _res, -_totalSize/2, _totalSize/2);
                float y = map(j, 0, _res, -_totalSize/2, _totalSize/2);
                float z = 0;//(1 - noise(i*noiseScale, j*noiseScale)*2) * _totalSize * .2;
                PVector offset = PVector.random3D().mult(_faceSize*.5);
                offset.z = 0;
                vertices[i][j] = new PVector(x, y, z)/*.add(offset)*/.add(_center);
            }
        }

        _faceList = new ArrayList<LandFace>();
        for (int i = 0; i < _res; i++)
        {
            for (int j = 0; j < _res; j++)
            {
                LandFace face = new LandFace(vertices[i][j], vertices[i+1][j], vertices[i][j+1], vertices[i+1][j+1]);
                _faceList.add(face);
            }
        }
    }

    void drawMe(PVector cameraCenter)
    {
        pushStyle();
        noStroke();
        //stroke(255);
        int n = _faceList.size();
        for (LandFace face : _faceList)
        {
            //int alpha = (int)(constrain(_totalSize / (1+PVector.dist(face.getCenter(), cameraCenter)) - 1.8, 0, 1)*255);
            int alpha = 255;
            //if (alpha == 0) { println(alpha); }
            fill(#987666, alpha);
            face.drawMe();
        }

        noFill();
        stroke(#ff0000);
        _range.drawMe();
        popStyle();
    }
}