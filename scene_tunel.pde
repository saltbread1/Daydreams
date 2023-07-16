class SceneTunnel extends Scene
{
    ArrayDeque<TunnelGate> _gateQueue;
    float _radius, _spaceZ, _minZ, _maxZ;
    int _rectNum;

    SceneTunnel(float totalSceneSec)
    {
        super(totalSceneSec);
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
}