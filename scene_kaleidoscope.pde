class SceneKaleidoscope extends Scene
{
    PImage _baseImg;
    PGraphics _pg;
    FloatQuadManager _fm;
    KaleidoscopeQuadManager _km;

    SceneKaleidoscope(TransitionEffect beginEffect, TransitionEffect endEffect, float totalSceneSec)
    {
        super(beginEffect, endEffect, totalSceneSec);
    }

    @Override
    void initialize()
    {
        _baseImg = _dm.getHandImage();
        _pg = createGraphics(width, height, P2D);
        _fm = new FloatQuadManager();
        _km = new KaleidoscopeQuadManager();
        _fm.createQuads(40);
    }

    @Override
    void update()
    {
        _fm.updateQuads();
        _km.updateQuads(.1);
        _pg.beginDraw();
        _pg.textureMode(NORMAL);
        _pg.blendMode(ADD);
        _pg.background(#000000);
        _km.drawQuads(_pg, 16);
        _pg.endDraw();
        image(_pg, 0, 0);
        _fm.drawQuads();
    }

    class FloatQuadManager
    {
        ArrayList<TextureQuadFloat> _quadList;

        void createQuads(int n)
        {
            _quadList = new ArrayList<TextureQuadFloat>();
            for (int i = 0; i < n; i++)
            {
                float h = sq(random(.18, .46))*width;
                float w = h * (float)_baseImg.width/_baseImg.height;
                TextureQuadFloat quad = new TextureQuadFloat(
                        new PVector(-w/2, -h/2),
                        new PVector(-w/2,  h/2),
                        new PVector( w/2,  h/2),
                        new PVector( w/2, -h/2),
                        _baseImg);
                _quadList.add(quad);
            }
        }

        void updateQuads()
        {
            for (TextureQuadFloat quad : _quadList) { quad.updateMe(_curSec*.6); }
        }

        void drawQuads()
        {
            for (TextureQuadFloat quad : _quadList) { quad.drawMeAttr(); }
        }
    }

    class KaleidoscopeQuadManager
    {
        ArrayList<TextureQuadLiner> _quadList;
        float _threshSec;

        KaleidoscopeQuadManager() { _quadList = new ArrayList<TextureQuadLiner>(); }

        void addQuad()
        {
            float h = sq(random(.24, .39))*width;
            float w = h * (float)_baseImg.width/_baseImg.height;
            TextureQuadLiner quad = new TextureQuadLiner(
                    new PVector(-w/2, -h/2),
                    new PVector(-w/2,  h/2),
                    new PVector( w/2,  h/2),
                    new PVector( w/2, -h/2),
                    _baseImg,
                    PVector.random2D().mult(random(.5, .6)*width/_frameRate));
            quad.translate(new PVector(width/2, height/2));
            _quadList.add(quad);
        }

        void updateQuads(float intervalSec)
        {
            _threshSec += 1./_frameRate;
            if (_threshSec >= intervalSec)
            {
                addQuad();
                _threshSec = 0;
            }
            for (int i = 0; i < _quadList.size(); i++)
            {
                TextureQuadLiner quad = _quadList.get(i);
                if (!quad.isInScreen())
                {
                    _quadList.remove(i--);
                    continue;
                }
                quad.updateMe();
            }
        }

        void drawQuads(PGraphics pg, int virtualMirrorNum)
        {
            PVector init = new PVector(width/2, height/2);
            for (TextureQuadLiner quad : _quadList)
            {
                for (int i = 0; i < virtualMirrorNum; i++)
                {
                    quad.rotate(TAU/virtualMirrorNum, init);
                    for (int j = 0; j < 2; j++)
                    {
                        quad.reverseY(init.y);
                        quad.drawMeAttr(pg, 180);
                    }
                }
            }
        }
    }

    class TextureQuadFloat extends TextureQuad
    {
        PVector _prePos, _preVelocity;
        final int _seed1, _seed2;

        TextureQuadFloat(PVector v1, PVector v2, PVector v3, PVector v4, PImage img)
        {
            super(v1, v2, v3, v4, img);
            _prePos = getCenter();
            _preVelocity = new PVector(1, 0);
            _seed1 = (int)random(65536);
            _seed2 = (int)random(65536);
        }

        void updateMe(float t)
        {
            float x = _util.easeInOutCubic(noise(t, _seed1))*width;
            float y = _util.easeInOutCubic(noise(t, _seed2))*height;
            PVector pos = new PVector(x, y);
            PVector velocity = PVector.sub(pos, _prePos);
            float rad = PVector.angleBetween(velocity, _preVelocity);
            if (_preVelocity.cross(velocity).z < 0) { rad *= -1; }
            rotate(rad, getCenter());
            translate(velocity);
            _prePos = pos;
            _preVelocity = velocity;
        }
    }

    class TextureQuadLiner extends TextureQuad
    {
        PVector _velocity;

        TextureQuadLiner(PVector v1, PVector v2, PVector v3, PVector v4, PImage img, PVector velocity)
        {
            super(v1, v2, v3, v4, img);
            _velocity = velocity;
            float rad = PVector.angleBetween(velocity, new PVector(1, 0));
            if (velocity.y < 0) { rad *= -1; }
            rotate(rad, getCenter());
        }

        void updateMe() { translate(_velocity); }

        boolean isInScreen()
        {
            return isVertexInScreen(_v1) || isVertexInScreen(_v2) || isVertexInScreen(_v3) || isVertexInScreen(_v4);
        }

        boolean isVertexInScreen(PVector v)
        {
            float offsetX = width*.8;
            float offsetY = height*.8;
            return v.x+offsetX > 0 && v.x-offsetX < width && v.y+offsetY > 0 && v.y-offsetY < height;
        }

        void reverseY(float y)
        {
            _v1.y = y - (_v1.y - y);
            _v2.y = y - (_v2.y - y);
            _v3.y = y - (_v3.y - y);
            _v4.y = y - (_v4.y - y);
        }
    }
}