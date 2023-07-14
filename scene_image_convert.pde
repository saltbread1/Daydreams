class SceneImageConvert extends Scene
{
    ImageBlockManager _ibm;
    PGraphics _base;
    PImage _target;
    PShader _noise;
    final float _convertStartSec, _totalMovingSec;

    SceneImageConvert(float convertStartSec, float totalMovingSec)
    {
        super(convertStartSec + totalMovingSec);
        _convertStartSec = convertStartSec;
        _totalMovingSec = totalMovingSec;
    }

    @Override
    void initialize()
    {
        // images
        _target = loadImage("eye0.png");
        _target.resize(width, height);
        _base = createGraphics(width, height, P2D);
        _noise = loadShader("noise0.glsl");

        // conversion
        updateGraphics(_convertStartSec); // image at the beginning to conversion
        updateGraphics(_convertStartSec); // first update is not go well...
        _ibm = new ImageBlockManager(_base.get(), 20);
        _ibm.createImageBlocks(_target, _totalMovingSec);
        convertImage(); // first convert is so slow...
        clearScene();
    }

    @Override
    void update()
    {
        if (_curSec < _convertStartSec)
        {
            updateGraphics(_curSec);
            image(_base, 0, 0);
        }
        else { convertImage(); }
    }

    void updateGraphics(float sec)
    {
        float t = sec/_convertStartSec;
        float time = _convertStartSec * easeOutSin(t);
        _noise.set("resolution", (float)_base.width, (float)_base.height);
        _noise.set("time", time);
        _noise.set("kernel_size", 5);
        _base.beginDraw();
        _base.shader(_noise);
        _base.rect(0, 0, _base.width, _base.height);
        _base.endDraw();
    }

    void convertImage()
    {
        _ibm.updateBlocks();
        _ibm.drawBlocks();
    }
}