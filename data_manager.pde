class DataManager
{
    final PImage _imgEye, _imgHand;
    final PImage[] _imgEyes, _imgEyesAlpha;
    final PShader _shaderNoise;

    DataManager()
    {
        _imgEye = loadImage("eye.png");
        _imgHand = loadImage("hand_a.png");
        _imgEyes = new PImage[3];
        _imgEyesAlpha = new PImage[3];
        for (int i = 0; i < 3; i++)
        {
            _imgEyes[i] = loadImage("eye"+i+".png");
            _imgEyesAlpha[i] = loadImage("eye"+i+"_a.png");
        }
        _shaderNoise = loadShader("noise.glsl");
    }

    void setFilter()
    {
        _imgEye.resize(width, height);
        _imgEye.filter(POSTERIZE, 5);
        _imgHand.filter(POSTERIZE, 5);
        for (int i = 0; i < 3; i++)
        {
            _imgEyes[i].filter(POSTERIZE, 5);
            _imgEyesAlpha[i].filter(POSTERIZE, 5);
        }
    }

    PImage getEyeImage() { return _imgEye; }

    PImage getHandImage() { return _imgHand; }

    PImage[] getEyeImages() { return _imgEyes; }

    PImage[] getEyeAlphaImages() { return _imgEyesAlpha; }

    PShader getNoiseShader() { return _shaderNoise; }
}