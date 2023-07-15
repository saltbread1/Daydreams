class TestHUD
{ // for test
    float _ms;

    int getFPS()
    {
        float tmp = _ms;
        _ms = millis();
        return (int)(1000./(_ms-tmp));
    }

    // PGraphics createHUD()
    // {
    //     String message = "FPS: " + getFPS();
    //     int textSize = 24;
    //     textSize(textSize);
    //     int messageSize = (int)textWidth(message);
    //     PGraphics pg;
    //     pg = createGraphics(messageSize, textSize, P2D);
    //     pg.beginDraw();
    //     pg.pushStyle();
    //     pg.textSize(textSize);
    //     pg.noStroke();
    //     pg.fill(#e0e0e0, 120);
    //     pg.rect(0, 0, messageSize, textSize);
    //     pg.textAlign(LEFT, TOP);
    //     pg.text(message, 0, 0);
    //     pg.popStyle();
    //     pg.endDraw();
    //     return pg;
    // }

    // void display()
    // {
    //     image(createHUD(), 0, 0);
    // }
}