class SceneReversingRects extends Scene
{
    DevidedQuad _devidedQuad;
    ArrayList<QuadManager> _quadManagerList;

    SceneReversingRects(float totalSceneSec)
    {
        super(totalSceneSec);
    }

    @Override
    void initialize()
    {
        _devidedQuad = new DevidedQuad(
                new PVector(0, 0),
                new PVector(0, height),
                new PVector(width, height),
                new PVector(width, 0),
                width*.42, width*2.5); // width*.52, width*11.8
        _devidedQuad.initialize();

        ArrayList<Quad> quadList = new ArrayList<Quad>();
        _devidedQuad.getAllChildren(quadList);
        _quadManagerList = new ArrayList<QuadManager>();
        for (Quad quad : quadList)
        {
            QuadManager qm = new QuadManager(quad);
            qm.initialize();
            _quadManagerList.add(qm);
        }
    }

    @Override
    void update()
    {
        for (QuadManager qm : _quadManagerList)
        {
            qm.updateQuad();
            qm.drawQuad();
        }
    }

    @Override
    void clearScene() { background(#e9e9e9); }

    class QuadManager
    {
        final Quad _quad;
        PVector _rotAxis;
        float _rotRad;
        float _curRotSec, _totalRotSec;
        final color[] _palette = {#666666, #665c51, #666600, #2c6651, #2c6666, #000066, #4c0066, #660066};

        QuadManager(Quad quad)
        {
            _quad = quad;
        }

        void initialize()
        {
            color c = _palette[(int)random(_palette.length)];
            _quad.setAttribution(new Attribution(c, DrawStyle.FILLONLY));
        }

        void setParameters()
        {
            _rotAxis = DirectionType.values()[(int)random(4)*2].getDirection();
            //_rotRad = 0;
            _curRotSec = 0;
            _totalRotSec = random(.2, 2);
        }

        void updateQuad()
        {
            if (_curRotSec >= _totalRotSec) { setParameters(); }
            _curRotSec += 1./_frameRate;
            _rotRad = _util.easeInOutQuad(_curRotSec/_totalRotSec)*PI;
        }

        void drawQuad()
        {
            Quad q = _quad.copy();
            q.rotate(_rotAxis, _rotRad, q.getCenter());
            q.drawMeAttr();
        }
    }
}