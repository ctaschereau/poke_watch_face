import Toybox.Graphics;
import Toybox.Lang;

module Jigglypuff {

    function draw(dc, px, py, look, tick) {
        var ox = look * 5;
        var white = Graphics.COLOR_WHITE;
        var black = Graphics.COLOR_BLACK;
        var blink = (tick == 3);
        var hx = px + ox / 2;                     // the whole puff leans a little

        // feet, arms
        Gfx.blob(dc, px - 14, py + 52, 8, 4);
        Gfx.blob(dc, px + 14, py + 52, 8, 4);
        Gfx.blob(dc, px - 34, py + 22, 6, 8);
        Gfx.blob(dc, px + 34, py + 22, 6, 8);

        // little pointy ears behind the balloon body
        Gfx.poly(dc, Gfx.shift([[-28, 0], [-34, -32], [-12, -14]], hx, py), white);
        Gfx.poly(dc, Gfx.shift([[28, 0], [34, -32], [12, -14]], hx, py), white);

        // round body
        Gfx.blob(dc, hx, py + 14, 34, 36);

        // curl on the forehead
        dc.setColor(black, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(hx, py - 25, 6, Graphics.ARC_COUNTER_CLOCKWISE, 90, 360);
        dc.drawArc(hx + 1, py - 25, 2, Graphics.ARC_COUNTER_CLOCKWISE, 0, 360);

        // huge eyes
        var ex = hx + look * 2;
        for (var s = -1; s <= 1; s += 2) {
            var cx = ex + s * 14;
            if (blink) {
                dc.setColor(black, Graphics.COLOR_TRANSPARENT);
                dc.drawLine(cx - 9, py + 6, cx + 9, py + 6);
            } else {
                dc.setColor(white, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(cx, py + 6, 10);
                dc.setColor(black, Graphics.COLOR_TRANSPARENT);
                dc.drawCircle(cx, py + 6, 10);
                dc.fillCircle(cx + look * 2, py + 7, 6);
                dc.setColor(white, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(cx + look * 2 - 2, py + 4, 2);
            }
        }

        // tiny mouth
        dc.setColor(black, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawArc(hx, py + 20, 6, Graphics.ARC_COUNTER_CLOCKWISE, 200, 340);
    }
}
