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
        _textureImages = _dm.getEyeImages();
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
        DividedQuad createChild(PVector v1, PVector v2, PVector v3, PVector v4)
        {
            return new TextureDivideQuad(v1, v2, v3, v4, _minEndArea, _maxEndArea, this);
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
        void drawLeaf()
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