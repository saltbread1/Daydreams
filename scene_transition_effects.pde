abstract class TransitionEffect
{
    final float _totalEffectSec;
    float _curSec;

    TransitionEffect(float totalEffectSec)
    {
        _totalEffectSec = totalEffectSec;
    }

    abstract void applyEffect();

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
    void applyEffect()
    {
        pushStyle();
        noStroke();
        fill(_colour, getAlpha());
        rectMode(CENTER);
        rect(0, 0, width*4, height*4);
        popStyle();
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
    void applyEffect()
    {
        if (_threshFrame < _blinkFrame)
        {
            pushStyle();
            noStroke();
            fill(_colour);
            rectMode(CENTER);
            rect(0, 0, width*4, height*4);
            popStyle();
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
    void applyEffect()
    {

    }
}