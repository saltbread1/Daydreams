abstract class Scene
{
    final PApplet _papplet;
    final TransitionEffect _beginEffect, _endEffect;
    final float _totalSceneSec;
    float _curSec;

    Scene(PApplet papplet, TransitionEffect beginEffect, TransitionEffect endEffect, float totalSceneSec)
    {
        _papplet = papplet;
        _beginEffect = beginEffect;
        _endEffect = endEffect;
        _totalSceneSec = totalSceneSec;
    }

    Scene(TransitionEffect beginEffect, TransitionEffect endEffect, float totalSceneSec)
    {
        this(null, beginEffect, endEffect, totalSceneSec);
    }

    Scene(PApplet papplet, float totalSceneSec)
    {
        this(papplet, null, null, totalSceneSec);
    }

    Scene(float totalSceneSec)
    {
        this(null, null, null, totalSceneSec);
    }
    
    abstract void initialize();

    void start() {}

    abstract void update();

    void timeCount() { _curSec += 1./_frameRate; }

    boolean isEnd() { return _curSec > _totalSceneSec; }

    void postProcessing() { println("End \""+this.getClass().getSimpleName()+"\"."); }

    void clearScene() { background(#000000); }

    float getCurrentSecond() { return _curSec; }

    float getTotalSecond() { return _totalSceneSec; }

    void applyBeginTransitionEffect()
    {
        if (_beginEffect == null) { return; }
        hint(DISABLE_DEPTH_TEST);
        _beginEffect.applyEffect();
        hint(ENABLE_DEPTH_TEST);
        _beginEffect.timeCount();
    }
    
    void applyEndTransitionEffect()
    {
        if (_endEffect == null) { return; }
        hint(DISABLE_DEPTH_TEST);
        _endEffect.applyEffect();
        hint(ENABLE_DEPTH_TEST);
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
}

class SceneManager
{
    ArrayDeque<Scene> _sceneQueue;
    Scene _curScene;

    SceneManager() { _sceneQueue = new ArrayDeque<Scene>(); }

    void addScene(Scene scene)
    {
        float t = millis();
        scene.initialize();
        println("Initialization of \""+scene.getClass().getSimpleName()+"\": "+(millis()-t)+" ms.");
        _sceneQueue.add(scene);
    }

    void advanceOneFrame()
    {
        if (_curScene == null) { _curScene = _sceneQueue.poll(); }

        _curScene.clearScene();
        if (_curScene.getCurrentSecond() == 0)
        {
            float t = millis();
            _curScene.start();
            println("Start of \""+_curScene.getClass().getSimpleName()+"\": "+(millis()-t)+" ms.");
        }
        _curScene.update();
        if (_curScene.getCurrentSecond() < _curScene.getBeginEffectTotalSecound())
        {
            _curScene.applyBeginTransitionEffect();
        }
        if (_curScene.getCurrentSecond() > _curScene.getTotalSecond() - _curScene.getEndEffectTotalSecound())
        {
            _curScene.applyEndTransitionEffect();
        }
        _curScene.timeCount();
        if (_curScene.isEnd())
        {
            _curScene.postProcessing();
            if (isFinish())
            {
                postProcessing();
                return;
            }
            _curScene = _sceneQueue.poll();
        }
    }

    boolean isFinish() { return _sceneQueue.size() == 0; }

    void postProcessing()
    {
        println("The movie has just finished.");
        noLoop();
    }
}

abstract class Camera
{
    final PVector _center2eye;
    PVector _centerPos, _vibOffset;
    float _vibRotRad, _vibCurSec;

    Camera(PVector center2eye, PVector centerPos)
    {
        _center2eye = center2eye;
        _centerPos = centerPos;
        _vibOffset = new PVector();
        _vibRotRad = random(TAU);
    }

    Camera(PVector center2eye)
    {
        this(center2eye, new PVector());
    }

    abstract void update();

    void updateCamera()
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

    PVector getCenter() { return PVector.add(_centerPos, _vibOffset); }

    PVector getCenter2Eye() { return _center2eye; }
}

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
        rect(0, 0, width*10, height*10);
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
            rect(0, 0, width*10, height*10);
            popStyle();
        }
        _threshFrame = (_threshFrame+1)%(_blinkFrame*2);
    }
}