class Utility
{
    void myVertex(PVector v)
    {
        vertex(v.x, v.y, v.z);
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

    PVector cubicBezierPath(PVector start, PVector control1, PVector control2, PVector goal,  float t)
    {
        t = constrain(t, 0, 1);
        PVector v1 = PVector.mult(start, pow(1-t,3));
        PVector v2 = PVector.mult(control1, t*sq(1-t)*3);
        PVector v3 = PVector.mult(control2, sq(t)*(1-t)*3);
        PVector v4 = PVector.mult(goal, pow(t,3));
        return v1.add(v2).add(v3).add(v4);
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

    /************************/
    /*    easing methods    */
    /************************/

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

    float easeOutSin(float t)
    {
        t = constrain(t, 0, 1);
        return sin(HALF_PI*t);
    }

    float easeOutBack(float t, float a)
    {
        t = constrain(t, 0, 1);
        float b = a+1;
        return 1 + b*pow(t-1, 3) + a*sq(t-1);
    }

    float easeOutElastic(float t)
    {
        t = constrain(t, 0, 1);
        return t == 0
            ? 0
            : t == 1
            ? 1
            //: pow(2, -10 * t) * sin((t * 10 - 0.75) * TAU/3) + 1;
            : pow(1.6, -11.2 * t) * sin((t * 11.2 - 0.75) * TAU/3) + 1;
    }

    float easeReturnLiner(float t)
    {
        t = constrain(t, 0, 1);
        return acos(cos(TAU*t))/PI;
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