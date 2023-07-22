class DataManager
{
    final PImage _imgEye, _imgHand;
    final PImage[] _imgEyes;
    final PShader _shaderNoise;

    DataManager()
    {
        _imgEye = loadImage("eye.png");
        _imgHand = loadImage("hand.png");
        _imgEyes = new PImage[3];
        for (int i = 0; i < _imgEyes.length; i++)
        {
            _imgEyes[i] = loadImage("eye"+i+".png");
        }
        _shaderNoise = loadShader("noise.glsl");
    }

    void setFilter()
    {
        _imgEye.filter(POSTERIZE, 5);
        _imgHand.filter(POSTERIZE, 5);
        for (int i = 0; i < _imgEyes.length; i++)
        {
            _imgEyes[i].filter(POSTERIZE, 5);
        }
    }

    PImage getEyeImage() { return _imgEye; }

    PImage getHandImage() { return _imgHand; }

    PImage[] getEyeImages() { return _imgEyes; }

    PShader getNoiseShader() { return _shaderNoise; }
}