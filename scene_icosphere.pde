class SceneIcosphere extends Scene
{
    SpikeIcosphere _ico;

    SceneIcosphere(TransitionEffect beginEffect, TransitionEffect endEffect, float totalSceneSec)
    {
        super(beginEffect, endEffect, totalSceneSec);
    }

    @Override
    void initialize()
    {
        _ico = new SpikeIcosphere(height*.24, 1);
        _ico.createFaces();
    }

    @Override
    void start()
    {
        camera(0, 0, (height/2)/tan(PI/6), 0, 0, 0, 0, 1, 0);
    }

    @Override
    void update()
    {
        float val = _curSec*1.4;
        float phi = val;
        float theta = (floor(val) + _util.easeInOutQuad(_util.fract(val)))*HALF_PI;
        PVector rotAxis = new PVector(sin(theta)*cos(phi), cos(theta), sin(theta)*sin(phi));
        _ico.updateMe();
        _ico.rotate(rotAxis, .09, new PVector());
        pushStyle();
        stroke(#e6e6e6);
        fill(#000000);
        _ico.drawMe();
        popStyle();
    }

    @Override
    void postProcessing()
    {
        super.postProcessing();
        _util.resetCamera();
    }

    class SpikeIcosphere extends Icosphere
    {
        ArrayList<TwistedTriangularPrism> _prismList;

        SpikeIcosphere(float radius, int subdivision)
        {
            super(radius, subdivision);
        }

        @Override
        void createFaces()
        {
            super.createFaces();
            _prismList = new ArrayList<TwistedTriangularPrism>();
            for (Triangle face : _faceList)
            {
                TwistedTriangularPrism prism = new TwistedTriangularPrism(face);
                _prismList.add(prism);
            }
        }

        void updateMe()
        {
            for (TwistedTriangularPrism prism : _prismList)
            {
                prism.updateMe(50, 180);
                prism.createFaces();
            }
        }

        @Override
        void drawMe()
        {
            for (TwistedTriangularPrism prism : _prismList)
            {
                prism.drawMe();
            }
        }

        @Override
        void rotate(PVector dir, float rad, PVector init)
        {
            for (TwistedTriangularPrism prism : _prismList)
            {
                prism.rotate(dir, rad, init);
            }
        }
    }

    class TwistedTriangularPrism extends TriangularPrism
    {
        float _rotRad;
        final int _seed = (int)random(65536);

        TwistedTriangularPrism(Triangle bottomFace)
        {
            super(bottomFace, 100);
            _rotRad = TAU;
        }

        @Override
        void createFaces()
        {
            ArrayList<Triangle> markTriangleList = new ArrayList<Triangle>();
            Triangle latest = _bottomFace;
            float[] edges = latest.getEdges();
            float stepLen = (edges[0] + edges[1] + edges[2])/3*.08;
            float stepScale = (_height-stepLen)/_height;
            float minArea = 60;
            int n = (int)(log(minArea/_bottomFace.getArea())/log(stepScale));
            markTriangleList.add(latest);
            for (int i = 0; i < n; i++)
            {
                PVector v1 = PVector.mult(_normal, stepLen).add(latest._v1);
                PVector v2 = PVector.mult(_normal, stepLen).add(latest._v2);
                PVector v3 = PVector.mult(_normal, stepLen).add(latest._v3);
                latest = new Triangle(v1, v2, v3);
                PVector vg = latest.getCenter();
                latest._v1 = scaling(latest._v1, vg, stepScale);
                latest._v2 = scaling(latest._v2, vg, stepScale);
                latest._v3 = scaling(latest._v3, vg, stepScale);
                latest.rotate(_normal, _rotRad/n, vg);
                markTriangleList.add(latest);
                stepLen *= stepScale;
            }

            _faceList = new ArrayList<SimpleShape>();
            for (int i = 0; i < markTriangleList.size()-1; i++)
            {
                Triangle tri1 = markTriangleList.get(i);
                Triangle tri2 = markTriangleList.get(i+1);
                addFace(tri1._v1, tri2._v1, tri2._v2, tri1._v2);
                addFace(tri1._v2, tri2._v2, tri2._v3, tri1._v3);
                addFace(tri1._v3, tri2._v3, tri2._v1, tri1._v1);
            }
            //_faceList.add(_bottomFace);
            //_faceList.add(markTriangleList.get(markTriangleList.size()-1));
        }

        void updateMe(float minH, float maxH)
        {
            float val1 = (1+sin(_curSec*7.5+_seed*.1))/2;
            float val2 = _util.easeInOutCubic(noise(_curSec*2.8, _seed));
            _height = minH + val1*(maxH-minH);
            _rotRad = map(val2, 0, 1, -TAU*3.2, TAU*3.2);
        }

        PVector scaling(PVector v, PVector c, float r)
        {
            return PVector.sub(v, c).mult(r).add(c);
        }

        @Override
        void rotate(PVector dir, float rad, PVector init)
        {
            _bottomFace.rotate(dir, rad, init);
            _normal = PVector.sub(_bottomFace._v2, _bottomFace._v1)
                    .cross(PVector.sub(_bottomFace._v3, _bottomFace._v1))
                    .normalize();
        }
    }
}