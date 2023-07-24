abstract class TransitionEffect
{
    final float _totalEffectSec;
    float _curSec;

    TransitionEffect(float totalEffectSec)
    {
        _totalEffectSec = totalEffectSec;
    }

    void applyEffect(PVector cameraCenter, PVector cameraCenter2Eye)
    {
        Quad effectQuad = new Quad(
                new PVector(-width, -height),
                new PVector(-width, height),
                new PVector(width, height),
                new PVector(width, -height));
        PVector ez = new PVector(0, 0, 1);
        PVector axis = ez.cross(cameraCenter2Eye);
        float rad = PVector.angleBetween(ez, cameraCenter2Eye);
        effectQuad.rotate(axis, rad, effectQuad.getCenter());
        effectQuad.translate(cameraCenter);
        hint(DISABLE_DEPTH_TEST);
        drawEffect(effectQuad);
        hint(ENABLE_DEPTH_TEST);
    }

    abstract void drawEffect(Quad effectQuad);

    void timeCount() { _curSec += 1./_frameRate; }

    float getTotalSecond() { return _totalEffectSec; }
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

class TransitionDivision extends TransitionEffect
{
    TransitionDivision(float totalEffectSec)
    {
        super(totalEffectSec);
    }

    @Override
    void drawEffect(Quad effectQuad)
    {

    }
}