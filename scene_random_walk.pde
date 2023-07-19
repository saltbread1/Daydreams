class SceneRandomWalk extends Scene
{
    RandomWalkDisplayer _displayer;

    SceneRandomWalk(float totalSceneSec)
    {
        super(totalSceneSec);
    }

    @Override
    void initialize()
    {
        _displayer = new RandomWalkDisplayer(0, 0, width, height);
        _displayer.initialize();
        for (int i = 0; i < 200; i++) { _displayer.updateWalkers(); }
    }

    @Override
    void start()
    {
        background(#000000);
    }

    @Override
    void update()
    {
        for (int i = 0; i < 4; i++) { _displayer.updateWalkers(); }
        _displayer.drawMeAttr();
    }

    @Override
    void clearScene() {}

    class RandomWalkDisplayer extends Rect
    {
        ArrayList<Walker> _walkerList;
        final float _width, _height;
        final color[] _palette = {#ffffff, #00c0f2, #00f2c0};

        RandomWalkDisplayer(float x, float y, float width, float height)
        {
            super(x, y, width, height);
            _width = getWidth();
            _height = getHeight();
            setAttribution(new Attribution(color(#000000, 60), DrawStyle.FILLONLY));
        }

        void initialize()
        {
            _walkerList = new ArrayList<Walker>();
            for (int i = 0; i < 64; i++)
            {
                _walkerList.add(new Walker(
                        new PVector(random(_width), random(_height)),
                        max(2, sq(random(1))*sqrt(_width*_height)*.01),
                        (int)random(36, 90),
                        this,
                        new Attribution(
                                color(_palette[(int)(min((1-sqrt(random(1)))*1.2, .9)*_palette.length)], 40),
                                random(1) < .5 ? DrawStyle.STROKEANDFILL : DrawStyle.STROKEONLY)));
            }
        }

        void updateWalkers()
        {
            for (Walker walker : _walkerList) { walker.updateMe(); }
        }

        @Override
        void drawMe()
        {
            rect(0, 0, _width, _height);
            for (Walker walker : _walkerList) { walker.drawMeAttr(); }
        }

        @Override
        void drawMe(PGraphics pg)
        {
            pg.rect(0, 0, _width, _height);
            for (Walker walker : _walkerList) { walker.drawMeAttr(pg); }
        }
    }

    class Walker extends SimpleShape
    {
        final float _stepLen;
        final int _trailNum, _dirTypeNum = 4;
        final Rect _range;
        ArrayDeque<Vertex> _verticesQueue;
        Vertex _latestVertex;
        
        IntList _indexesList = new IntList();
        
        Walker(PVector startPos, float stepLen, int trailNum, Rect range, Attribution attr)
        {
            super(attr);
            _stepLen = stepLen;
            _verticesQueue = new ArrayDeque<Vertex>();
            _latestVertex = new Vertex(startPos, -1);
            _verticesQueue.add(_latestVertex);
            _trailNum = trailNum;
            _range = range;
            for (int i = 0; i < _dirTypeNum-1; i++)
            {
                _indexesList.append(i);
            }
        }

        void updateMe()
        {
            int n = _dirTypeNum-1;
            _indexesList.shuffle();
            for (int i = 0; i < n; i++)
            {
                Vertex newVertex = _latestVertex.getNextStepVertex(_stepLen, _indexesList.get(i));
                if (!isOverlap(newVertex))
                {
                    _latestVertex = newVertex;
                    break;
                }
                else if (i == n-1)
                {
                    _latestVertex = _latestVertex.getNextStepVertex(_stepLen, (int)random(n));
                }
            }
            _verticesQueue.add(_latestVertex);
            while (_verticesQueue.size() > _trailNum) { _verticesQueue.poll(); }
        }

        boolean isOverlap(Vertex v)
        {
            for (Vertex other : _verticesQueue)
            {
                PVector a1 = PVector.fromAngle(QUARTER_PI);
                PVector a2 = PVector.fromAngle(QUARTER_PI*3);
                PVector b = PVector.sub(other.getPos(), v.getPos());
                float d = sqrt(max(production(a1, b).magSq(), production(a2, b).magSq()));
                if (_stepLen > d) { return true; }
            }
            return false;
        }

        PVector production(PVector a, PVector b)
        { // calc production vector: b to a
            return PVector.mult(a, a.dot(b)/a.magSq());
        }

        @Override
        void drawMe()
        {
            int n = 6;
            PVector init = new PVector(width/2, height/2);
            for (int i = 0; i < n*2; i++)
            {
                float rot = TAU/n*i;
                PVector prePos = _util.rotate(_verticesQueue.peek().getPos(), rot, init);
                if (i >= n) { prePos.y = init.y - (prePos.y - init.y); }
                beginShape(TRIANGLE_STRIP);
                for (Vertex v : _verticesQueue)
                {
                    PVector pos = _util.rotate(v.getPos(), rot, init);
                    if (i >= n) { pos.y = init.y - (pos.y - init.y); }
                    if (PVector.dist(prePos, pos) > _stepLen*2)
                    {
                        endShape();
                        beginShape(TRIANGLE_STRIP);
                    }
                    _util.myVertex(pos);
                    prePos = pos;
                }
                endShape();
            }
        }

        @Override
        void drawMe(PGraphics pg)
        {
            int n = 6;
            PVector init = new PVector(width/2, height/2);
            for (int i = 0; i < n*2; i++)
            {
                float rot = TAU/n*i;
                PVector prePos = _util.rotate(_verticesQueue.peek().getPos(), rot, init);
                if (i >= n) { prePos.y = init.y - (prePos.y - init.y); }
                pg.beginShape(TRIANGLE_STRIP);
                for (Vertex v : _verticesQueue)
                {
                    PVector pos = _util.rotate(v.getPos(), rot, init);
                    if (i >= n) { pos.y = init.y - (pos.y - init.y); }
                    if (PVector.dist(prePos, pos) > _stepLen*2)
                    {
                        pg.endShape();
                        pg.beginShape(TRIANGLE_STRIP);
                    }
                    _util.myVertex(pos, pg);
                    prePos = pos;
                }
                pg.endShape();
            }
        }

        class Vertex
        {
            final PVector _pos;
            final int _index;

            Vertex(PVector pos, int index)
            {
                _pos = pos;
                _index = index;
            }

            Vertex getNextStepVertex(float stepLen, int indexOffset)
            {
                int newIndex = _index >= 0
                    ? (_index+_dirTypeNum/2+1+indexOffset)%_dirTypeNum
                    : (int)random(_dirTypeNum)%_dirTypeNum;
                PVector newPos = PVector.add(_pos,
                        PVector.mult(DirectionType.values()[newIndex*2+1].getDirection(), stepLen));
                float w = _range.getWidth();
                float h = _range.getHeight();
                if (newPos.x > w) { newPos.x -= w; }
                if (newPos.y > h) { newPos.y -= h; }
                if (newPos.x < 0) { newPos.x += w; }
                if (newPos.y < 0) { newPos.y += h; }
                return new Vertex(newPos, newIndex);
            }

            PVector getPos() { return _pos; }
        }
    }
}