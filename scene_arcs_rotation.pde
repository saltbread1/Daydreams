class SceneArcsRotation extends Scene
{
    PGraphics _pg;
    ArcRingManager _rm;

    SceneArcsRotation(Camera camera, float totalSceneSec)
    {
        super(camera, totalSceneSec);
    }

    @Override
    void initialize()
    {
        _pg = createGraphics(width, height, P3D);
        _rm = new ArcRingManager();
        _rm.createRings(16, width*2, 200);
    }

    @Override
    void update()
    {
        _rm.updateRings();
        _pg.beginDraw();
        _pg.background(#000000);
        _pg.blendMode(ADD);
        _rm.drawRings(_pg);
        _pg.endDraw();
        image(_pg, 0, 0);
    }

    class ArcRingManager
    {
        ArrayList<ArcRing> _ringList;

        void createRings(float minRadius, float maxRadius, int n)
        {
            _ringList = new ArrayList<ArcRing>();
            for (int i = 0; i < n; i++)
            {
                float r1 = map(i, 0, n, minRadius, maxRadius);
                float r2 = map(i+1, 0, n, minRadius, maxRadius);
                float maxRotRad = minRadius*.057/sqrt((r1+r2)/2);
                int arcNum = (int)random(12, constrain(sqrt((r1+r2)/2), 12, 64));
                ArcRing ring = new ArcRing(r1, r2+sqrt(r1)*5.3, maxRotRad, arcNum);
                _ringList.add(ring);
            }
        }

        void updateRings()
        {
            for (ArcRing ring : _ringList) { ring.updateMe(); }
        }

        void drawRings(PGraphics pg) { for (ArcRing ring : _ringList) { ring.drawMe(pg); } }
    }

    class ArcRing
    {
        final PVector _trackCenter;
        final float _minRadius, _maxRadius, _maxRotRad, _radOffset;
        final int _arcNum, _rotDir, _seed;
        float _trackRadius, _rad;
        ArrayList<Arc> _arcList;
        final color[] _palette = {#ff0000, #ff9900, #ffff00, #00ff00, #00ffff, #0000ff, #9900ff, #ff00ff};
        final color _colour;

        ArcRing(PVector trackCenter, float minRadius, float maxRadius, float maxRotRad, int arcNum)
        {
            _trackCenter = trackCenter;
            _maxRadius = maxRadius;
            _minRadius = minRadius;
            _maxRotRad = maxRotRad;
            _arcNum = arcNum;
            _radOffset = random(TAU);
            _rotDir = 1-(int)random(2)*2;
            _seed = (int)random(65536);
            _colour = color(_palette[(int)random(_palette.length)], 200);
        }

        ArcRing(float minRadius, float maxRadius, float maxRotRad, int arcNum)
        {
            this(new PVector(width/2, height/2), minRadius, maxRadius, maxRotRad, arcNum);
        }

        void createArcs()
        {
            _arcList = new ArrayList<Arc>();
            float dRad = TAU/(_arcNum*2);
            for (int i = 0; i < _arcNum; i++)
            {
                float k1 = map(_util.easeInOutQuad(noise(_curSec*2.3, _seed+i)), 0, 1, -.48, .48);
                float k2 = map(_util.easeInOutQuad(noise(_curSec*2.3, _seed*_arcNum+i)), 0, 1, -.48, .48);
                float start = dRad*(i*2+k1) + _radOffset;
                float stop = dRad*(i*2+1+k2) + _radOffset;
                Attribution attr = new Attribution(_colour, DrawStyle.FILLONLY);
                _arcList.add(new CustomArc(_trackCenter, _trackRadius, start, stop, attr));
            }
        }

        void updateMe()
        {
            _trackRadius = map(_util.easeInOutQuad(noise(_curSec*4.7, _seed)), 0, 1, _minRadius, _maxRadius);
            createArcs();
            _rad += _util.easeInOutQuad(noise(_curSec*8.4, _seed))*_maxRotRad*_rotDir;
            for (Arc arc : _arcList) { arc.rotate(_rad, _trackCenter); }
        }

        void drawMe(PGraphics pg)
        {
            for (Arc arc : _arcList) { arc.drawMeAttr(pg); }
        }
    }

    class CustomArc extends Arc
    {
        CustomArc(PVector center, float radius, float startRad, float stopRad, Attribution attr)
        {
            super(center, radius, startRad, stopRad, OPEN, attr);
        }

        @Override
        void drawMeAttr()
        {
            super.drawMeAttr();

            float t = .39;
            PVector v1 = PVector.fromAngle(_startRad).mult(_radius).add(_center);
            PVector v2 = PVector.fromAngle(_stopRad).mult(_radius).add(_center);
            PVector v3 = PVector.mult(v2, 1-t).add(PVector.mult(_center, t));
            PVector v4 = PVector.mult(v1, 1-t).add(PVector.mult(_center, t));
            pushStyle();
            beginShape(QUADS);
            if (_attr != null) { _attr.apply(); }
            _util.myVertex(v1);
            _util.myVertex(v2);
            fill(#000000, 80);
            _util.myVertex(v3);
            _util.myVertex(v4);
            endShape();
            popStyle();
        }

        @Override
        void drawMeAttr(PGraphics pg)
        {
            super.drawMeAttr(pg);

            float t = .39;
            PVector v1 = PVector.fromAngle(_startRad).mult(_radius).add(_center);
            PVector v2 = PVector.fromAngle(_stopRad).mult(_radius).add(_center);
            PVector v3 = PVector.mult(v2, 1-t).add(PVector.mult(_center, t));
            PVector v4 = PVector.mult(v1, 1-t).add(PVector.mult(_center, t));
            pg.pushStyle();
            pg.beginShape(QUADS);
            if (_attr != null) { _attr.apply(pg); }
            _util.myVertex(v1, pg);
            _util.myVertex(v2, pg);
            pg.fill(#000000, 80);
            _util.myVertex(v3, pg);
            _util.myVertex(v4, pg);
            pg.endShape();
            pg.popStyle();
        }
    }
}