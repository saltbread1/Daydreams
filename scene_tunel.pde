class SceneTunnel extends Scene
{
    ArrayDeque<TunnelGate> _gateQueue;
    float _radius, _spaceZ, _minZ, _maxZ;
    int _rectNum;

    SceneTunnel(TransitionEffect beginEffect, TransitionEffect endEffect, float totalSceneSec)
    {
        super(beginEffect, endEffect, totalSceneSec);
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
    void start()
    {
        camera(0, 0, (height/2)/tan(PI/6), 0, 0, 0, 0, 1, 0);
    }

    @Override
    void update()
    {
        ambientLight(128, 128, 128);
        clearScene();
        updateGates();
        pushMatrix();
        rotate(sin(_curSec*3)*PI*.1);
        drawGates();
        popMatrix();
    }

    @Override
    void postProcessing()
    {
        super.postProcessing();
        _util.resetCamera();
    }

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
        for (TunnelGate gate : _gateQueue) { gate.drawMe(); }
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
                PVector v1 = PVector.fromAngle(rad - PI/_num).mult(minorRadius).add(dirMaxHeight).add(_center);
                PVector v2 = PVector.fromAngle(rad + PI/_num).mult(minorRadius).add(dirMaxHeight).add(_center);
                cuboid.setParameters(v1, v2, dir.mult(-1), heights[i]);
                cuboid.createFaces();
                cuboid.rotate(sec*1.7);
                rad += TAU/_num;
            }

            _center.z += dz;
        }

        void drawMe()
        {
            for (TunnelCuboid cuboid : _cuboidArray) { cuboid.drawMe(); }
        }

        float myNoise(float val, float scale, float seed)
        {
            return noise((cos(val)+1)*scale, (sin(val)+2)*scale, seed);
        }

        float getZ() { return _center.z; }

        class TunnelCuboid implements Rotatable3D
        {
            final float _minZ, _maxZ;
            final float _initRotRad;
            final int _rotDir;
            PVector _fv1, _fv2, _fv3, _fv4;
            float _edgeLenZ;
            PVector _dir, _rotInit;
            ArrayList<Quad> _faceList;

            TunnelCuboid(float minZ, float maxZ)
            {
                _minZ = minZ;
                _maxZ = maxZ;
                _initRotRad = random(TAU);
                _rotDir = 1-(int)random(2)*2;
            }

            void setParameters(PVector fv1, PVector fv2, PVector dir, float height)
            {
                PVector xy = PVector.mult(dir, height);
                _fv1 = fv1;
                _fv2 = fv2;
                _fv3 = PVector.add(fv2, xy);
                _fv4 = PVector.add(fv1, xy);
                _edgeLenZ = PVector.dist(fv1, fv2);
                _dir = dir;
                _rotInit = PVector.add(_fv3, _fv4).div(2);
                _rotInit.z -= _edgeLenZ/2;
            }

            void createFaces()
            {
                PVector z  = new PVector(0, 0, -_edgeLenZ);
                PVector hv1 = PVector.add(_fv1, z);
                PVector hv2 = PVector.add(_fv2, z);
                PVector hv3 = PVector.add(_fv3, z);
                PVector hv4 = PVector.add(_fv4, z);
                
                _faceList = new ArrayList<Quad>();
                _faceList.add(new Quad(_fv1, _fv2, _fv3, _fv4));
                _faceList.add(new Quad( hv1,  hv2,  hv3,  hv4));
                _faceList.add(new Quad(_fv1,  hv1,  hv4, _fv4));
                _faceList.add(new Quad(_fv2,  hv2,  hv3, _fv3));
            }

            void drawMe()
            {
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
            }

            @Override
            void rotate(PVector dir, float rad, PVector init)
            {
                for (Quad face : _faceList) { face.rotate(dir, rad, init); }
            }

            void rotate(float rad)
            {
                rad = _initRotRad + rad * _rotDir;
                for (Quad face : _faceList) { rotate(_dir, rad, _rotInit); }
            }
        }
    }
}