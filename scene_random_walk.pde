class SceneRandomWalk extends Scene
{
    ArrayList<RandomWalkDisplayer> _screenList;

    SceneRandomWalk(float totalSceneSec)
    {
        super(totalSceneSec);
    }

    @Override
    void initialize()
    {
        _screenList = new ArrayList<RandomWalkDisplayer>();
        createScreens(0, 0, width, height, 2);
        for (RandomWalkDisplayer screen : _screenList) { screen.initialize(); }
    }

    @Override
    void update()
    {
        for (RandomWalkDisplayer screen : _screenList)
        {
            for (int i = 0; i < 2; i++) { screen.updateWalkers(); }
            screen.drawMe();
        }
    }

    void createScreens(float x, float y, float w, float h, float n)
    {
        if (n <= 0)
        {
            _screenList.add(new RandomWalkDisplayer(x, y, w, h));
            return;
        }
        createScreens(x, y, w/2, h/2, n-1);
        createScreens(x+w/2, y, w/2, h/2, n-1);
        createScreens(x, y+h/2, w/2, h/2, n-1);
        createScreens(x+w/2, y+h/2, w/2, h/2, n-1);
    }

    @Override
    void clearScene() { background(#000000); }

    class RandomWalkDisplayer extends Rect
    {
        final PGraphics _pg;
        ArrayList<Walker> _walkerList;

        RandomWalkDisplayer(float x, float y, float width, float height)
        {
            super(x, y, width, height);
            _pg = createGraphics((int)width, (int)height, P2D);
            _pg.beginDraw();
            _pg.background(#000000);
            _pg.endDraw();
        }

        void initialize()
        {
            _walkerList = new ArrayList<Walker>();
            for (int i = 0; i < 8; i++)
            {
                _walkerList.add(new Walker(
                        new PVector(random(_width), random(_height)),
                        max(2, sq(random(1))*sqrt(_width*_height)*.03),
                        (int)random(36, 90),
                        this,
                        new Attribution(
                                random(1) < .5 ? #ffffff : #00c0f2,
                                DrawStyle.STROKEANDFILL)));
            }
            for (Walker walker : _walkerList)
            {
                for (int i = 0; i < walker.getTrailNum(); i++)
                {
                    walker.updateMe(_walkerList);
                }
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
            _pg.fill(#000000, 40);
            _pg.noStroke();
            _pg.rect(0, 0, _width, _height);
            for (Walker walker : _walkerList) { walker.drawMeAttr(_pg); }
            _pg.endDraw();
            _pg.popStyle();
            image(_pg, (int)_upperLeft.x, (int)_upperLeft.y);
        }
    }
}