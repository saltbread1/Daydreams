class SceneTunnel extends Scene
{
    ArrayList<TunnelGate> _gateList;
    float _radius, _spaceZ, _minZ, _maxZ;
    int _rectNum;

    SceneTunnel(float totalSceneSec)
    {
        super(totalSceneSec);
    }

    @Override
    void initialize()
    {
        _gateList = new ArrayList<TunnelGate>();
        _radius = sqrt(sq(width)+sq(height))/2;
        _spaceZ = 300;
        _maxZ = 400;
        _minZ = _maxZ - _spaceZ*18;
        _rectNum = 100;
        for (float z = _maxZ-_spaceZ; z >= _minZ; z-=_spaceZ)
        {
            TunnelGate gate = new TunnelGate(new PVector(width/2, height/2, z), _radius, _rectNum);
            _gateList.add(gate);
        }
    }

    @Override
    void update()
    {
        ambientLight(128, 128, 128);
        //directionalLight(255, 255, 255, 0, 0, -1);
        clearScene();
        updateGates();
        drawGates();
    }

    void updateGates()
    {
        if (_gateList.get(0).getZ() > _maxZ)
        {
            _gateList.remove(0);
            _gateList.add(new TunnelGate(new PVector(width/2, height/2, _minZ), _radius, _rectNum));
        }

        for (TunnelGate gate : _gateList) { gate.updateMe(new PVector(0, 0, 16), frameCount); }
    }

    void drawGates()
    {
        for (TunnelGate gate : _gateList) { gate.drawMe(_minZ, _maxZ); }
    }
}