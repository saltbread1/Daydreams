class Camera
{
    PVector _center2eye, _centerPos, _vibOffset;
    final TransitionEffect _beginEffect, _endEffect;
    float _vibRotRad, _vibCurSec;
    final TimeDisplayer _timeDisplayer;

    Camera(PVector center2eye, PVector centerPos, TransitionEffect beginEffect, TransitionEffect endEffect)
    {
        _center2eye = center2eye;
        _centerPos = centerPos;
        _vibOffset = new PVector();
        _beginEffect = beginEffect;
        _endEffect = endEffect;
        _vibRotRad = random(TAU);
        _timeDisplayer = new TimeDisplayer();
    }

    Camera(TransitionEffect beginEffect, TransitionEffect endEffect)
    { // default
        this(new PVector(0, 0, (height/2)/tan(PI/6)), new PVector(width/2, height/2), beginEffect, endEffect);
    }

    PVector getCenter() { return PVector.add(_centerPos, _vibOffset); }

    PVector getCenter2Eye() { return _center2eye; }

    void setCamera()
    {
        PVector c = PVector.add(_centerPos, _vibOffset);
        PVector eye = PVector.add(c, _center2eye);
        camera(eye.x, eye.y, eye.z, c.x, c.y, c.z, 0, 1, 0);
    }

    void addVibration(float vibPeriodSec, float vibScaleRadius, float vibRotMaxSpd)
    {
        float r = acos(cos(TAU*_vibCurSec/vibPeriodSec))/PI;
        _vibRotRad += vibRotMaxSpd * random(.36, 1);
        _vibOffset = PVector.fromAngle(_vibRotRad).mult(vibScaleRadius * r);
        _vibCurSec += 1./_frameRate;
    }

    void applyBeginTransitionEffect()
    {
        if (_beginEffect == null) { return; }
        _beginEffect.applyEffect(getCenter(), getCenter2Eye());
        _beginEffect.timeCount();
    }

    void applyEndTransitionEffect()
    {
        if (_endEffect == null) { return; }
        _endEffect.applyEffect(getCenter(), getCenter2Eye());
        _endEffect.timeCount();
    }

    float getBeginEffectTotalSecound()
    {
        if (_beginEffect == null) { return -1; }
        return _beginEffect.getTotalSecond();
    }

    float getEndEffectTotalSecound()
    {
        if (_endEffect == null) { return -1; }
        return _endEffect.getTotalSecond();
    }

    void displayTimeInfo() { _timeDisplayer.applyEffect(getCenter(), getCenter2Eye()); }

    class TimeDisplayer extends TransitionEffect
    {
        float _ms;

        TimeDisplayer()
        {
            super(-1);
            _ms = millis();
        }

        float getFPS()
        {
            float tmp = _ms;
            _ms = millis();
            return 1000./(_ms-tmp);
        }

        @Override
        Quad createBaseEffectQuad()
        {
            String message = "FPS: " + nf(getFPS(), 2, 1) + ", Second: " + nf((float)(frameCount - _scenes.length+2)/_frameRate, 2, 2);
            int textSize = (int)(width*.04);
            textSize(textSize);
            int messageSize = (int)textWidth(message);
            PGraphics pg;
            pg = createGraphics(messageSize, textSize, P2D);
            pg.beginDraw();
            pg.pushStyle();
            pg.textSize(textSize);
            pg.noStroke();
            pg.fill(#000000, 200);
            pg.rect(0, 0, messageSize, textSize);
            pg.textAlign(LEFT, TOP);
            pg.fill(#ffffff);
            pg.text(message, 0, 0);
            pg.popStyle();
            pg.endDraw();
            return new TextureQuad(
                    new PVector(-width/2, -height/2),
                    new PVector(-width/2, -height/2 + pg.height),
                    new PVector(-width/2 + pg.width, -height/2 + pg.height),
                    new PVector(-width/2 + pg.width, -height/2),
                    pg);
        }

        @Override
        void drawEffect(Quad displayer)
        {
            displayer.drawMeAttr();
        }
    }
}


class LandscapeCamera extends Camera
{
    PVector _startPos, _goalPos;
    float _preStepRad, _stepCurSec, _stepTotalSec, _stepEndSec;

    LandscapeCamera(PVector center2eye, PVector centerPos, TransitionEffect beginEffect, TransitionEffect endEffect)
    {
        super(center2eye, centerPos, beginEffect, endEffect);
        _preStepRad = random(TAU);
    }

    void setStepParameters(Rect limit, LandscapeType type)
    {
        PVector virtualGoalPos;
        float rad;
        int c = 0;

        _startPos = _centerPos.copy();
        do
        {
            float d = width + sqrt(random(1))*width*2.5;
            rad = ++c < 20 ? _preStepRad + random(-1,1)*PI*.4 : _preStepRad + random(-1,1)*PI*.8;
            PVector dir = PVector.fromAngle(rad);
            _stepTotalSec = type == LandscapeType.PHASE1 ? d*.0015 : d*.0006;
            _stepEndSec = _stepTotalSec * sq(random(.28, .82));
            _goalPos = PVector.add(_startPos, dir.mult(d));
            float r = _util.easeOutQuad(_stepEndSec/_stepTotalSec);
            virtualGoalPos = PVector.mult(_startPos, 1-r).add(PVector.mult(_goalPos, r));
        }
        while (!isInIimitRange(virtualGoalPos, limit));
        
        _preStepRad = rad;
        _stepCurSec = 0;
    }

    void update(Rect limit, LandscapeType type)
    {
        if (_stepCurSec >= _stepEndSec) { setStepParameters(limit, type); }
        float r = _util.easeOutQuad(_stepCurSec/_stepTotalSec);
        _centerPos = PVector.mult(_startPos, 1-r).add(PVector.mult(_goalPos, r));
        _stepCurSec += 1./_frameRate;
    }

    boolean isInIimitRange(PVector pos, Rect limit)
    {
        PVector ul = limit._upperLeft;
        PVector lr = limit._lowerRight;
        if (pos.x > ul.x && pos.x < lr.x && pos.y > ul.y && pos.y < lr.y)
        {
            return true;
        }
        return false;
    }
}

class ExploringCamera extends Camera
{
    ExploringCamera(PVector center2eye, PVector centerPos, TransitionEffect beginEffect, TransitionEffect endEffect)
    {
        super(center2eye, centerPos, beginEffect, endEffect);
    }

    void update(PVector pos) { _centerPos = pos; }
}