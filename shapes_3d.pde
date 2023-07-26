interface Rotatable3D
{
    void rotate(PVector dir, float rad, PVector init);
}

abstract class SimpleShape3D extends SimpleShape
{
    SimpleShape3D(Attribute attr) { super(attr); }

    SimpleShape3D() {}

    abstract void createFaces();

    abstract void addFace(PVector... v);
}

class Cone extends SimpleShape3D implements Translatable
{
    PVector _bottomCenter, _centerAxis;
    float _radius, _height;
    int _res;
    ArrayList<Triangle> _faceList;

    Cone(PVector bottomCenter, PVector centerAxis, float radius, float height, int res, Attribute attr)
    {
        super(attr);
        _bottomCenter = bottomCenter;
        _centerAxis = centerAxis;
        _radius = radius;
        _height = height;
        _res = res;
    }

    Cone(PVector bottomCenter, PVector centerAxis, float radius, float height, int res)
    {
        this(bottomCenter, centerAxis, radius, height, res, null);
    }

    @Override
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
            PVector v1 = _util.rotate3D(new PVector(x1, y1, 0), dir, phi).add(_bottomCenter);
            PVector v2 = _util.rotate3D(new PVector(x2, y2, 0), dir, phi).add(_bottomCenter);
            PVector v3 = _util.rotate3D(new PVector(0, 0, _height), dir, phi).add(_bottomCenter);
            addFace(v1, v2, v3);
        }
    }

    @Override
    void addFace(PVector... v)
    {
        _faceList.add(new Triangle(v[0], v[1], v[2]));
    }

    @Override
    void drawMe()
    {
        for (Triangle face : _faceList) { face.drawMe(); }
    }

    @Override
    void drawMe(PGraphics pg)
    {
        for (Triangle face : _faceList) { face.drawMe(pg); }
    }
    
    @Override
    void translate(PVector dv)
    {
        for (Triangle face : _faceList) { face.translate(dv); }
    }
}

class Cylinder extends SimpleShape3D
{
    PVector _bottomCenter, _centerAxis;
    float _radius, _height;
    int _res;
    ArrayList<SimpleShape> _faceList;

    Cylinder(PVector bottomCenter, PVector centerAxis, float radius, float height, int res, Attribute attr)
    {
        super(attr);
        _bottomCenter = bottomCenter;
        _centerAxis = centerAxis;
        _radius = radius;
        _height = height;
        _res = res;
    }

    Cylinder(PVector bottomCenter, PVector centerAxis, float radius, float height, int res)
    {
        this(bottomCenter, centerAxis, radius, height, res, null);
    }

    @Override
    void createFaces()
    {
        _faceList = new ArrayList<SimpleShape>();
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
            PVector v1 = _util.rotate3D(new PVector(x1, y1, 0), dir, phi).add(_bottomCenter);
            PVector v2 = _util.rotate3D(new PVector(x2, y2, 0), dir, phi).add(_bottomCenter);
            PVector v3 = _util.rotate3D(new PVector(x2, y2, _height), dir, phi).add(_bottomCenter);
            PVector v4 = _util.rotate3D(new PVector(x1, y1, _height), dir, phi).add(_bottomCenter);
            PVector vc = _util.rotate3D(new PVector(0, 0, _height), dir, phi).add(_bottomCenter);
            addFace(v1, v2, v3, v4, vc);
        }
    }

    @Override
    void addFace(PVector... v)
    {
        _faceList.add(new Quad(v[0], v[1], v[2], v[3]));
        _faceList.add(new Triangle(v[2], v[3], v[4]));
    }

    @Override
    void drawMe()
    {
        for (SimpleShape face : _faceList) { face.drawMe(); }
    }

    @Override
    void drawMe(PGraphics pg)
    {
        for (SimpleShape face : _faceList) { face.drawMe(pg); }
    }
}

class Icosphere extends SimpleShape3D implements Rotatable3D
{
    float _radius;
    int _subdivision;
    ArrayDeque<Triangle> _faceList;

    Icosphere(float radius, int subdivision)
    {
        _radius = radius;
        _subdivision = subdivision;
    }

    @Override
    void createFaces()
    {
        icosahedron();
        for (int i = 0; i < _subdivision; i++) { split(); }
    }

    void icosahedron()
    {
        PVector[] vertices = new PVector[12];
        vertices[0] = new PVector(0., 0., _radius);
        float hrad = 0.;
        float vrad = atan2(1., 2.);
        for (int i = 1; i <= 5; i++)
        {
            float z = _radius * sin(vrad);
            float rxy = _radius * cos(vrad);
            vertices[i] = new PVector(rxy*cos(hrad-PI/5.), rxy*sin(hrad-PI/5.), z);
            vertices[i+5] = new PVector(rxy*cos(hrad), rxy*sin(hrad), -z);
            hrad += TAU/5.;
        }
        vertices[11] = new PVector(0., 0., -_radius);

        _faceList = new ArrayDeque<Triangle>();
        for (int i = 1; i <= 5; i++)
        {
            addFace(vertices[0], vertices[i], vertices[i%5+1]);
            addFace(vertices[i], vertices[i+5], vertices[i%5+1]);
            addFace(vertices[i+5], vertices[i%5+1+5], vertices[i%5+1]);
            addFace(vertices[11], vertices[i%5+1+5], vertices[i+5]);
        }
    }

    void split()
    {
        int len = _faceList.size();
        for (int i = 0; i < len; i++)
        {
            Triangle t = _faceList.poll();
            PVector newv1 = PVector.add(t._v1, t._v2).div(2.);
            PVector newv2 = PVector.add(t._v2, t._v3).div(2.);
            PVector newv3 = PVector.add(t._v3, t._v1).div(2.);
            newv1.mult(_radius / newv1.mag());
            newv2.mult(_radius / newv2.mag());
            newv3.mult(_radius / newv3.mag());
            addFace(t._v1, newv1, newv3);
            addFace(newv1, t._v2, newv2);
            addFace(newv3, newv2, t._v3);
            addFace(newv1, newv2, newv3);
        }
    }

    @Override
    void addFace(PVector... v)
    {
        _faceList.add(new Triangle(v[0], v[1], v[2]));
    }

    @Override
    void drawMe()
    {
        for (Triangle face : _faceList) { face.drawMe(); }
    }

    @Override
    void drawMe(PGraphics pg)
    {
        for (Triangle face : _faceList) { face.drawMe(pg); }
    }

    @Override
    void rotate(PVector dir, float rad, PVector init)
    {
        for (Triangle face : _faceList)
        {
            face.rotate(dir, rad, init);
        }
    }
}

class TriangularPrism extends SimpleShape3D implements Rotatable3D
{
    Triangle _bottomFace;
    float _height;
    PVector _normal;
    ArrayList<SimpleShape> _faceList;

    TriangularPrism(Triangle bottomFace, float height)
    {
        _bottomFace = bottomFace;
        _height = height;
        _normal = PVector.sub(_bottomFace._v2, _bottomFace._v1)
                .cross(PVector.sub(_bottomFace._v3, _bottomFace._v1))
                .normalize();
    }

    TriangularPrism(PVector v1, PVector v2, PVector v3, float height)
    {
        this(new Triangle(v1, v2, v3), height);
    }

    @Override
    void createFaces()
    {
        _faceList = new ArrayList<SimpleShape>();

        Triangle _topFace = _bottomFace.copy();
        _topFace.translate(PVector.mult(_normal, _height));
        addFace(_bottomFace._v1, _topFace._v1, _topFace._v2, _bottomFace._v2);
        addFace(_bottomFace._v2, _topFace._v2, _topFace._v3, _bottomFace._v3);
        addFace(_bottomFace._v3, _topFace._v3, _topFace._v1, _bottomFace._v1);
        _faceList.add(_topFace);
    }

    @Override
    void addFace(PVector... v)
    {
        _faceList.add(new Quad(v[0], v[1], v[2], v[3]));
    }

    @Override
    void drawMe()
    {
        for (SimpleShape face : _faceList) { face.drawMe(); }
    }

    @Override
    void drawMe(PGraphics pg)
    {
        for (SimpleShape face : _faceList) { face.drawMe(pg); }
    }

    @Override
    void rotate(PVector dir, float rad, PVector init)
    {
        for (SimpleShape face : _faceList)
        {
            if (face instanceof Rotatable3D)
            {
                Rotatable3D tmp = (Rotatable3D)face;
                tmp.rotate(dir, rad, init);
            }
        }
    }
}

class QuadPrism extends SimpleShape3D implements Rotatable3D
{
    Quad _bottomFace;
    float _height;
    PVector _normal;
    ArrayList<Quad> _faceList;

    QuadPrism(Quad bottomFace, float height, Attribute attr)
    {
        super(attr);
        _bottomFace = bottomFace;
        _height = height;
        _normal = PVector.sub(_bottomFace._v2, _bottomFace._v1)
                .cross(PVector.sub(_bottomFace._v4, _bottomFace._v1))
                .normalize();
    }

    QuadPrism(Quad bottomFace, float height)
    {
        this(bottomFace, height, null);
    }

    QuadPrism()
    {
        _bottomFace = null;
        _height = 0;
        _normal = null;
    }

    @Override
    void createFaces()
    {
        _faceList = new ArrayList<Quad>();

        Quad _topFace = _bottomFace.copy();
        _topFace.translate(PVector.mult(_normal, _height));
        addFace(_bottomFace._v1, _bottomFace._v2, _topFace._v2, _topFace._v1);
        addFace(_bottomFace._v2, _bottomFace._v3, _topFace._v3, _topFace._v2);
        addFace(_bottomFace._v3, _bottomFace._v4, _topFace._v4, _topFace._v3);
        addFace(_bottomFace._v4, _bottomFace._v1, _topFace._v1, _topFace._v4);
        _faceList.add(_topFace);
    }

    @Override
    void addFace(PVector... v)
    {
        _faceList.add(new Quad(v[0], v[1], v[2], v[3]));
    }

    @Override
    void drawMe()
    {
        for (Quad face : _faceList) { face.drawMe(); }
    }

    @Override
    void drawMe(PGraphics pg)
    {
        for (Quad face : _faceList) { face.drawMe(pg); }
    }

    @Override
    void rotate(PVector dir, float rad, PVector init)
    {
        for (Quad face : _faceList) { face.rotate(dir, rad, init); }
    }
}