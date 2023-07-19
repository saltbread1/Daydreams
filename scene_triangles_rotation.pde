class SceneTrianglesRotation extends Scene
{
    HashMap<Triangle, Float> _triangleMap;
    ArrayList<Circle> _circleList;
    final color[] _palette = {#333333, #332c26, #333300, #192c26, #192c2c, #000033, #260033, #330033};

    SceneTrianglesRotation(float totalSceneSec)
    {
        super(totalSceneSec);
    }

    @Override
    void initialize()
    {
        _circleList = new ArrayList<Circle>();
        for (int i = 0; i < 16; i++)
        {
            PVector c = new PVector(random(width), random(height));
            float r = width*.002;
            _circleList.add(new Circle(c, r));
        }

        _triangleMap = new HashMap<Triangle, Float>();
        for (int i = 0; i < 256; i++)
        {
            Circle circle = null;
            for (int j = 0; j < 100; j++)
            {
                PVector c = new PVector(random(width), random(height));
                float r = random(width*.02, width*.24);
                circle = new Circle(c, r);
                if (!isOverlap(circle)) { break; }
            }
            float dRotRad = random(.02, .28)*(1-(int)random(2)*2);
            _triangleMap.put(createTriangle(circle), Float.valueOf(dRotRad));
        }
    }

    Triangle createTriangle(Circle circle)
    {
        float start = random(TAU);
        float goal = start + TAU*.23;
        float offset = TAU/3;

        PVector v1 = PVector.fromAngle(random(start, goal)).mult(circle._radius);
        PVector v2 = PVector.fromAngle(random(start, goal) + offset).mult(circle._radius);
        PVector v3 = PVector.fromAngle(random(start, goal) + offset*2).mult(circle._radius);
        Attribution attr = new Attribution(
                color(_palette[(int)random(_palette.length)], 100),
                DrawStyle.FILLONLY);
        Triangle tri = new Triangle(v1, v2, v3, attr);
        tri.translate(circle._center);

        return tri;
    }

    boolean isOverlap(Circle circle)
    {
        for (Circle other : _circleList)
        {
            float d = PVector.dist(other._center, circle._center);
            if (d < other._radius + circle._radius)
            {
                return true;
            }
        }
        return false;
    }

    @Override
    void update()
    {
        PGraphics pg = createGraphics(width, height, P2D);
        pg.beginDraw();
        pg.blendMode(SUBTRACT);
        for (Triangle tri : _triangleMap.keySet())
        {
            float dRad = _triangleMap.get(tri);
            tri.rotate(dRad, tri.getCenter());
            tri.drawMeAttr(pg);
        }
        pg.endDraw();
        image(pg, 0, 0);
    }
}