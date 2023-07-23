class Utility
{
    void myVertex(PVector v)
    {
        if (v.z == 0) { vertex(v.x, v.y); }
        else { vertex(v.x, v.y, v.z); }
    }

    void myVertex(PVector v, PGraphics pg)
    {
        if (v.z == 0) { pg.vertex(v.x, v.y); }
        else { pg.vertex(v.x, v.y, v.z); }
    }

    void myLine(PVector v1, PVector v2)
    {
        if (v1.z == 0 && v2.z == 0) { line(v1.x, v1.y, v2.x, v2.y); }
        else { line(v1.x, v1.y, v1.z, v2.x, v2.y, v2.z); }
    }

    PVector rotate(PVector target, float rad)
    {
        return target.copy().rotate(rad);
    }

    PVector rotate(PVector target, float rad, PVector init)
    {
        PVector v = target.copy();
        v.sub(init);
        v.rotate(rad);
        v.add(init);
        return v;
    }

    PVector rotate3D(PVector target, PVector dir, float rad)
    {
        Quaternion q = new Quaternion(dir, rad);
        Quaternion qi = q.inverse(null);
        Quaternion qr = q.multr(target).multreq(qi);
        return new PVector(qr.x, qr.y, qr.z);
    }

    PVector rotate3D(PVector target, PVector dir, float rad, PVector init)
    {
        Quaternion q = new Quaternion(dir, rad);
        Quaternion qi = q.inverse(null);
        Quaternion qr = q.multr(PVector.sub(target, init)).multreq(qi);
        return new PVector(qr.x, qr.y, qr.z).add(init);
    }

    PVector cubicBezierPath(PVector start, PVector control1, PVector control2, PVector goal, float t)
    {
        t = constrain(t, 0, 1);
        PVector v1 = PVector.mult(start, pow(1-t,3));
        PVector v2 = PVector.mult(control1, t*sq(1-t)*3);
        PVector v3 = PVector.mult(control2, sq(t)*(1-t)*3);
        PVector v4 = PVector.mult(goal, pow(t,3));
        return v1.add(v2).add(v3).add(v4);
    }

    float calcCubicBezierLength(PVector start, PVector control1, PVector control2, PVector goal, float n)
    {
        float l = 0;
        for (int i = 0; i < n; i++)
        {
            float t1 = (float)i/n;
            float t2 = (float)(i+1)/n;
            float x1 = bezierPoint(start.x, control1.x, control2.x, goal.x, t1);
            float y1 = bezierPoint(start.y, control1.y, control2.y, goal.y, t1);
            float x2 = bezierPoint(start.x, control1.x, control2.x, goal.x, t2);
            float y2 = bezierPoint(start.y, control1.y, control2.y, goal.y, t2);
            l += dist(x1, y1, x2, y2);
        }
        return l;
    }

    FloatList calcCubicBezierConstantParams(PVector start, PVector control1, PVector control2, PVector goal, float speed)
    {
        float l = calcCubicBezierLength(start, control1, control2, goal, (int)(PVector.dist(start, goal)*.1));
        int n = (int)(l/speed*_frameRate);
        FloatList params = new FloatList();
        float stepDist = l/n;
        int m = n*8;
        float x = start.x;
        float y = start.y;
        int c = 0;
        for (int i = 1; i < m; i++)
        {
            float t = (float)i/m;
            float x0 = bezierPoint(start.x, control1.x, control2.x, goal.x, t);
            float y0 = bezierPoint(start.y, control1.y, control2.y, goal.y, t);
            if (dist(x, y, x0, y0) >= stepDist)
            {
                x = x0;
                y = y0;
                params.append(t);
            }
        }

        return params;
    }

    /**
    *   calc production vector: b to a
    */
    PVector production(PVector a, PVector b)
    {
        return PVector.mult(a, a.dot(b)/a.magSq());
    }

    /**
    * reset camera to default one
    */
    void resetCamera()
    {
        camera(width/2, height/2, (height/2)/tan(PI/6), width/2, height/2, 0, 0, 1, 0);
    }

    float mod(float x, float y)
    {
        return x-y*floor(x/y);
    }

    float fract(float x)
    {
        return mod(x, 1);
    }

    /************************/
    /*    easing methods    */
    /************************/

    float easeInQuad(float t)
    {
        t = constrain(t, 0, 1);
        return sq(t);
    }

    float easeOutQuad(float t)
    {
        t = constrain(t, 0, 1);
        return 1-sq(1-t);
    }

    float easeInOutQuad(float t)
    {
        t = constrain(t, 0, 1);
        return t < .5 ? 2*sq(t) : 1-2*sq(t-1);
    }

    float easeInCubic(float t)
    {
        t = constrain(t, 0, 1);
        return pow(t, 3);
    }

    float easeOutCubic(float t)
    {
        t = constrain(t, 0, 1);
        return 1-pow(1-t, 3);
    }

    float easeInOutCubic(float t)
    {
        t = constrain(t, 0, 1);
        return t < .5 ? 4*pow(t,3) : 1+4*pow(t-1,3);
    }

    float easeInQuart(float t)
    {
        t = constrain(t, 0, 1);
        return pow(t, 4);
    }

    float easeInQuint(float t)
    {
        t = constrain(t, 0, 1);
        return pow(t, 5);
    }

    float easeOutQuint(float t)
    {
        t = constrain(t, 0, 1);
        return 1-pow(1-t, 5);
    }

    float easeOutBack(float t, float a)
    {
        t = constrain(t, 0, 1);
        float b = a+1;
        return 1 + b*pow(t-1, 3) + a*sq(t-1);
    }
}

enum DirectionType
{
    RIGHT(new PVector(1, 0)),
    UPPER_RIGHT(new PVector(1, -1)),
    UP(new PVector(0, -1)),
    UPPER_LEFT(new PVector(-1, -1)),
    LEFT(new PVector(-1, 0)),
    LOWER_LEFT(new PVector(-1, 1)),
    DOWN(new PVector(0, 1)),
    LOWER_RIGHT(new PVector(1, 1));

    final PVector _dir;

    DirectionType(PVector dir) { _dir = dir; }

    PVector getDirection() { return _dir; }
}