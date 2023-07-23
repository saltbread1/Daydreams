class SceneAbsorption extends Scene
{
    PGraphics _pg;
    PShader _noise;
    QuadManager _qm;
    
    SceneAbsorption(PApplet papplet, float totalSceneSec)
    {
        super(papplet, totalSceneSec);
    }

    @Override
    void initialize()
    {
        _pg = createGraphics(width, height, P3D);
        _noise = _dm.getNoiseShader1();
        _noise.set("resolution", (float)_pg.width, (float)_pg.height);
        _qm = new QuadManager();
    }

    @Override
    void update()
    {
        _qm.updateQuads(.1, 4);
        _noise.set("time", _curSec*2.3);

        _pg.beginDraw();
        _pg.textureMode(NORMAL);
        //_pg.blendMode(ADD);
        _pg.background(#600000);
        _pg.hint(DISABLE_DEPTH_TEST);
        _pg.pushStyle();
        _pg.imageMode(CENTER);
        _pg.image(_dm.getMouthImage(), width/2, height/2);
        _pg.popStyle();
        _qm.drawQuads(_pg);
        _pg.filter(_noise);
        _pg.endDraw();

        image(_pg, 0, 0);
    }

    class AbsorbedTextureQuad extends TextureQuad
    {
        final PVector _start, _middle, _goal, _control1, _control2;
        PVector _prePos;
        final float _start2MiddleSec, _middle2GoalSec;
        float _moveSec;
        final int _seed1, _seed2;

        AbsorbedTextureQuad(PVector v1, PVector v2, PVector v3, PVector v4, PImage img, PVector start)
        {
            super(v1, v2, v3, v4, img);
            _start = start;
            PVector c = new PVector(width/2, height/2);
            _middle = PVector.sub(_start, c).normalize().mult(width*.16).add(c);
            _goal = new PVector(c.x, c.y, -height*2);

            //calc control points
            float t1 = random(1);
            float t2 = random(1);
            PVector c1 = PVector.mult(_start, 1-t1).add(PVector.mult(_middle, t1));
            PVector c2 = PVector.mult(_start, 1-t2).add(PVector.mult(_middle, t2));
            PVector dir = PVector.sub(_middle, _start);
            PVector n = new PVector(dir.y, -dir.x).normalize();
            float r = PVector.dist(_start, _middle)*1.8;
            float s1 = sqrt(random(1)) * (1-(int)random(2)*2) * r;
            float s2 = sqrt(random(1)) * (1-(int)random(2)*2) * r;
            _control1 = PVector.mult(n, s1).add(c1);
            _control2 = PVector.mult(n, s2).add(c2);

            _prePos = getCenter();
            _start2MiddleSec = random(.31, 1.6);
            _middle2GoalSec = random(.22, .37);
            _seed1 = (int)random(65536);
            _seed2 = (int)random(65536);
        }

        void updateMe()
        {
            PVector pos = null;
            if (_moveSec < _start2MiddleSec)
            {
                float r = _util.easeOutQuad(_moveSec/_start2MiddleSec);
                pos = _util.cubicBezierPath(_start, _control1, _control2, _middle, r);
            }
            else
            {
                float r = _util.easeInCubic((_moveSec-_start2MiddleSec)/_middle2GoalSec);
                pos = PVector.mult(_middle, 1-r).add(PVector.mult(_goal, r));
            }
            translate(PVector.sub(pos, _prePos));
            _prePos = pos;
            _moveSec += 1./_frameRate;
        }

        @Override
        void drawMe()
        {
            pushMatrix();
            _papplet.translate(0, 0, _prePos.z);
            super.drawMe();
            popMatrix();
        }

        @Override
        void drawMe(PGraphics pg)
        {
            pg.pushMatrix();
            pg.translate(0, 0, _prePos.z);
            super.drawMe(pg);
            pg.popMatrix();
        }

        boolean isDestroy()
        {
            return _moveSec > _start2MiddleSec + _middle2GoalSec;
        }

        void displayDebugInfo()
        {
            pushStyle();
            stroke(#00ff00);
            noFill();
            bezier(_start.x, _start.y, _control1.x, _control1.y, _control2.x, _control2.y, _middle.x, _middle.y);
            popStyle();
        }
    }

    class QuadManager
    {
        PImage[] _imgs;
        ArrayList<AbsorbedTextureQuad> _quadList;

        QuadManager()
        {
            _imgs = _dm.getEyeAlphaImages();
            _quadList = new ArrayList<AbsorbedTextureQuad>();
        }

        void addQuad()
        {
            PImage img = _imgs[(int)random(_imgs.length)];
            float h = sq(random(.15, .28))*width;
            float w = h * (float)img.width/img.height;
            AbsorbedTextureQuad quad = new AbsorbedTextureQuad(
                    new PVector(-w/2, -h/2),
                    new PVector(-w/2,  h/2),
                    new PVector( w/2,  h/2),
                    new PVector( w/2, -h/2),
                    img,
                    new PVector(width/2, height/2).add(PVector.random2D().mult(width/2*1.2)));
            _quadList.add(quad);
        }

        void updateQuads(float intervalSec, int maxiterations)
        {
            if (_util.mod(_curSec, intervalSec) > intervalSec/2
                && _util.mod(_curSec+1./_frameRate, intervalSec) < intervalSec/2)
            {
                for (int i = 0; i < maxiterations; i++) { addQuad(); }
            }
            for (int i = 0; i < _quadList.size(); i++)
            {
                AbsorbedTextureQuad quad = _quadList.get(i);
                if (quad.isDestroy())
                {
                    _quadList.remove(i--);
                    continue;
                }
                quad.updateMe();
                if (random(1) < .4)
                {
                    quad.setImage(_imgs[(int)random(_imgs.length)]);
                }
            }
        }

        void drawQuads(PGraphics pg)
        {
            for (AbsorbedTextureQuad quad : _quadList) { quad.drawMeAttr(pg); }
        }
    }
}