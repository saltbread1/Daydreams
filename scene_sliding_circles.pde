class SceneSlidingCircles
{
    PGraphics _pg;
    CircleManager _cm;
    GraphicsManager _gm;

    SceneSlidingCircles(float totalSceneSec)
    {
        super(totalSceneSec);
    }

    @Override
    void initialize()
    {
        _pg = createGraphics(width, height, P2D);
        _cm = new CircleManager();
        _gm = new GraphicsManager();
    }

    @Override
    void update()
    {
        _pg.beginDraw();
        _pg.background(#000000);
        _cm.drawCircles(_pg);
        _pg.endDraw();
    }

    class SlidingCircle extends Circle
    {
        final PVector _step;
        PVector _start, _goal;
        final float _stepTotalSec;
        float _stepSec;

        SlidingCircle(PVector center, float radius, Attribution attr)
        {
            super(center, radius, attr);
        }

        void setStepParameters()
        {
            _start = _center.copy();
            _goal = PVector.add(_start, _step);
        }

        void updateMe()
        {

        }
    }

    class CircleManager
    {
        ArrayList<SlidingCircle> _circleList;

        CircleManager()
        {
            
        }

        void createCircles()
        {
            _circleList = new ArrayList<SlidingCircle>();
        }

        void updateCircles()
        {
            for (SlidingCircle circle : _circleList)
            {
                circle.updateMe();
            }
        }

        void drawCircles(PGraphics pg)
        {
            for (SlidingCircle circle : _circleList)
            {
                circle.drawMeAttr(pg);
            }
        }
    }
}