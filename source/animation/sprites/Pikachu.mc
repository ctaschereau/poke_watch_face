import Toybox.Graphics;
import Toybox.Lang;

module Pikachu {

    function draw(dc, px, py, look, tick) {
        var ox = look * 5;                    // head turns toward where it looks
        var white = Graphics.COLOR_WHITE;
        var black = Graphics.COLOR_BLACK;

        // tail (lightning bolt)
        Gfx.poly(dc, Gfx.shift([[18, 46], [44, 46], [36, 32], [56, 32], [40, 6], [30, 6], [38, 20], [22, 20]], px, py), white);

        // feet, body, arms
        Gfx.blob(dc, px - 12, py + 50, 9, 4);
        Gfx.blob(dc, px + 12, py + 50, 9, 4);
        Gfx.blob(dc, px, py + 30, 22, 20);
        Gfx.blob(dc, px - 22, py + 28, 5, 8);
        Gfx.blob(dc, px + 22, py + 28, 5, 8);

        // ears (black tips), drawn before head so the head overlaps their base
        Gfx.poly(dc, Gfx.shift([[-24, -16], [-30, -50], [-8, -26]], px + ox, py), white);
        Gfx.poly(dc, Gfx.shift([[24, -16], [30, -50], [8, -26]], px + ox, py), white);
        Gfx.poly(dc, Gfx.shift([[-30, -50], [-28, -41], [-24, -44]], px + ox, py), black);
        Gfx.poly(dc, Gfx.shift([[30, -50], [28, -41], [24, -44]], px + ox, py), black);

        // head
        Gfx.blob(dc, px + ox, py - 6, 28, 22);

        // eyes (blink on the last second)
        var ex = px + ox + look * 2;
        dc.setColor(black, Graphics.COLOR_TRANSPARENT);
        if (tick == 3) {
            dc.drawLine(ex - 15, py - 10, ex - 9, py - 10);
            dc.drawLine(ex + 9, py - 10, ex + 15, py - 10);
        } else {
            dc.fillCircle(ex - 12, py - 10, 3);
            dc.fillCircle(ex + 12, py - 10, 3);
            dc.setColor(white, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(ex - 11, py - 11, 1);
            dc.fillCircle(ex + 13, py - 11, 1);
        }

        // cheeks, nose, mouth
        dc.setColor(black, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(px + ox - 22, py, 5);
        dc.fillCircle(px + ox + 22, py, 5);
        dc.fillCircle(px + ox, py - 4, 1);
        dc.setPenWidth(1);
        dc.drawLine(px + ox - 5, py, px + ox - 2, py + 3);
        dc.drawLine(px + ox - 2, py + 3, px + ox, py);
        dc.drawLine(px + ox, py, px + ox + 2, py + 3);
        dc.drawLine(px + ox + 2, py + 3, px + ox + 5, py);
    }
}
