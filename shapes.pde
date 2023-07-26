interface Translatable
{
    void translate(PVector dv);
}

interface Rotatable
{
    void rotate(float rad, PVector init);
}

abstract class SimpleShape
{
    Attribute _attr;

    SimpleShape(Attribute attr) { _attr = attr; }

    SimpleShape() { _attr = null; }

    final void setAttribute(Attribute attr) { _attr = attr; }

    final Attribute getAttribute() { return _attr; }

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

class Triangle extends SimpleShape implements Translatable, Rotatable, Rotatable3D
{
    PVector _v1, _v2, _v3;

    Triangle(PVector v1, PVector v2, PVector v3, Attribute attr)
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
        beginShape(TRIANGLES);
        _util.myVertex(_v1);
        _util.myVertex(_v2);
        _util.myVertex(_v3);
        endShape();
    }

    @Override
    void drawMe(PGraphics pg)
    {
        pg.beginShape(TRIANGLES);
        _util.myVertex(_v1, pg);
        _util.myVertex(_v2, pg);
        _util.myVertex(_v3, pg);
        pg.endShape();
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

    Rect(PVector upperLeft, PVector lowerRight, Attribute attr)
    {
        super(attr);
        _upperLeft = upperLeft;
        _lowerRight = lowerRight;
    }

    Rect(PVector upperLeft, PVector lowerRight)
    {
        this(upperLeft, lowerRight, null);
    }

    Rect(PVector upperLeft, float width, float height, Attribute attr)
    {
        this(upperLeft, new PVector(width, height).add(upperLeft), attr);
    }

    Rect(PVector upperLeft, float width, float height)
    {
        this(upperLeft, width, height, null);
    }

    Rect(float x, float y, float width, float height, Attribute attr)
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

    Rect2(PVector center, float width, float height, Attribute attr)
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

    Quad(PVector v1, PVector v2, PVector v3, PVector v4, Attribute attr)
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

class TextureQuad extends Quad
{
    PImage _img;

    TextureQuad(PVector v1, PVector v2, PVector v3, PVector v4, PImage img)
    {
        super(v1, v2, v3, v4, new Attribute(#ffffff, DrawStyle.FILLONLY));
        _img = img;
    }

    TextureQuad(PVector v1, PVector v2, PVector v3, PVector v4)
    {
        this(v1, v2, v3, v4, null);
    }

    void setImage(PImage img) { _img = img; }

    @Override
    void drawMe()
    {
        beginShape(QUADS);
        texture(_img);
        _util.myVertex(_v1, 0, 0);
        _util.myVertex(_v2, 0, 1);
        _util.myVertex(_v3, 1, 1);
        _util.myVertex(_v4, 1, 0);
        endShape();
    }

    @Override
    void drawMe(PGraphics pg)
    {
        pg.beginShape(QUADS);
        pg.texture(_img);
        _util.myVertex(_v1, 0, 0, pg);
        _util.myVertex(_v2, 0, 1, pg);
        _util.myVertex(_v3, 1, 1, pg);
        _util.myVertex(_v4, 1, 0, pg);
        pg.endShape();
    }

    void drawMeAttr(int alpha)
    {
        pushStyle();
        tint(255, alpha);
        if (_attr != null) { _attr.apply(); }
        drawMe();
        popStyle();
    }

    void drawMeAttr(PGraphics pg, int alpha)
    {
        pg.pushStyle();
        pg.tint(255, alpha);
        if (_attr != null) { _attr.apply(pg); }
        drawMe(pg);
        pg.popStyle();
    }
}

class DividedQuad extends Quad
{
    final PVector _e1v1, _e1v2, _e2v1, _e2v2;
    final PVector _c1v1, _c1v2, _c2v1, _c2v2;
    final float _endArea, _minEndArea, _maxEndArea;
    final DividedQuad _parent;
    DividedQuad _child1, _child2;
    final int _seed1, _seed2;

    DividedQuad(PVector v1, PVector v2, PVector v3, PVector v4, float minEndArea, float maxEndArea, DividedQuad parent)
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

    DividedQuad(PVector v1, PVector v2, PVector v3, PVector v4, float minEndArea, float maxEndArea)
    {
        this(v1, v2, v3, v4, minEndArea, maxEndArea, null);
    }

    void initialize()
    {
        createChildren();
        updateMe(-1);
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
        _child1 = createChild(_c1v1, _c1v2, vd1, vd2);
        _child2 = createChild(_c2v1, _c2v2, vd1, vd2);
        _child1.createChildren();
        _child2.createChildren();
    }

    DividedQuad createChild(PVector v1, PVector v2, PVector v3, PVector v4)
    {
        return new DividedQuad(v1, v2, v3, v4, _minEndArea, _maxEndArea, this);
    }

    void trasform(float t)
    {
        if (_parent == null) { return; }

        float s1 = t < 0 ? random(.3, .7) : _util.easeInOutQuad(noise(t, _seed1));
        float s2 = t < 0 ? 1-s1 : _util.easeInOutQuad(noise(t, _seed2));
        PVector v3 = PVector.mult(_parent._e1v1, s1).add(PVector.mult(_parent._e1v2, 1-s1));
        PVector v4 = PVector.mult(_parent._e2v1, s2).add(PVector.mult(_parent._e2v2, 1-s2));
        _v3.set(v3.x, v3.y, v3.z);
        _v4.set(v4.x, v4.y, v4.z);
    }

    void updateMe(float t)
    {
        if (!isChildren()) { return; }
        _child1.trasform(t);
        _child2.trasform(t);
        _child1.updateMe(t);
        _child2.updateMe(t);
    }

    void drawLeaf() { super.drawMe(); }

    @Override
    void drawMe()
    {
        if (!isChildren())
        {
            drawLeaf();
            return;
        }
        _child1.drawMe();
        _child2.drawMe();
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

    Circle(PVector center, float radius, Attribute attr)
    {
        super(attr);
        _center = center;
        _radius = radius;
    }

    Circle(PVector center, float radius)
    {
        this(center, radius, null);
    }

    Circle(float x, float y, float radius, Attribute attr)
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

    Arc(PVector center, float radius, float startRad, float stopRad, int mode, Attribute attr)
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

    Arc(float x, float y, float radius, float startRad, float stopRad, int mode, Attribute attr)
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
