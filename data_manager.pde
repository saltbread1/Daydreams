class DataManager
{
    final PImage _imgEye, _imgHand, _imgMouth;
    final PImage[] _imgEyes, _imgEyesAlpha;
    final PShader _shaderNoise0, _shaderNoise1, _shaderGlitch;
    final HashMap<String, PixelData> _textMap;

    DataManager()
    {
        _imgEye = loadImage("eye.png");
        _imgHand = loadImage("hand_a.png");
        _imgMouth = loadImage("mouth_a.png");
        _imgEyes = new PImage[3];
        _imgEyesAlpha = new PImage[3];
        for (int i = 0; i < 3; i++)
        {
            _imgEyes[i] = loadImage("eye"+i+".png");
            _imgEyesAlpha[i] = loadImage("eye"+i+"_a.png");
        }
        _shaderNoise0 = loadShader("noise0.glsl");
        _shaderNoise1 = loadShader("noise1.glsl");
        _shaderGlitch = loadShader("glitch.glsl");

        _textMap = new HashMap<String, PixelData>();
    }

    void preprocessing()
    {
        int cNum = 4;
        _imgEye.resize(width, height);
        _imgMouth.resize(height*_imgMouth.width/_imgMouth.height, height);
        _imgHand.filter(POSTERIZE, cNum);
        _imgMouth.filter(POSTERIZE, cNum);
        for (int i = 0; i < 3; i++)
        {
            _imgEyes[i].filter(POSTERIZE, cNum);
            _imgEyesAlpha[i].filter(POSTERIZE, cNum);
        }

        _textMap.put(" ", new PixelData(new int[]{}, 6));
        _textMap.put("0", new PixelData(new int[]{0x3C, 0x62, 0xE1, 0xE1, 0xE1, 0xE1, 0xE1, 0xF1, 0xFE, 0x7C}, 8));
        _textMap.put("2", new PixelData(new int[]{0x7E, 0xE3, 0xE1, 0xE0, 0xF0, 0x38, 0x1C, 0xE, 0xFF, 0xFF}, 8));
        _textMap.put("3", new PixelData(new int[]{0x7E, 0xE3, 0xE1, 0xE0, 0x7C, 0xE0, 0xE0, 0xE3, 0xFF, 0xFE}, 8));
        _textMap.put("a", new PixelData(new int[]{0x3E, 0x73, 0x70, 0x7E, 0x71, 0xF1, 0xF9, 0xFF, 0xFF}, 8));
        _textMap.put("d", new PixelData(new int[]{0x70, 0x70, 0x70, 0x70, 0x70, 0x7E, 0x71, 0xF1, 0xF9, 0xFF, 0xFF}, 8));
        _textMap.put("e", new PixelData(new int[]{0x7E, 0xE1, 0xE1, 0xFF, 0x1, 0x1, 0xFF, 0xFF}, 8));
        _textMap.put("k", new PixelData(new int[]{0x3, 0x3, 0x3, 0x63, 0x33, 0x1B, 0xF, 0x1F, 0x7B, 0x73}, 7));
        _textMap.put("m", new PixelData(new int[]{0x7FE, 0x733, 0x733, 0x733, 0x733, 0x733, 0x733, 0x703, 0x3}, 11));
        _textMap.put("r", new PixelData(new int[]{0xFD, 0xE5, 0xE7, 0xE1, 0x1, 0x1, 0x1, 0x1, 0x1}, 8));
        _textMap.put("s", new PixelData(new int[]{0xFE, 0xE3, 0x1, 0x1, 0xFF, 0xE0, 0xE1, 0xFF, 0xFF}, 8));
        _textMap.put("t", new PixelData(new int[]{0x1C, 0x1C, 0x7F, 0x1C, 0x1C, 0x1C, 0x1C, 0x1C, 0x3C, 0x3C}, 7));
        _textMap.put("y", new PixelData(new int[]{0x1C0, 0x1C6, 0x1C7, 0x1C4, 0x1F4, 0x1DC, 0x1C0, 0x1C0, 0x1C0, 0x1FE, 0x1FE}, 9));
        _textMap.put("D", new PixelData(new int[]{0x3F, 0xC1, 0x1C1, 0x381, 0x381, 0x381, 0x381, 0x381, 0x381, 0x3E1, 0x1FF, 0x7F}, 10));
    }

    PImage getEyeImage() { return _imgEye; }

    PImage getHandImage() { return _imgHand; }

    PImage getMouthImage() { return _imgMouth; }

    PImage[] getEyeImages() { return _imgEyes; }

    PImage[] getEyeAlphaImages() { return _imgEyesAlpha; }

    PShader getNoiseShader0() { return _shaderNoise0; }

    PShader getNoiseShader1() { return _shaderNoise1; }

    PShader getGlitchShader() { return _shaderGlitch; }

    HashMap<String, PixelData> getTextMap() { return _textMap; }
}

class PixelData
{
    final int[] _data;
    final int _bitLen;

    PixelData(int[] data, int bitLen)
    {
        _data = data;
        _bitLen = bitLen;
    }

    /**
    *   draw pixel image
    *   @param  x the left position
    *   @param  y the bottom position
    *   @param  pixelSize the size of one pixel
    */
    void drawData(int x, int y, int pixelSize)
    {
        for (int i = 0; i < _data.length; i++)
        {
            for (int j = 0; j < _bitLen; j++)
            {
                if ((_data[_data.length-i-1] & (1<<j)) == 0) { continue; }
                rect(x+pixelSize*j, y-pixelSize*i, pixelSize, pixelSize);
            }
        }
    }

    /**
    *   draw pixel image on the PGraphics
    *   @param  x the left position
    *   @param  y the bottom position
    *   @param  pixelSize the size of one pixel
    */
    void drawData(PGraphics pg, int x, int y, int pixelSize)
    {
        for (int i = 0; i < _data.length; i++)
        {
            for (int j = 0; j < _bitLen; j++)
            {
                if ((_data[_data.length-i-1] & (1<<j)) == 0) { continue; }
                pg.rect(x+pixelSize*j, y-pixelSize*i, pixelSize, pixelSize);
            }
        }
    }

    int getBitLength() { return _bitLen; }
}