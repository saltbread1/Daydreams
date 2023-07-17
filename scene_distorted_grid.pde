class SceneDistortedGrid extends Scene
{
    DistortedGrid _grid;

    SceneDistortedGrid(float totalSceneSec)
    {
        super(totalSceneSec);
    }

    @Override
    void initialize()
    {
        _grid = new DistortedGrid(width*1.1, height*1.1, width*.03, height*.03);
    }

    @Override
    void update()
    {
        _grid.updateMe();
        _grid.drawMe();
    }

    class DistortedGrid
    {
        final PVector _center;
        final float _totalLenX, _totalLenY, _stepLenX, _stepLenY;
        final int _resX, _resY;
        final int _seedX, _seedY;
        final Rect _limit;
        ArrayList<Rect> _rectList;

        DistortedGrid(PVector center, float totalLenX, float totalLenY, float stepLenX, float stepLenY)
        {
            _center = center;
            _totalLenX = totalLenX;
            _totalLenY = totalLenY;
            _stepLenX = stepLenX;
            _stepLenY = stepLenY;
            _resX = (int)(_totalLenX/_stepLenX);
            _resY = (int)(_totalLenY/_stepLenY);
            _seedX = (int)random(65536);
            _seedY = (int)random(65536);
            _limit = new Rect(
                    new PVector(-totalLenX/2+stepLenX*2, -totalLenY/2+stepLenY*2).add(center),
                    new PVector(totalLenX/2-stepLenX*2, totalLenY/2-stepLenY*2).add(center));
        }

        DistortedGrid(float totalLenX, float totalLenY, float stepLenX, float stepLenY)
        {
            this(new PVector(width/2, height/2), totalLenX, totalLenY, stepLenX, stepLenY);
        }

        void createGrid(float s, float t)
        {
            PVector[][] vertices = new PVector[_resX+1][_resY+1];
            float noiseScale = .1;
            for (int i = 0; i <= _resX; i++)
            {
                for (int j = 0; j <= _resY; j++)
                {
                    float x = map(i, 0, _resX, -_totalLenX/2, _totalLenX/2);
                    float y = map(j, 0, _resY, -_totalLenY/2, _totalLenY/2);
                    float nValX = noise(i*noiseScale+s*1.8, j*noiseScale+s, _seedX+t);
                    float nValY = noise(i*noiseScale+s*.6, j*noiseScale+s*1.3, _seedY+t);
                    float offX = constrain((1-nValX*2)*4, -1, 1)*_stepLenX*1.6;
                    float offY = constrain((1-nValY*2)*4, -1, 1)*_stepLenY*1.6;
                    PVector offset = new PVector(offX, offY);
                    vertices[i][j] = new PVector(x, y).add(offset).add(_center);
                }
            }

            _rectList = new ArrayList<Rect>();
            for (int i = 0; i < _resX; i++)
            {
                for (int j = 0; j < _resY; j++)
                {
                    Rect rect1 = new Rect(vertices[i][j], vertices[i+1][j]);
                    Rect rect2 = new Rect(vertices[i][j], vertices[i][j+1]);
                    _rectList.add(rect1);
                    _rectList.add(rect2);
                }
            }
        }

        void updateMe()
        {
            createGrid(_curSec, _curSec*2.3);
        }

        void drawMe()
        {
            pushStyle();
            noStroke();
            fill(#ffffff);
            for (Rect rect : _rectList) { rect.drawMe(); }
            popStyle();
        }
    }
}