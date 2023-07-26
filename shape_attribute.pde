enum DrawStyle
{
    STROKEONLY,
    FILLONLY,
    STROKEANDFILL,
}

class Attribute
{
    final color _cStroke, _cFill;
    final DrawStyle _style;

    Attribute(color cStroke, color cFill, DrawStyle style)
    {
        _cStroke = cStroke;
        _cFill = cFill;
        _style = style;
    }

    Attribute(color cStroke, color cFill)
    {
        this(cStroke, cFill, DrawStyle.STROKEANDFILL);
    }

    Attribute(color colour, DrawStyle style)
    {
        this(colour, colour, style);
    }

    Attribute()
    { // default colors
        _cStroke = #000000;
        _cFill = #ffffff;
        _style = null;
    }

    color getStroke() { return _cStroke; }

    color getFill() { return _cFill; }

    DrawStyle getStyle() { return _style; }

    void apply()
    {
        if (_style == null) { return; }

        switch (_style)
        {
            case STROKEONLY:
                stroke(_cStroke);
                noFill();
                break;
            case FILLONLY:
                noStroke();
                fill(_cFill);
                break;
            case STROKEANDFILL:
                stroke(_cStroke);
                fill(_cFill);
                break;
        }
    }

    void apply(PGraphics pg)
    {
        if (_style == null) { return; }

        switch (_style)
        {
            case STROKEONLY:
                pg.stroke(_cStroke);
                pg.noFill();
                break;
            case FILLONLY:
                pg.noStroke();
                pg.fill(_cFill);
                break;
            case STROKEANDFILL:
                pg.stroke(_cStroke);
                pg.fill(_cFill);
                break;
        }
    }

    @Override
    boolean equals(Object o)
    {
        if (o == null || !(o instanceof Attribute)) { return false; }
        Attribute other = (Attribute)o;
        if (_cStroke == other._cStroke && _cFill == other._cFill && _style == other._style)
        {
            return true;
        }
        return false;
    }
}

class AttributeDetail extends Attribute
{
    final float _strokeW;
    final int _capType; // stroke cap: ROUND, SQUARE, PROJECT

    AttributeDetail(color cStroke, color cFill, DrawStyle style, float strokeW, int capType)
    {
        super(cStroke, cFill, style);
        _strokeW = strokeW;
        _capType = capType;
    }

    AttributeDetail(color cStroke, color cFill, float strokeW, int capType)
    {
        this(cStroke, cFill, DrawStyle.STROKEANDFILL, strokeW, capType);
    }

    AttributeDetail(color colour, DrawStyle style, float strokeW, int capType)
    {
        this(colour, colour, style, strokeW, capType);
    }

    AttributeDetail()
    {
        _strokeW = 1;
        _capType = ROUND;
    }

    void apply()
    {
        super.apply();
        strokeWeight(_strokeW);
        strokeCap(_capType);
    }

    void apply(PGraphics pg)
    {
        super.apply(pg);
        pg.strokeWeight(_strokeW);
        pg.strokeCap(_capType);
    }
}