class DataManager
{
    final PImage _imgEye, _imgHand, _imgMouth;
    final PImage[] _imgEyes, _imgEyesAlpha;
    final PShader _shaderNoise;

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
        _shaderNoise = loadShader("noise.glsl");
    }

    void preprocessing()
    {
        int cNum = 4;
        _imgEye.resize(width, height);
        _imgMouth.resize((int)((height*.84)*_imgMouth.width/_imgMouth.height), (int)(height*.84));
        _imgHand.filter(POSTERIZE, cNum);
        _imgMouth.filter(POSTERIZE, cNum);
        for (int i = 0; i < 3; i++)
        {
            _imgEyes[i].filter(POSTERIZE, cNum);
            _imgEyesAlpha[i].filter(POSTERIZE, cNum);
        }
    }

    PImage getEyeImage() { return _imgEye; }

    PImage getHandImage() { return _imgHand; }

    PImage getMouthImage() { return _imgMouth; }

    PImage[] getEyeImages() { return _imgEyes; }

    PImage[] getEyeAlphaImages() { return _imgEyesAlpha; }

    PShader getNoiseShader() { return _shaderNoise; }
}