class TunnelGate
{
    final PVector _center;
    final float _radius;
    final int _num;
    final int _seed = (int)random(65536);
    final color[] _palette = {#9f664b, #3e4e7c, #d16d67, #529c66, #aa548f, #7c8463, #c49c3d, #628b90};
    final color[] _colours;
    ArrayList<TunnelCuboid> _cuboidList;

    TunnelGate(PVector center, float radius, int num)
    {
        _center = center;
        _radius = radius;
        _num = num;
        _colours = new color[_num];
        for (int i = 0; i < _num; i++)
        {
            _colours[i] = _palette[(int)random(_palette.length)];
        }
    }

    void createCuboids(int time)
    {
        // calculate heights of rects
        float[] heights = new float[_num];
        float maxHeight = 0;
        for (int i = 0; i < _num; i++)
        {
            //float h = _radius * (.12 + sq(random(1))*.6);
            //float h = abs(randomGaussian())*_radius*.34+8;
            float h = _radius * (.12 + myNoise(TAU*i/_num, _num*.04, _seed+time*.02)*.66);
            heights[i] = h;
            if (h > maxHeight) { maxHeight = h; }
        }

        _cuboidList = new ArrayList<TunnelCuboid>();
        float minorRadius = _radius - maxHeight;
        float rad = 0;
        for (int i = 0; i < _num; i++)
        {
            PVector dir = PVector.fromAngle(rad);
            PVector dirHeight = PVector.mult(dir, -heights[i]);
            PVector dirMaxHeight = PVector.mult(dir, maxHeight);
            PVector v1 = PVector.fromAngle(rad - PI/_num).mult(minorRadius).add(dirMaxHeight).add(_center);
            PVector v2 = PVector.fromAngle(rad + PI/_num).mult(minorRadius).add(dirMaxHeight).add(_center);
            TunnelCuboid cuboid = new TunnelCuboid(v1, v2, dirHeight, time*.05, _colours[i]);
            cuboid.createFaces();
            _cuboidList.add(cuboid);
            rad += TAU/_num;
        }
    }

    void updateMe(PVector dPos, int time)
    {
        _center.add(dPos);
        createCuboids(time);
    }

    void drawMe(float minZ, float maxZ)
    {
        for (TunnelCuboid cuboid : _cuboidList) { cuboid.drawMe(minZ, maxZ); }
    }

    float myNoise(float val, float scale, float seed)
    {
        return noise((cos(val)+1)*scale, (sin(val)+2)*scale, seed);
    }

    float getZ() { return _center.z; }
}

class TunnelCuboid extends SimpleShape3D implements Translatable
{
    final PVector _v1, _v2, _v3, _v4;
    final float _rotRad;
    final color _colour;
    ArrayList<Quad> _faceList;

    TunnelCuboid(PVector v1, PVector v2, PVector dirHeight, float rotRad, color colour)
    {
        _v1 = v1;
        _v2 = v2;
        _v3 = PVector.add(_v2, dirHeight);
        _v4 = PVector.add(_v1, dirHeight);
        _rotRad = rotRad;
        _colour = colour;
    }

    @Override
    void createFaces()
    {
        _faceList = new ArrayList<Quad>();
        
        PVector hide = new PVector(0, 0, PVector.dist(_v1, _v2));
        PVector hv1 = PVector.add(_v1, hide);
        PVector hv2 = PVector.add(_v2, hide);
        PVector hv3 = PVector.add(_v3, hide);
        PVector hv4 = PVector.add(_v4, hide);
        PVector dir = PVector.sub(_v4, _v1);
        PVector vc12 = PVector.add(_v1, _v2).add(hv1).add(hv2).div(4);
        PVector vc34 = PVector.add(_v3, _v4).add(hv3).add(hv4).div(4);
        PVector fv1 = _util.rotate3D(PVector.sub(_v1, vc12), dir, _rotRad).add(vc12);
        PVector fv2 = _util.rotate3D(PVector.sub(_v2, vc12), dir, _rotRad).add(vc12);
        PVector fv3 = _util.rotate3D(PVector.sub(_v3, vc34), dir, _rotRad).add(vc34);
        PVector fv4 = _util.rotate3D(PVector.sub(_v4, vc34), dir, _rotRad).add(vc34);
        hv1 = _util.rotate3D(PVector.sub(hv1, vc12), dir, _rotRad).add(vc12);
        hv2 = _util.rotate3D(PVector.sub(hv2, vc12), dir, _rotRad).add(vc12);
        hv3 = _util.rotate3D(PVector.sub(hv3, vc34), dir, _rotRad).add(vc34);
        hv4 = _util.rotate3D(PVector.sub(hv4, vc34), dir, _rotRad).add(vc34);
        _faceList.add(new Quad(fv1, fv2, fv3, fv4));
        _faceList.add(new Quad(hv1, hv2, hv3, hv4));
        _faceList.add(new Quad(fv1, hv1, hv4, fv4));
        _faceList.add(new Quad(fv2, hv2, hv3, fv3));
        // drawSurface(fv1, fv2, fv3, fv4);
        // drawSurface(hv1, hv2, hv3, hv4);
        // drawSurface(fv1, hv1, hv4, fv4);
        // drawSurface(fv2, hv2, hv3, fv3);
    }

    @Override
    void drawMe() {}
    
    void drawMe(float minZ, float maxZ)
    {
        for (Quad face : _faceList)
        {
            PVector v1 = face._v1;
            PVector v2 = face._v2;
            PVector v3 = face._v3;
            PVector v4 = face._v4;
            float val = sq(map(v1.z, minZ, maxZ, 0, 1));
            beginShape();
            noStroke();
            fill(#000000, val*100);
            _util.myVertex(v1);
            _util.myVertex(v2);
            //fill(_cFill, val*180);
            fill(#ff0000, val*180);
            _util.myVertex(v3);
            _util.myVertex(v4);
            endShape();
        }
    }

    @Override
    void translate(PVector dv)
    {
        for (Quad face : _faceList) { face.translate(dv); }
    }
}