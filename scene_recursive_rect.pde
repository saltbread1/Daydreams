class SceneRecursiveRect extends Scene
{
    ArrayDeque<RecursiveRect> _rectQueue;
    RecursiveRect _latest;
    final float _scale = .5;

    SceneRecursiveRect(float totalSceneSec)
    {
        super(totalSceneSec);
    }

    @Override
    void initialize()
    {
        _latest = new RecursiveRect(width, height);
        _rectQueue = new ArrayDeque<RecursiveRect>();
        _rectQueue.add(_latest);
        float w = width * _scale;
        float h = height * _scale;
        while (w*h > 80)
        {
            RecursiveRect rect = new RecursiveRect(w, h, _latest);
            _rectQueue.add(rect);
            _latest = rect;
            w *= _scale; h *= _scale;
        }
    }

    void addNewRect()
    {
        RecursiveRect rect = new RecursiveRect(_latest._width*_scale, _latest._height*_scale, _latest);
        _rectQueue.add(rect);
        _latest = rect;
    }

    @Override
    void update()
    {
        RecursiveRect first = _rectQueue.peek();
        float dh = 8;

        if (first._width > width)
        {
            _rectQueue.poll();
            addNewRect();
        }

        for (RecursiveRect rect : _rectQueue)
        {
            rect.updateSize(dh);
            dh *= _scale;
        }

        for (RecursiveRect rect : _rectQueue)
        {
            rect.updateMe();
            pushStyle();
            stroke(#ffffff);
            noFill();
            rect.drawMe();
            popStyle();
        }
    }
}