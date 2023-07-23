class SceneReversingRects extends Scene
{
    DividedQuad _dividedQuad;
    ArrayList<QuadManager> _quadManagerList;
    CustomBackground _bg;

    SceneReversingRects(TransitionEffect beginEffect, TransitionEffect endEffect, float totalSceneSec)
    {
        super(beginEffect, endEffect, totalSceneSec);
    }

    @Override
    void initialize()
    {
        _dividedQuad = new DividedQuad(
                new PVector(0, 0),
                new PVector(0, height),
                new PVector(width, height),
                new PVector(width, 0),
                width*.42, width*11.5);
        _dividedQuad.initialize();

        ArrayList<Quad> quadList = new ArrayList<Quad>();
        _dividedQuad.getAllChildren(quadList);
        _quadManagerList = new ArrayList<QuadManager>();
        for (Quad quad : quadList)
        {
            QuadManager qm = new QuadManager(quad);
            qm.initialize();
            _quadManagerList.add(qm);
        }

        _bg = new CustomBackground();
        _bg.createQuads();
    }

    @Override
    void update()
    {
        _bg.updateQuads();
        hint(DISABLE_DEPTH_TEST);
        image(_bg.createBackground(), 0, 0);
        hint(ENABLE_DEPTH_TEST);
        for (QuadManager qm : _quadManagerList)
        {
            qm.updateQuad();
            qm.drawQuad();
        }
    }

    class QuadManager
    {
        final Quad _quad;
        PVector _rotAxis;
        float _rotRad;
        float _curRotSec, _totalRotSec, _waitRotSec;

        QuadManager(Quad quad)
        {
            _quad = quad;
        }

        void initialize()
        {
            _quad.setAttribution(new Attribution(#000000, DrawStyle.FILLONLY));
            for (int i = 0; i < 80; i++) { updateQuad(); }
        }

        void setParameters()
        {
            _rotAxis = DirectionType.values()[(int)random(4)*2].getDirection();
            _curRotSec = 0;
            _totalRotSec = random(.46, 1.24);
            _waitRotSec = random(.67);
        }

        void updateQuad()
        {
            if (_curRotSec-_waitRotSec >= _totalRotSec) { setParameters(); }
            _curRotSec += 1./_frameRate;
            _rotRad = _util.easeInOutQuad((_curRotSec-_waitRotSec)/_totalRotSec)*PI;
        }

        void drawQuad()
        {
            Quad q = _quad.copy();
            q.rotate(_rotAxis, _rotRad, q.getCenter());
            q.drawMeAttr();
        }
    }

    class CustomBackground
    {
        final PImage[] _imgs;
        ArrayList<TextureQuad> _quadList;

        CustomBackground()
        {
            _imgs = _dm.getEyeAlphaImages();
        }

        void createQuads()
        {
            _quadList = new ArrayList<TextureQuad>();
            while (addQuad(256));
        }

        PImage createBackground()
        {
            PGraphics pg = createGraphics(width, height, P2D);
            pg.beginDraw();
            pg.textureMode(NORMAL);
            pg.background(#a40000);
            for (TextureQuad quad : _quadList) { quad.drawMeAttr(pg); }
            pg.endDraw();
            return pg;
        }

        void updateQuads()
        {
            for (TextureQuad quad : _quadList)
            {
                if (random(1) < .4)
                {
                    quad.setImage(_imgs[(int)random(_imgs.length)]);
                }
            }
        }

        boolean addQuad(int maxTrialIterations)
        {
            for (int i = 0; i < maxTrialIterations; i++)
            {
                PImage img = _imgs[(int)random(_imgs.length)];
                float h = sq(random(.28, 1))*width*.16;
                float w = h * (float)img.width/img.height;
                TextureQuad quad = new TextureQuad(
                        new PVector(-w/2, -h/2),
                        new PVector(-w/2,  h/2),
                        new PVector( w/2,  h/2),
                        new PVector( w/2, -h/2),
                        img);
                quad.translate(new PVector(random(w/2, width-w/2), random(h/2, height-h/2)));
                if (!isOverlap(quad))
                {
                    _quadList.add(quad);
                    return true;
                }
            }
            return false;
        }

        boolean isOverlap(TextureQuad quad)
        {
            for (TextureQuad other : _quadList)
            {
                float dx = abs(quad.getCenter().x - other.getCenter().x);
                float dy = abs(quad.getCenter().y - other.getCenter().y);
                float lx = (PVector.dist(quad._v1, quad._v4) + PVector.dist(other._v1, other._v4))/2;
                float ly = (PVector.dist(quad._v1, quad._v2) + PVector.dist(other._v1, other._v2))/2;
                if (dx < lx && dy < ly) { return true; }
            }
            return false;
        }
    }
}