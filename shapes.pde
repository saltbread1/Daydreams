enum DrawStyle
{
    STROKEONLY,
    FILLONLY,
    STROKEANDFILL,
}

class Attribution
{
    final color _cStroke, _cFill;
    final DrawStyle _style;

    Attribution(color cStroke, color cFill, DrawStyle style)
    {
        _cStroke = cStroke;
        _cFill = cFill;
        _style = style;
    }

    Attribution(color cStroke, color cFill)
    {
        this(cStroke, cFill, DrawStyle.STROKEANDFILL);
    }

    Attribution(color colour, DrawStyle style)
    {
        this(colour, colour, style);
    }

    Attribution()
    { // default colors
        _cStroke = #000000;
        _cFill = #ffffff;
        _style = null;
    }

    void apply()
    {
        if (_style == null) { return; }

        switch (_style)
        {
            case STROKEONLY:
                stroke(_cStroke);
                noFill();
                break;
            case FILLONLY:
                noStroke();
                fill(_cFill);
                break;
            case STROKEANDFILL:
                stroke(_cStroke);
                fill(_cFill);
                break;
        }
    }

    void apply(PGraphics pg)
    {
        if (_style == null) { return; }

        switch (_style)
        {
            case STROKEONLY:
                pg.stroke(_cStroke);
                pg.noFill();
                break;
            case FILLONLY:
                pg.noStroke();
                pg.fill(_cFill);
                break;
            case STROKEANDFILL:
                pg.stroke(_cStroke);
                pg.fill(_cFill);
                break;
        }
    }

    @Override
    boolean equals(Object o)
    {
        if (o == null || !(o instanceof Attribution)) { return false; }
        Attribution other = (Attribution)o;
        if (_cStroke == other._cStroke && _cFill == other._cFill && _style == other._style)
        {
            return true;
        }
        return false;
    }
}

class AttributionDetail extends Attribution
{
    final float _strokeW;
    final int _capType; // stroke cap: ROUND, SQUARE, PROJECT

    AttributionDetail(color cStroke, color cFill, DrawStyle style, float strokeW, int capType)
    {
        super(cStroke, cFill, style);
        _strokeW = strokeW;
        _capType = capType;
    }

    AttributionDetail(color cStroke, color cFill, float strokeW, int capType)
    {
        this(cStroke, cFill, DrawStyle.STROKEANDFILL, strokeW, capType);
    }

    AttributionDetail(color colour, DrawStyle style, float strokeW, int capType)
    {
        this(colour, colour, style, strokeW, capType);
    }

    AttributionDetail()
    {
        _strokeW = 1;
        _capType = ROUND;
    }

    void apply()
    {
        super.apply();
        strokeWeight(_strokeW);
        strokeCap(_capType);
    }

    void apply(PGraphics pg)
    {
        super.apply(pg);
        pg.strokeWeight(_strokeW);
        pg.strokeCap(_capType);
    }
}

interface Translatable
{
    void translate(PVector dv);
}

interface Rotatable
{
    void rotate(float rad, PVector init);
}

interface Rotatable3D
{
    void rotate(PVector dir, float rad, PVector init);
}

abstract class SimpleShape
{
    Attribution _attr;

    SimpleShape(Attribution attr) { _attr = attr; }

    SimpleShape() { _attr = null; }

    final void setAttribution(Attribution attr) { _attr = attr; }

    final Attribution getAttribution() { return _attr; }

    void drawMeAttr()
    {
        pushStyle();
        if (_attr != null) { _attr.apply(); }
        drawMe();
        popStyle();
    }

    void drawMeAttr(PGraphics pg)
    {
        pg.pushStyle();
        if (_attr != null) { _attr.apply(pg); }
        drawMe(pg);
        pg.popStyle();
    }

    abstract void drawMe();

    abstract void drawMe(PGraphics pg);
}

abstract class SimpleShape3D extends SimpleShape
{
    SimpleShape3D(Attribution attr) { super(attr); }

    SimpleShape3D() {}

    abstract void createFaces();
}

class Triangle extends SimpleShape implements Translatable, Rotatable, Rotatable3D
{
    PVector _v1, _v2, _v3;

    Triangle(PVector v1, PVector v2, PVector v3, Attribution attr)
    {
        super(attr);
        _v1 = v1;
        _v2 = v2;
        _v3 = v3;
    }

    Triangle(PVector v1, PVector v2, PVector v3)
    {
        this(v1, v2, v3, null);
    }

    Triangle copy() { return new Triangle(_v1.copy(), _v2.copy(), _v3.copy(), _attr); }

    @Override
    void drawMe()
    {
        beginShape();
        _util.myVertex(_v1);
        _util.myVertex(_v2);
        _util.myVertex(_v3);
        endShape(CLOSE);
    }

    @Override
    void drawMe(PGraphics pg)
    {
        pg.beginShape();
        _util.myVertex(_v1, pg);
        _util.myVertex(_v2, pg);
        _util.myVertex(_v3, pg);
        pg.endShape(CLOSE);
    }

    @Override
    void translate(PVector dv)
    {
        _v1.add(dv);
        _v2.add(dv);
        _v3.add(dv);
    }

    @Override
    void rotate(float rad, PVector init)
    {
        _v1 = _util.rotate(_v1, rad, init);
        _v2 = _util.rotate(_v2, rad, init);
        _v3 = _util.rotate(_v3, rad, init);
    }

    @Override
    void rotate(PVector dir, float rad, PVector init)
    {
        _v1 = _util.rotate3D(_v1, dir, rad, init);
        _v2 = _util.rotate3D(_v2, dir, rad, init);
        _v3 = _util.rotate3D(_v3, dir, rad, init);
    }

    PVector getCenter()
    {
        return PVector.add(_v1, _v2).add(_v3).div(3);
    }

    float[] getEdges()
    {
        float[] edges = new float[3];
        edges[0] = PVector.dist(_v1, _v2);
        edges[1] = PVector.dist(_v2, _v3);
        edges[2] = PVector.dist(_v3, _v1);
        return edges;
    }
    
    PVector getInner()
    {
        float[] edges = getEdges();
        return PVector.mult(_v1, edges[1])
                .add(PVector.mult(_v2, edges[2]))
                .add(PVector.mult(_v3, edges[0]))
                .div(edges[0]+edges[1]+edges[2]);
    }

    float getArea()
    {
        float[] edges = getEdges();
        float s = (edges[0]+edges[1]+edges[2])/2;
        return sqrt(s*(s-edges[0])*(s-edges[1])*(s-edges[2]));
    }

    float getInnerRadius()
    {
        float[] edges = getEdges();
        float s = (edges[0]+edges[1]+edges[2])/2;
        return sqrt(s*(s-edges[0])*(s-edges[1])*(s-edges[2])) / s;
    }
}

class Rect extends SimpleShape implements Translatable
{ // for only 2D renderer
    PVector _upperLeft, _lowerRight;

    Rect(PVector upperLeft, PVector lowerRight, Attribution attr)
    {
        super(attr);
        _upperLeft = upperLeft;
        _lowerRight = lowerRight;
    }

    Rect(PVector upperLeft, PVector lowerRight)
    {
        this(upperLeft, lowerRight, null);
    }

    Rect(PVector upperLeft, float width, float height, Attribution attr)
    {
        this(upperLeft, new PVector(width, height).add(upperLeft), attr);
    }

    Rect(PVector upperLeft, float width, float height)
    {
        this(upperLeft, width, height, null);
    }

    Rect(float x, float y, float width, float height, Attribution attr)
    {
        this(new PVector(x, y), width, height, attr);
    }

    Rect(float x, float y, float width, float height)
    {
        this(x, y, width, height, null);
    }

    @Override
    void drawMe()
    {
        rectMode(CORNERS);
        rect(_upperLeft.x, _upperLeft.y, _lowerRight.x, _lowerRight.y);
    }

    @Override
    void drawMe(PGraphics pg)
    {
        pg.rectMode(CORNERS);
        pg.rect(_upperLeft.x, _upperLeft.y, _lowerRight.x, _lowerRight.y);
    }

    @Override
    void translate(PVector dv)
    {
        _upperLeft.add(dv);
        _lowerRight.add(dv);
    }

    float getWidth() { return _lowerRight.x - _upperLeft.x; }

    float getHeight() { return _lowerRight.y - _upperLeft.y; }

    PVector getCenter()
    {
        return PVector.add(_upperLeft, _lowerRight).div(2);
    }
}

class Rect2 extends SimpleShape implements Translatable
{ // center base
    PVector _center;
    float _width, _height;

    Rect2(PVector center, float width, float height, Attribution attr)
    {
        super(attr);
        _center = center;
        _width = width;
        _height = height;
    }

    Rect2(PVector center, float width, float height)
    {
        this(center, width, height, null);
    }

    @Override
    void drawMe()
    {
        rectMode(CENTER);
        rect(_center.x, _center.y, _width, _height);
    }

    @Override
    void drawMe(PGraphics pg)
    {
        pg.rectMode(CENTER);
        pg.rect(_center.x, _center.y, _width, _height);
    }

    @Override
    void translate(PVector dv)
    {
        _center.add(dv);
        _center.add(dv);
    }

    PVector getCenter() { return _center; }
}

class Quad extends SimpleShape implements Translatable, Rotatable, Rotatable3D
{
    PVector _v1, _v2, _v3, _v4;

    Quad(PVector v1, PVector v2, PVector v3, PVector v4, Attribution attr)
    {
        super(attr);
        _v1 = v1;
        _v2 = v2;
        _v3 = v3;
        _v4 = v4;
    }

    Quad(PVector v1, PVector v2, PVector v3, PVector v4)
    {
        this(v1, v2, v3, v4, null);
    }

    Quad copy() { return new Quad(_v1.copy(), _v2.copy(), _v3.copy(), _v4.copy(), _attr); }

    @Override
    void drawMe()
    {
        beginShape(QUADS);
        _util.myVertex(_v1);
        _util.myVertex(_v2);
        _util.myVertex(_v3);
        _util.myVertex(_v4);
        endShape();
    }

    @Override
    void drawMe(PGraphics pg)
    {
        pg.beginShape(QUADS);
        _util.myVertex(_v1, pg);
        _util.myVertex(_v2, pg);
        _util.myVertex(_v3, pg);
        _util.myVertex(_v4, pg);
        pg.endShape();
    }

    @Override
    void translate(PVector dv)
    {
        _v1.add(dv);
        _v2.add(dv);
        _v3.add(dv);
        _v4.add(dv);
    }

    @Override
    void rotate(float rad, PVector init)
    {
        _v1 = _util.rotate(_v1, rad, init);
        _v2 = _util.rotate(_v2, rad, init);
        _v3 = _util.rotate(_v3, rad, init);
        _v4 = _util.rotate(_v4, rad, init);
    }

    @Override
    void rotate(PVector dir, float rad, PVector init)
    {
        _v1 = _util.rotate3D(_v1, dir, rad, init);
        _v2 = _util.rotate3D(_v2, dir, rad, init);
        _v3 = _util.rotate3D(_v3, dir, rad, init);
        _v4 = _util.rotate3D(_v4, dir, rad, init);
    }

    PVector getCenter()
    {
        return PVector.add(_v1, _v2).add(_v3).add(_v4).div(4);
    }

    float[] getEdges()
    {
        float[] edges = new float[4];
        edges[0] = PVector.dist(_v1, _v2);
        edges[1] = PVector.dist(_v2, _v3);
        edges[2] = PVector.dist(_v3, _v4);
        edges[3] = PVector.dist(_v4, _v1);
        return edges;
    }

    float getArea()
    {
        float[] edges = getEdges();
        float e12 = edges[0];
        float e23 = edges[1];
        float e34 = edges[2];
        float e41 = edges[3];
        // Bretschneider's formula
        float t = (e12 + e23 + e34 + e41)/2;
        float a = PVector.angleBetween(PVector.sub(_v2, _v1), PVector.sub(_v4, _v1));
        float c = PVector.angleBetween(PVector.sub(_v2, _v3), PVector.sub(_v4, _v3));
        return sqrt( (t-e12)*(t-e23)*(t-e34)*(t-e41) - e12*e23*e34*e41*sq(cos((a+c)/2)) );
    }
}

class DevidedQuad extends Quad
{
    final PVector _e1v1, _e1v2, _e2v1, _e2v2;
    final PVector _c1v1, _c1v2, _c2v1, _c2v2;
    final float _endArea, _minEndArea, _maxEndArea;
    final DevidedQuad _parent;
    DevidedQuad _child1, _child2;
    final int _seed1, _seed2;

    DevidedQuad(PVector v1, PVector v2, PVector v3, PVector v4, float minEndArea, float maxEndArea, DevidedQuad parent)
    {
        super(v1, v2, v3, v4);

        if (PVector.sub(v2, v1).mag() + PVector.sub(v4, v3).mag()
            > PVector.sub(v2, v3).mag() + PVector.sub(v4, v1).mag())
        {
            _e1v1 = v1; _e1v2 = v2; _e2v1 = v3; _e2v2 = v4;
            _c1v1 = v4; _c1v2 = v1; _c2v1 = v3; _c2v2 = v2;
        }
        else
        {
            _e1v1 = v2; _e1v2 = v3; _e2v1 = v4; _e2v2 = v1;
            _c1v1 = v1; _c1v2 = v2; _c2v1 = v4; _c2v2 = v3;
        }
        _minEndArea = minEndArea;
        _maxEndArea = maxEndArea;
        _endArea = minEndArea + sq(random(1))*(maxEndArea-minEndArea);
        _parent = parent;
        _seed1 = (int)random(65536);
        _seed2 = (int)random(65536);
    }

    DevidedQuad(PVector v1, PVector v2, PVector v3, PVector v4, float minEndArea, float maxEndArea)
    {
        this(v1, v2, v3, v4, minEndArea, maxEndArea, null);
    }

    void initialize()
    {
        createChildren();
        updateMe(0, 0);
    }

    void createChildren()
    {
        if (getArea() <= _endArea)
        {
            _child1 = null;
            _child2 = null;
            return;
        }
        float s1 = random(1);
        float s2 = random(1);
        PVector vd1 = PVector.mult(_e1v1, s1).add(PVector.mult(_e1v2, 1-s1));
        PVector vd2 = PVector.mult(_e2v1, s2).add(PVector.mult(_e2v2, 1-s2));
        _child1 = new DevidedQuad(_c1v1, _c1v2, vd1, vd2, _minEndArea, _maxEndArea, this);
        _child2 = new DevidedQuad(_c2v1, _c2v2, vd1, vd2, _minEndArea, _maxEndArea, this);
        _child1.createChildren();
        _child2.createChildren();
    }

    void trasform(float t, float scale)
    {
        if (_parent == null) { return; }

        //scale = (float)mouseX/width;
        float s1 = constrain(.5 + (1-noise(t, _seed1)*2)/2 * scale*1.5, 0, 1);
        float s2 = constrain(.5 + (1-noise(t, _seed2)*2)/2 * scale*1.5, 0, 1);
        PVector v3 = PVector.mult(_parent._e1v1, s1).add(PVector.mult(_parent._e1v2, 1-s1));
        PVector v4 = PVector.mult(_parent._e2v1, s2).add(PVector.mult(_parent._e2v2, 1-s2));
        _v3.set(v3.x, v3.y, v3.z);
        _v4.set(v4.x, v4.y, v4.z);
    }

    void updateMe(float t, float scale)
    {
        if (!isChildren()) { return; }
        _child1.trasform(t, scale);
        _child2.trasform(t, scale);
        _child1.updateMe(t, scale);
        _child2.updateMe(t, scale);
    }

    @Override
    void drawMeAttr()
    {
        if (!isChildren())
        {
            super.drawMeAttr();
            return;
        }
        _child1.drawMeAttr();
        _child2.drawMeAttr();
    }

    boolean isChildren()
    {
        return _child1 != null && _child2 != null;
    }

    void getAllChildren(ArrayList<Quad> _childrenList)
    {
        if (!isChildren())
        {
            _childrenList.add(this);
            return;
        }
        _child1.getAllChildren(_childrenList);
        _child2.getAllChildren(_childrenList);
    }
}


class Circle extends SimpleShape implements Translatable, Rotatable
{
    PVector _center;
    float _radius;

    Circle(PVector center, float radius, Attribution attr)
    {
        super(attr);
        _center = center;
        _radius = radius;
    }

    Circle(PVector center, float radius)
    {
        this(center, radius, null);
    }

    Circle(float x, float y, float radius, Attribution attr)
    {
        this(new PVector(x, y), radius, attr);
    }

    Circle(float x, float y, float radius)
    {
        this(x, y, radius, null);
    }

    @Override
    void drawMe()
    {
        circle(_center.x, _center.y, _radius*2);
    }

    @Override
    void drawMe(PGraphics pg)
    {
        pg.circle(_center.x, _center.y, _radius*2);
    }

    @Override
    void translate(PVector dv)
    {
        _center.add(dv);
    }

    @Override
    void rotate(float rad, PVector init)
    {
        _center = _util.rotate(_center, rad, init);
    }

    PVector getCenter() { return _center; }
}

class Arc extends Circle
{
    float _startRad, _stopRad;
    int _mode;

    Arc(PVector center, float radius, float startRad, float stopRad, int mode, Attribution attr)
    {
        super(center, radius, attr);
        _startRad = startRad;
        _stopRad = stopRad;
        _mode = mode;
    }

    Arc(PVector center, float radius, float startRad, float stopRad, int mode)
    {
        this(center, radius, startRad, stopRad, mode, null);
    }

    Arc(float x, float y, float radius, float startRad, float stopRad, int mode, Attribution attr)
    {
        this(new PVector(x, y), radius, startRad, stopRad, mode, attr);
    }

    Arc(float x, float y, float radius, float startRad, float stopRad, int mode)
    {
        this(x, y, radius, startRad, stopRad, mode, null);
    }

    @Override
    void drawMe()
    {
        arc(_center.x, _center.y, _radius*2, _radius*2, _startRad, _stopRad, _mode);
    }

    @Override
    void drawMe(PGraphics pg)
    {
        pg.arc(_center.x, _center.y, _radius*2, _radius*2, _startRad, _stopRad, _mode);
    }

    @Override
    void rotate(float rad, PVector init)
    {
        super.rotate(rad, init);
        rotate(rad);
    }

    void rotate(float rad)
    {
        _startRad += rad;
        _stopRad += rad;
    }
}

class Cone extends SimpleShape3D implements Translatable
{
    PVector _bottomCenter, _centerAxis;
    float _radius, _height;
    int _res;
    ArrayList<Triangle> _faceList;

    Cone(PVector bottomCenter, PVector centerAxis, float radius, float height, int res)
    {
        _bottomCenter = bottomCenter;
        _centerAxis = centerAxis;
        _radius = radius;
        _height = height;
        _res = res;
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
            _faceList.add(new Triangle(v1, v2, v3));
        }
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
            _faceList.add(new Triangle(vertices[0], vertices[i], vertices[i%5+1]));
            _faceList.add(new Triangle(vertices[i], vertices[i+5], vertices[i%5+1]));
            _faceList.add(new Triangle(vertices[i+5], vertices[i%5+1+5], vertices[i%5+1]));
            _faceList.add(new Triangle(vertices[11], vertices[i%5+1+5], vertices[i+5]));
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
            _faceList.add(new Triangle(t._v1 , newv1, newv3));
            _faceList.add(new Triangle(newv1, t._v2 , newv2));
            _faceList.add(new Triangle(newv3, newv2, t._v3 ));
            _faceList.add(new Triangle(newv1, newv2, newv3));
        }
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
        Quad face1 = new Quad(_bottomFace._v1, _topFace._v1, _topFace._v2, _bottomFace._v2);
        Quad face2 = new Quad(_bottomFace._v2, _topFace._v2, _topFace._v3, _bottomFace._v3);
        Quad face3 = new Quad(_bottomFace._v3, _topFace._v3, _topFace._v1, _bottomFace._v1);
        _faceList.add(face1);
        _faceList.add(face2);
        _faceList.add(face3);
        _faceList.add(_bottomFace);
        _faceList.add(_topFace);
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