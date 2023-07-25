abstract class TransitionEffect
{
    final float _totalEffectSec;
    float _curSec;

    TransitionEffect(float totalEffectSec)
    {
        _totalEffectSec = totalEffectSec;
    }

    final void applyEffect(PVector cameraCenter, PVector cameraCenter2Eye)
    {
        Quad effectQuad = createBaseEffectQuad();
        PVector ez = new PVector(0, 0, 1);
        PVector axis = ez.cross(cameraCenter2Eye);
        float rad = PVector.angleBetween(ez, cameraCenter2Eye);
        effectQuad.rotate(axis, rad, effectQuad.getCenter());
        effectQuad.translate(cameraCenter);
        hint(DISABLE_DEPTH_TEST);
        drawEffect(effectQuad);
        hint(ENABLE_DEPTH_TEST);
    }

    abstract Quad createBaseEffectQuad();

    abstract void drawEffect(Quad effectQuad);

    final void timeCount() { _curSec += 1./_frameRate; }

    final float getTotalSecond() { return _totalEffectSec; }
}

abstract class TransitionFade extends TransitionEffect
{
    final color _colour;

    TransitionFade(float totalEffectSec, color colour)
    {
        super(totalEffectSec);
        _colour = colour;
    }

    @Override
    Quad createBaseEffectQuad()
    {
        return new Quad(
                new PVector(-width*8, -height*8),
                new PVector(-width*8,  height*8),
                new PVector( width*8,  height*8),
                new PVector( width*8, -height*8));
    }

    @Override
    void drawEffect(Quad effectQuad)
    {
        effectQuad.setAttribution(new Attribution(color(_colour, getAlpha()), DrawStyle.FILLONLY));
        effectQuad.drawMeAttr();
    }

    abstract int getAlpha();
}

class TransitionFadeIn extends TransitionFade
{
    TransitionFadeIn(float totalEffectSec, color colour)
    {
        super(totalEffectSec, colour);
    }

    @Override
    int getAlpha()
    {
        float r = constrain(_curSec/_totalEffectSec, 0, 1);
        return (int)(r*255);
    }
}

class TransitionFadeOut extends TransitionFade
{
    TransitionFadeOut(float totalEffectSec, color colour)
    {
        super(totalEffectSec, colour);
    }

    @Override
    int getAlpha()
    {
        float r = constrain(1-_curSec/_totalEffectSec, 0, 1);
        return (int)(r*255);
    }
}

class TransitionBlink extends TransitionEffect
{
    final int _blinkFrame;
    final color _colour;
    int _threshFrame;

    TransitionBlink(float totalEffectSec, int blinkFrame, color colour)
    {
        super(totalEffectSec);
        _blinkFrame = blinkFrame;
        _colour = colour;
    }

    @Override
    Quad createBaseEffectQuad()
    {
        return new Quad(
                new PVector(-width*8, -height*8),
                new PVector(-width*8,  height*8),
                new PVector( width*8,  height*8),
                new PVector( width*8, -height*8));
    }

    @Override
    void drawEffect(Quad effectQuad)
    {
        if (_threshFrame < _blinkFrame)
        {
            effectQuad.setAttribution(new Attribution(_colour, DrawStyle.FILLONLY));
            effectQuad.drawMeAttr();
        }
        _threshFrame = (_threshFrame+1)%(_blinkFrame*2);
    }
}

class TransitionRecursive extends TransitionEffect
{
    final int _maxiterations;
    final float _recursiveScale;
    int _recursiveNum;
    float _iterateSec;
    final PShader _glitch;

    TransitionRecursive(float totalEffectSec, int maxiterations, float scale)
    {
        super(totalEffectSec);
        _maxiterations = maxiterations;
        _recursiveScale = scale;
        _recursiveNum = 1;
        _glitch = _dm.getGlitchShader();
        _glitch.set("resolution", (float)width, (float)height);
    }

    @Override
    Quad createBaseEffectQuad()
    {
        PImage img = get(0, 0, width, height);
        PGraphics pg = createGraphics(width, height, P2D);
        pg.beginDraw();
        pg.pushStyle();
        pg.imageMode(CENTER);
        float scale = 1;
        for (int i = 0; i <= _recursiveNum; i++)
        {
            pg.image(img, width/2, height/2, (int)(width*scale), (int)(height*scale));
            scale *= _recursiveScale;
        }
        pg.popStyle();
        pg.filter(_glitch);
        pg.endDraw();
        return new TextureQuad(
                new PVector(-width/2, -height/2),
                new PVector(-width/2,  height/2),
                new PVector( width/2,  height/2),
                new PVector( width/2, -height/2),
                pg);
    }

    @Override
    void drawEffect(Quad effectQuad)
    {
        _glitch.set("time", _curSec*16);

        if (_iterateSec > _totalEffectSec / _maxiterations)
        {
            _recursiveNum++;
            _iterateSec = 0;
        }
        effectQuad.drawMeAttr();
        _iterateSec += 1./_frameRate;
    }
}

class TransitionDivision extends TransitionEffect
{
    final int _maxiterations;
    int _divisionDepth;
    float _iterateSec;
    final PShader _glitch;

    TransitionDivision(float totalEffectSec, int maxiterations)
    {
        super(totalEffectSec);
        _maxiterations = maxiterations;
        _divisionDepth = 1;
        _glitch = _dm.getGlitchShader();
        _glitch.set("resolution", (float)width, (float)height);
    }

    @Override
    Quad createBaseEffectQuad()
    {
        PImage img = get(0, 0, width, height);
        PGraphics pg = createGraphics(width, height, P2D);
        pg.beginDraw();
        pg.background(#000000);
        pg.pushStyle();
        drawDivisionImage(pg, img, 0, 0, width, height, 0);
        pg.popStyle();
        pg.filter(_glitch);
        pg.endDraw();
        return new TextureQuad(
                new PVector(-width/2, -height/2),
                new PVector(-width/2,  height/2),
                new PVector( width/2,  height/2),
                new PVector( width/2, -height/2),
                pg);
    }

    void drawDivisionImage(PGraphics pg, PImage img, int x, int y, int w, int h, int depth)
    {
        if (depth >= _divisionDepth)
        {
            pg.image(img, x, y, w, h); 
            return;
        }
        drawDivisionImage(pg, img, x, y, w/2, h/2, depth+1);
        drawDivisionImage(pg, img, x+w/2, y, w/2, h/2, depth+1);
        drawDivisionImage(pg, img, x, y+h/2, w/2, h/2, depth+1);
        drawDivisionImage(pg, img, x+w/2, y+h/2, w/2, h/2, depth+1);
    }

    @Override
    void drawEffect(Quad effectQuad)
    {
        _glitch.set("time", _curSec*16);

        if (_iterateSec > _totalEffectSec / _maxiterations)
        {
            _divisionDepth++;
            _iterateSec = 0;
        }
        effectQuad.drawMeAttr();
        _iterateSec += 1./_frameRate;
    }
}

class TransitionSlide extends TransitionEffect
{
    final color _colour;

    TransitionSlide(float totalEffectSec, color colour)
    {
        super(totalEffectSec);
        _colour = colour;
    }

    @Override
    Quad createBaseEffectQuad()
    {
        float r = constrain(_curSec/_totalEffectSec, 0, 1);
        return new Quad(
                new PVector(-width/2, -height/2),
                new PVector(-width/2,  height/2),
                new PVector(-width/2 + width * r,  height/2),
                new PVector(-width/2 + width * r, -height/2));
    }

    @Override
    void drawEffect(Quad effectQuad)
    {
        effectQuad.setAttribution(new Attribution(_colour, DrawStyle.FILLONLY));
        effectQuad.drawMeAttr();
    }
}