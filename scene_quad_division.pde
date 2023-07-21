class SceneQuadDivision extends Scene
{
    PImage[] _textureImages;
    TextureDivideQuad _quad;

    SceneQuadDivision(float totalSceneSec)
    {
        super(totalSceneSec);
    }

    @Override
    void initialize()
    {
        _textureImages = new PImage[3];
        _textureImages[0] = loadImage("eye1.png");
        _textureImages[1] = loadImage("eye2.png");
        _textureImages[2] = loadImage("eye3.png");
        for (PImage img : _textureImages) { img.filter(POSTERIZE, 5); }
        _quad = new TextureDivideQuad(
                new PVector(0, 0),
                new PVector(0, height),
                new PVector(width, height),
                new PVector(width, 0),
                width*.42, width*2.5); // width*.52, width*11.8
        _quad.initialize();
    }

    @Override
    void update()
    {
        _quad.updateMe(_curSec*2);
        _quad.drawMeAttr();
    }

    class TextureDivideQuad extends DividedQuad
    {
        PImage _curImg;
        float _imageSec, _imageTotalSec;

        TextureDivideQuad(PVector v1, PVector v2, PVector v3, PVector v4, float minEndArea, float maxEndArea, TextureDivideQuad parent)
        {
            super(v1, v2, v3, v4, minEndArea, maxEndArea, parent);
            setAttribution(new Attribution(#ffffff, DrawStyle.FILLONLY));
        }

        TextureDivideQuad(PVector v1, PVector v2, PVector v3, PVector v4, float minEndArea, float maxEndArea)
        {
            this(v1, v2, v3, v4, minEndArea, maxEndArea, null);
        }

        @Override
        void createChildren()
        {
            if (getArea() <= _endArea)
            {
                _child1 = null;
                _child2 = null;
                return;
            }
            float s1 = random(1);
            float s2 = random(1);
            PVector vd1 = PVector.mult(_e1v1, s1).add(PVector.mult(_e1v2, 1-s1));
            PVector vd2 = PVector.mult(_e2v1, s2).add(PVector.mult(_e2v2, 1-s2));
            _child1 = new TextureDivideQuad(_c1v1, _c1v2, vd1, vd2, _minEndArea, _maxEndArea, this);
            _child2 = new TextureDivideQuad(_c2v1, _c2v2, vd1, vd2, _minEndArea, _maxEndArea, this);
            _child1.createChildren();
            _child2.createChildren();
        }

        @Override
        void updateMe(float t)
        {
            super.updateMe(t);
            if (isChildren()) { return; }
            if (_imageSec >= _imageTotalSec)
            {
                _curImg = _textureImages[(int)random(_textureImages.length)];
                _imageSec = 0;
                _imageTotalSec = sq(random(1))*.18;
            }
            _imageSec += 1./_frameRate;
        }

        @Override
        void drawMe()
        {
            if (!isChildren())
            {
                drawMeLeaf();
                return;
            }
            TextureDivideQuad c1 = (TextureDivideQuad)_child1;
            TextureDivideQuad c2 = (TextureDivideQuad)_child2;
            c1.drawMe();
            c2.drawMe();
        }

        @Override
        void drawMeAttr()
        {
            if (!isChildren())
            {
                super.drawMeAttr();
                return;
            }
            TextureDivideQuad c1 = (TextureDivideQuad)_child1;
            TextureDivideQuad c2 = (TextureDivideQuad)_child2;
            c1.drawMeAttr();
            c2.drawMeAttr();
        }

        void drawMeLeaf()
        {
            beginShape();
            texture(_curImg);
            vertex(_v1.x, _v1.y, 0, 0);
            vertex(_v2.x, _v2.y, 0, 1);
            vertex(_v3.x, _v3.y, 1, 1);
            vertex(_v4.x, _v4.y, 1, 0);
            endShape();
        }
    }
}