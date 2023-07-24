class SceneTunnel extends Scene
{
    ArrayDeque<TunnelGate> _gateQueue;
    float _radius, _spaceZ, _minZ, _maxZ;
    int _rectNum;

    SceneTunnel(Camera camera, float totalSceneSec)
    {
        super(camera, totalSceneSec);
    }

    @Override
    void initialize()
    {
        _gateQueue = new ArrayDeque<TunnelGate>();
        _radius = dist(0, 0, width/2, height/2);
        _spaceZ = 300;
        _maxZ = (height/2)/tan(PI/3)+_spaceZ;
        _minZ = _maxZ - _spaceZ*8;
        _rectNum = 90;
        for (float z = _maxZ-_spaceZ; z >= _minZ; z-=_spaceZ)
        {
            _gateQueue.add(createNewGate(z));
        }
    }

    @Override
    void update()
    {
        ambientLight(128, 128, 128);
        clearScene();
        updateGates();
        pushMatrix();
        rotate(sin(_curSec*3)*PI*.12);
        drawGates();
        popMatrix();
    }

    PVector getCameraCenter() { return new PVector(); }

    TunnelGate createNewGate(float z)
    {
        TunnelGate gate = new TunnelGate(new PVector(0, 0, z), _radius, _rectNum);
        gate.createCuboids(_minZ, _maxZ);
        return gate;
    }

    void updateGates()
    {
        if (_gateQueue.peek().getZ() > _maxZ)
        {
            _gateQueue.poll();
            _gateQueue.add(createNewGate(_minZ));
        }

        for (TunnelGate gate : _gateQueue) { gate.updateMe(32, _curSec); }
    }

    void drawGates()
    {
        for (TunnelGate gate : _gateQueue) { gate.drawMeAttr(); }
    }

    class TunnelGate
    {
        final PVector _center;
        final float _radius;
        final int _num;
        TunnelCuboid[] _cuboidArray;
        final int _seed;

        TunnelGate(PVector center, float radius, int num)
        {
            _center = center;
            _radius = radius;
            _num = num;
            _seed = (int)random(65536);
        }

        void createCuboids(float minZ, float maxZ)
        {
            _cuboidArray = new TunnelCuboid[_num];
            for (int i = 0; i < _num; i++) { _cuboidArray[i] = new TunnelCuboid(minZ, maxZ); }

        }

        void updateMe(float dz, float sec)
        {
            // calculate heights of rects
            float[] heights = new float[_num];
            float maxHeight = 0;
            for (int i = 0; i < _num; i++)
            {
                float h = _radius * (.23 + myNoise(TAU*i/_num, _num*.04, _seed+sec*1.2)*.66);
                heights[i] = h;
                if (h > maxHeight) { maxHeight = h; }
            }

            float minorRadius = _radius - maxHeight;
            float rad = 0;
            for (int i = 0; i < _num; i++)
            {
                TunnelCuboid cuboid = _cuboidArray[i];
                PVector dir = PVector.fromAngle(rad);
                PVector dirMaxHeight = PVector.mult(dir, maxHeight);
                PVector v1 = PVector.fromAngle(rad + PI/_num).mult(minorRadius).add(dirMaxHeight).add(_center);
                PVector v2 = PVector.fromAngle(rad - PI/_num).mult(minorRadius).add(dirMaxHeight).add(_center);
                PVector offZ = new PVector(0, 0, PVector.dist(v1, v2));
                cuboid.setParameters(new Quad(v1, v2, PVector.add(v2, offZ), PVector.add(v1, offZ)), heights[i]);
                cuboid.createFaces();
                cuboid.rotate(sec*2.7);
                rad += TAU/_num;
            }

            _center.z += dz;
        }

        void drawMeAttr()
        {
            for (TunnelCuboid cuboid : _cuboidArray) { cuboid.drawMeAttr(); }
        }

        float myNoise(float val, float scale, float seed)
        {
            return noise((cos(val)+1)*scale, (sin(val)+2)*scale, seed);
        }

        float getZ() { return _center.z; }

        class TunnelCuboid extends QuadPrism implements Rotatable3D
        {
            final float _minZ, _maxZ, _initRotRad;
            final int _rotDir;
            float _edgeLenZ;

            TunnelCuboid(float minZ, float maxZ)
            {
                _minZ = minZ;
                _maxZ = maxZ;
                _initRotRad = random(TAU);
                _rotDir = 1-(int)random(2)*2;
            }

            void setParameters(Quad bottomFace, float height)
            {
                _bottomFace = bottomFace;
                _height = height;
                _normal = PVector.sub(_bottomFace._v2, _bottomFace._v1)
                        .cross(PVector.sub(_bottomFace._v4, _bottomFace._v1))
                        .normalize();
            }

            @Override
            void drawMeAttr()
            {
                pushStyle();
                for (Quad face : _faceList)
                {
                    PVector v1 = face._v1;
                    PVector v2 = face._v2;
                    PVector v3 = face._v3;
                    PVector v4 = face._v4;
                    float val = sq(map(v1.z, _minZ, _maxZ, 0, 1));
                    beginShape();
                    noStroke();
                    stroke(#000000, val*100);
                    fill(#000000, val*100);
                    _util.myVertex(v1);
                    _util.myVertex(v2);
                    stroke(#f00000, val*180);
                    fill(#ec0000, val*180);
                    _util.myVertex(v3);
                    _util.myVertex(v4);
                    endShape();
                }
                popStyle();
            }

            @Override
            void rotate(PVector dir, float rad, PVector init)
            {
                for (Quad face : _faceList) { face.rotate(dir, rad, init); }
            }

            void rotate(float rad)
            {
                rad = _initRotRad + rad * _rotDir;
                for (Quad face : _faceList) { rotate(_normal, rad, _bottomFace.getCenter()); }
            }
        }
    }
}