class SceneRandomWalk extends Scene
{
    ArrayList<RandomWalkDisplayer> _rwdList;

    SceneRandomWalk(float totalSceneSec)
    {
        super(totalSceneSec);
    }

    @Override
    void initialize()
    {
        _rwdList = new ArrayList<RandomWalkDisplayer>();
        createRWDList(0, 0, width, height, 2);
        for (RandomWalkDisplayer rwd : _rwdList) { rwd.initialize(); }
    }

    @Override
    void update()
    {
        for (RandomWalkDisplayer rwd : _rwdList)
        {
            for (int i = 0; i < 2; i++) { rwd.updateWalkers(); }
            rwd.drawMe();
        }
    }

    void createRWDList(float x, float y, float w, float h, float n)
    {
        if (n <= 0)
        {
            _rwdList.add(new RandomWalkDisplayer(x+2, y+2, w-2, h-2));
            return;
        }
        createRWDList(x, y, w/2, h/2, n-1);
        createRWDList(x+w/2, y, w/2, h/2, n-1);
        createRWDList(x, y+h/2, w/2, h/2, n-1);
        createRWDList(x+w/2, y+h/2, w/2, h/2, n-1);
    }

    @Override
    void clearScene() { background(#ffffff); }

    class RandomWalkDisplayer extends Rect
    {
        final PGraphics _pg;
        final color[] _palette = {
            #000000, #ffffff
        };
        ArrayList<Walker> _walkerList;

        RandomWalkDisplayer(float x, float y, float width, float height)
        {
            super(new PVector(x, y), width, height);
            _pg = createGraphics((int)width, (int)height, P2D);
        }

        void initialize()
        {
            _walkerList = new ArrayList<Walker>();
            for (int i = 0; i < 8; i++)
            {
                PVector v = new PVector(random(_width), random(_height));
                float l = max(2, sq(random(1))*_width*.03);
                int n = (int)random(36, 90);
                Rect r = this;
                color c = _palette[(int)random(_palette.length)];
                _walkerList.add(new Walker(v, l, n, r, c));
            }
            for (Walker walker : _walkerList)
            {
                for (int i = 0; i < walker.getTrailNum(); i++) { walker.updateMe(_walkerList); }
            }
        }

        void updateWalkers()
        {
            for (Walker walker : _walkerList) { walker.updateMe(_walkerList); }
        }

        @Override
        void drawMe()
        {
            _pg.pushStyle(); 
            _pg.beginDraw();
            _pg.background(#ec0000);
            for (Walker walker : _walkerList) { walker.drawMe(_pg); }
            _pg.endDraw();
            _pg.popStyle();
            image(_pg, (int)_upperLeft.x, (int)_upperLeft.y);
        }
    }
}