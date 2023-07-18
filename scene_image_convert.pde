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
        float time = _convertStartSec * _util.easeOutSin(t);
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

    class ImageBlock implements ImageSortable
    {
        final PImage _img;
        final float _totalMoveSec;
        PVector _pos, _start, _goal, _control1, _control2;
        float _curSec;

        ImageBlock(PImage img, float totalMoveSec)
        {
            _img = img;
            _totalMoveSec = totalMoveSec;
        }

        ImageBlock(PImage img, PVector start, float totalMoveSec)
        {
            this(img, totalMoveSec);
            setStart(start);
        }

        void setStart(PVector start)
        {
            _start = start;
            _pos = start.copy();
        }

        void setGoal(PVector goal)
        {
            _goal = goal;
        }

        void setControls()
        {
            // float t1 = random(.1, .4);
            // float t2 = random(.6, .9);
            float t1 = random(-1, 1);
            float t2 = random(-1, 1);
            PVector c1 = PVector.mult(_start, 1-t1).add(PVector.mult(_goal, t1));
            PVector c2 = PVector.mult(_start, 1-t2).add(PVector.mult(_goal, t2));
            PVector dir = PVector.sub(_goal, _start);
            PVector n = new PVector(dir.y, -dir.x);
            float d = PVector.dist(_start, _goal)*_totalMoveSec*.002;
            float s1 = random(-1, 1)*d;
            float s2 = random(-1, 1)*d;
            _control1 = PVector.mult(n, s1).add(c1);
            _control2 = PVector.mult(n, s2).add(c2);
        }

        void updateMe()
        {
            float r = _curSec/_totalMoveSec;
            float t = _util.easeInOutQuad(r);
            _pos = _util.cubicBezierPath(_start, _control1, _control2, _goal, t);
            _curSec += 1./_frameRate;
        }

        void drawMe()
        {
            image(_img, _pos.x, _pos.y);
        }

        PImage getImage() { return _img; }
    }

    class ImageBlockManager
    {
        final PImage _img;
        final int _kernelsize, _xNum, _yNum;
        final ImageBlock[] _blocks;

        /**
        * @param img base image; must be resize to window size
        */
        ImageBlockManager(PImage img, int kernelsize)
        {
            _img = img;
            _kernelsize = kernelsize;
            _xNum = ceil((float)_img.width/_kernelsize);
            _yNum = ceil((float)_img.height/_kernelsize);
            _blocks = new ImageBlock[_xNum*_yNum];
        }

        class ImageInfo implements ImageSortable
        {
            final PImage _img;
            final PVector _pos;

            ImageInfo(PImage img, PVector pos)
            {
                _img = img;
                _pos = pos;
            }

            PImage getImage() { return _img; }

            PVector getPos() { return _pos; }
        }

        /**
        * @param target Image to be converted; must be resize to window size
        */
        void createImageBlocks(PImage target, float totalMoveSec)
        {
            ImageInfo[] targetInfo = new ImageInfo[_xNum*_yNum];
            for (int i = 0; i < _xNum*_yNum; i++)
            {
                int x = i%_xNum;
                int y = i/_xNum;
                int w = (x+1)*_kernelsize <= _img.width ? _kernelsize : _img.width % _kernelsize;
                int h = (y+1)*_kernelsize <= _img.height ? _kernelsize : _img.height % _kernelsize;
                PImage imgBlock = _img.get(x*_kernelsize, y*_kernelsize, w, h);
                PVector pos = new PVector((i%_xNum)*_kernelsize, (i/_xNum)*_kernelsize);
                _blocks[i] = new ImageBlock(imgBlock, pos, totalMoveSec);

                PImage targetBlock = target.get(x*_kernelsize, y*_kernelsize, w, h);
                targetInfo[i] = new ImageInfo(targetBlock, pos);
            }
            Arrays.sort(_blocks, new BrightnessComparator());
            Arrays.sort(targetInfo, new BrightnessComparator());
            for (int i = 0; i < _xNum*_yNum; i++)
            {
                PVector pos = targetInfo[i].getPos();
                _blocks[i].setGoal(pos);
                _blocks[i].setControls();
            }
        }

        void updateBlocks()
        {
            for (ImageBlock block : _blocks) { block.updateMe(); }
        }

        void drawBlocks()
        {
            for (ImageBlock block : _blocks) { block.drawMe(); }
        }
    }
}