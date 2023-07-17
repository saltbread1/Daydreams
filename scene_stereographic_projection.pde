class SceneStereographicProjection extends Scene
{
    StereographicGasket _gasket;

    SceneStereographicProjection(float totalSceneSec)
    {
        super(totalSceneSec);
    }

    @Override
    void initialize()
    {
        _gasket = new StereographicGasket(height*.24, 5);
        _gasket.createFaces();
    }

    @Override
    void start()
    {
        camera(0, 0, (height/2)/tan(PI/6), 0, 0, 0, 0, 1, 0);
    }

    @Override
    void update()
    {
        float phi = _curSec*4.4;
        float theta = _curSec*2.4 + .66;
        PVector rotAxis = new PVector(sin(theta)*cos(phi), cos(theta), sin(theta)*sin(phi));
        _gasket.rotate(rotAxis, .12, new PVector());
        _gasket.drawMe();
    }

    @Override
    void postProcessing()
    {
        super.postProcessing();
        _util.resetCamera();
    }

    class StereographicGasket extends Icosphere
    {
        StereographicGasket(float radius, int subdivision)
        {
            super(radius, subdivision);
        }

        @Override
        void split()
        {
            int len = _faceList.size();
            for (int i = 0; i < len; i++)
            {
                Triangle face = _faceList.poll();
                PVector newv1 = PVector.add(face._v1, face._v2).div(2.);
                PVector newv2 = PVector.add(face._v2, face._v3).div(2.);
                PVector newv3 = PVector.add(face._v3, face._v1).div(2.);
                newv1.mult(_radius / newv1.mag());
                newv2.mult(_radius / newv2.mag());
                newv3.mult(_radius / newv3.mag());
                Attribution attr1 = new Attribution(#ffffff, DrawStyle.FILLONLY);
                Attribution attr2 = new Attribution(#000000, DrawStyle.FILLONLY);
                if (attr2.equals(face.getAttribution()))
                {
                    _faceList.add(new Triangle(newv1, newv2, newv3, attr1));
                    continue;
                }
                _faceList.add(new Triangle(face._v1, newv1   , newv3   , attr1));
                _faceList.add(new Triangle(newv1   , face._v2, newv2   , attr1));
                _faceList.add(new Triangle(newv3   , newv2   , face._v3, attr1));
                _faceList.add(new Triangle(newv1   , newv2   , newv3   , attr2));
            }
        }

        @Override
        void drawMe()
        {
            float maxDist = _radius*.5;
            for (Triangle face : _faceList)
            {
                PVector v1 = projectionMapping(face._v1);
                PVector v2 = projectionMapping(face._v2);
                PVector v3 = projectionMapping(face._v3);
                if ( PVector.sub(v1, v2).magSq() < sq(maxDist)
                  && PVector.sub(v2, v3).magSq() < sq(maxDist)
                  && PVector.sub(v3, v1).magSq() < sq(maxDist))
                {
                    new Triangle(v1, v2, v3, face.getAttribution()).drawMeAttr();
                }
            }
        }

        PVector projectionMapping(PVector v)
        {
            PVector v0 = new PVector(0, 0, -_radius);
            float k = v0.z/(v0.z-v.z);
            return new PVector(v0.x+k*(v.x-v0.x), v0.y+k*(v.y-v0.y), 0);
        }
    }
}