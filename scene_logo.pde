class SceneLogo extends Scene
{
    final float _vibrationStartSec;
    PGraphics _pg;
    PShader _glitch;
    Logo _logo;
    int _seed;

    SceneLogo(Camera camera, float totalSceneSec, float vibrationStartSec)
    {
        super(camera, totalSceneSec);
        _vibrationStartSec = vibrationStartSec;
    }

    @Override
    void initialize()
    {
        _pg = createGraphics(width, height, P2D);
        _glitch = _dm.getGlitchShader();
        _glitch.set("resolution", (float)width, (float)height);
        _logo = new Logo();
        _seed = (int)random(65536);
    }

    @Override
    void update()
    {
        int x = _curSec < _vibrationStartSec
                ? 0
                : (int)(pow(random(-1, 1), 3)*width*.15);
        _glitch.set("time", _curSec*16);
        _pg.beginDraw();
        _pg.background(#000000);
        _pg.pushStyle();
        _pg.noStroke();
        // _pg.fill(#000000);
        // _pg.rect(0, 0, width+x, height);
        _pg.fill(#ffffff);
        _logo.drawText("Daydreams", _pg, x, height/2, (int)(width/100), 2);
        _logo.drawText("take 2023", _pg, x, height/2+24*(int)(width/200), (int)(width/200), 2);
        _pg.popStyle();
        if (_curSec > _vibrationStartSec) { _pg.filter(_glitch); }
        _pg.endDraw();
        image(_pg, 0, 0);
    }

    @Override
    void clearScene() { background(#ffffff); }

    class Logo
    {
        void drawText(String text, int offX, int bottom, int pixelSize, int emptyOffset)
        {
            ArrayDeque<PixelData> dataQueue = createTextQueue(text);
            int x = width/2 - calcTextLength(dataQueue, pixelSize, emptyOffset)/2; // place at the center
            x += offX;
            for (PixelData data : dataQueue)
            {
                data.drawData(x, bottom, pixelSize);
                x += (data.getBitLength() + emptyOffset) * pixelSize;
            }
        }

        void drawText(String text, PGraphics pg, int offX, int bottom, int pixelSize, int emptyOffset)
        {
            ArrayDeque<PixelData> dataQueue = createTextQueue(text);
            int x = width/2 - calcTextLength(dataQueue, pixelSize, emptyOffset)/2; // place at the center
            x += offX;
            for (PixelData data : dataQueue)
            {
                data.drawData(pg, x, bottom, pixelSize);
                x += (data.getBitLength() + emptyOffset) * pixelSize;
            }
        }

        ArrayDeque<PixelData> createTextQueue(String text)
        {
            ArrayDeque<PixelData> dataQueue = new ArrayDeque<PixelData>();
            for (int i = 0; i < text.length(); i++)
            {
                dataQueue.add(_dm.getTextMap().get(text.charAt(i)+""));
            }
            return dataQueue;
        }

        int calcTextLength(ArrayDeque<PixelData> dataQueue, int pixelSize, int emptyOffset)
        {
            int l = -emptyOffset * pixelSize;
            for (PixelData data : dataQueue)
            {
                l += (data.getBitLength() + emptyOffset) * pixelSize;
            }
            return l;
        }
    }
}