class SceneImageConvert extends Scene
{
    ImageBlockManager _ibm;
    PGraphics _base;
    PShader _noise;
    final float _colorChangeSec, _convertStartSec, _totalMovingSec;

    SceneImageConvert(Camera camera, float totalSceneSec, float colorChangeSec, float convertStartSec)
    {
        super(camera, totalSceneSec);
        _colorChangeSec = colorChangeSec;
        _convertStartSec = convertStartSec;
        _totalMovingSec = totalSceneSec - convertStartSec;
    }

    @Override
    void initialize()
    {
        _base = createGraphics(width, height, P2D);
        _noise = _dm.getNoiseShader0();

        updateGraphics(_convertStartSec); // image at the beginning to conversion
        updateGraphics(_convertStartSec); // first update is not go well...
        _ibm = new ImageBlockManager(_base.get(), width/80);
        _ibm.createImageBlocks(_dm.getEyeImage(), _totalMovingSec);
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
        float timeVal = (_convertStartSec - _colorChangeSec) * easeCustom(sec, _colorChangeSec, _convertStartSec, 5);
        _noise.set("resolution", (float)_base.width, (float)_base.height);
        _noise.set("time", timeVal);
        _noise.set("kernel_size", 5);
        _noise.set("hue_offset", sec < _colorChangeSec ? .6 : .8);
        _base.beginDraw();
        _base.shader(_noise);
        _base.rect(0, 0, _base.width, _base.height);
        _base.endDraw();
    }

    float easeCustom(float sec, float sec1, float sec2, float a)
    { // sec1 < sec2
        sec = constrain(sec, 0, sec2);
        return sec < sec1
                ? sec/sec1+a-1
                : sec < (sec1+sec2)/2
                ? a-a*4*pow((sec-sec1)/(sec2-sec1), 3)
                : a*4*pow((sec-sec2)/(sec1-sec2), 3);
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
            PVector[] controls = _util.setCubicBezierControls(_start, _goal, random(-1, 1), random(2), random(-3, 3), random(-3, 3));
            _control1 = controls[0];
            _control2 = controls[1];
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

interface ImageSortable
{
    PImage getImage();
}

class BrightnessComparator implements Comparator<ImageSortable>
{
    @Override
	public int compare(ImageSortable arg1, ImageSortable arg2)
    {
        color c1 = getAverageColor(arg1.getImage());
        color c2 = getAverageColor(arg2.getImage());
		if (brightness(c1) < brightness(c2)) { return 1; }
		else if (brightness(c1) == brightness(c2)) { return 0; }
		else { return -1; }
	}

    private color getAverageColor(PImage img)
    {
        int imgSize = img.width*img.height;
        int red = 0, green = 0, blue = 0;
        img.loadPixels();
        for (int i = 0; i < imgSize; i++)
        {
            color c = img.pixels[i];
            red += red(c);
            green += green(c);
            blue += blue(c);
        }
        red /= imgSize;
        green /= imgSize;
        blue /= imgSize;

        return color(red, green, blue);
    }
}