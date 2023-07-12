void myVertex(PVector v)
{
    vertex(v.x, v.y, v.z);
}

PVector rotate3d(PVector target, PVector dir, float theta)
{
    Quaternion q = new Quaternion(dir, theta);
    Quaternion qi = q.inverse(null);
    Quaternion qr = q.multr(target).multreq(qi);
    return new PVector(qr.x, qr.y, qr.z);
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

float easingInOutQuad(float t)
{
    t = constrain(t, 0, 1);
    if (t < .5) { return 2*sq(t); }
    return 1-2*sq(t-1);
}

float easingInOutCubic(float t)
{
    t = constrain(t, 0, 1);
    if (t < .5) { return 4*pow(t,3); }
    return 1+4*pow(t-1,3);
}

float easingOutSin(float t)
{
    t = constrain(t, 0, 1);
    return sin(HALF_PI*t);
}

void resetCamera()
{
    camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0), width/2.0, height/2.0, 0, 0, 1, 0);
}