class Walker
{
    final float _stepLen;
    final int _trailNum;
    final color _colour;
    final Rect _range;
    ArrayDeque<Vertex> _verticesQueue;
    Vertex _latestVertex;
    
    final PVector[] _stepArray;
    IntList _indexesList = new IntList();
    
    Walker(PVector startPos, float stepLen, int trailNum, Rect range, color colour)
    {
        _stepLen = stepLen;
        _verticesQueue = new ArrayDeque<Vertex>();
        _latestVertex = new Vertex(startPos, -1);
        _verticesQueue.add(_latestVertex);
        _trailNum = trailNum;
        _range = range;
        _colour = colour;

        _stepArray = new PVector[] {
                new PVector(1, 1),
                new PVector(-1, 1),
                new PVector(-1, -1),
                new PVector(1, -1)
            };
        for (int i = 0; i < _stepArray.length-1; i++)
        {
            _indexesList.append(i);
        }
    }

    //float getStepLen() { return _stepLen; }

    ArrayDeque<Vertex> getVerticesQueue() { return _verticesQueue; }

    void updateMe(ArrayList<Walker> walkerList)
    {
        int n = _stepArray.length-1;
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
                //float d = PVector.dist(v.getPos(), other.getPos());
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

    void drawMe(PGraphics pg)
    {
        //PGraphics pg = createGraphics((int)_range._width, (int)_range._height, P2D);
        //pg.beginDraw();
        pg.pushStyle();
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
            pg.stroke(_colour);
            pg.fill(_colour);
            pg.vertex(pos.x, pos.y);
            prePos = pos;
        }
        pg.endShape();
        pg.popStyle();
        //pg.endDraw();
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
            int len = _stepArray.length;
            int newIndex = _index >= 0 ? (_index+len/2+1+indexOffset)%len : (int)random(len)%len;
            PVector newPos = PVector.add(_pos, PVector.mult(_stepArray[newIndex], stepLen));
            if (newPos.x > _range._width) { newPos.x -= _range._width; }
            if (newPos.y > _range._height) { newPos.y -= _range._height; }
            if (newPos.x < 0) { newPos.x += _range._width; }
            if (newPos.y < 0) { newPos.y += _range._height; }
            return new Vertex(newPos, newIndex);
        }

        PVector getPos() { return _pos; }
    }
}