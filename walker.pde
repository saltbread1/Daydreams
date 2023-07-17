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

    ArrayDeque<Vertex> getVerticesQueue() { return _verticesQueue; }

    void updateMe(ArrayList<Walker> walkerList)
    {
        int n = _dirTypeNum-1;
        _indexesList.shuffle();
        for (int i = 0; i < n; i++)
        {
            Vertex newVertex = _latestVertex.getNextStepVertex(_stepLen, _indexesList.get(i));
            if (!isOverlap(newVertex, walkerList))
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
        if (_verticesQueue.size() > _trailNum) { _verticesQueue.poll(); }
    }

    boolean isOverlap(Vertex v, ArrayList<Walker> walkerList)
    {
        for (Walker walker : walkerList)
        {
            ArrayDeque<Vertex> verticesQueue = walker.getVerticesQueue();
            for (Vertex other : verticesQueue)
            {
                PVector a1 = PVector.fromAngle(QUARTER_PI);
                PVector a2 = PVector.fromAngle(QUARTER_PI*3);
                PVector b = PVector.sub(other.getPos(), v.getPos());
                float d = sqrt(max(production(a1, b).magSq(), production(a2, b).magSq()));
                if (_stepLen > d) { return true; }
            }
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
        beginShape(TRIANGLE_STRIP);
        PVector prePos = _verticesQueue.peek().getPos();
        for (Vertex v : _verticesQueue)
        {
            PVector pos = v.getPos();
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

    @Override
    void drawMe(PGraphics pg)
    {
        pg.beginShape(TRIANGLE_STRIP);
        PVector prePos = _verticesQueue.peek().getPos();
        for (Vertex v : _verticesQueue)
        {
            PVector pos = v.getPos();
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

    int getTrailNum() { return _trailNum; }

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
            if (newPos.x > _range._width) { newPos.x -= _range._width; }
            if (newPos.y > _range._height) { newPos.y -= _range._height; }
            if (newPos.x < 0) { newPos.x += _range._width; }
            if (newPos.y < 0) { newPos.y += _range._height; }
            return new Vertex(newPos, newIndex);
        }

        PVector getPos() { return _pos; }
    }
}