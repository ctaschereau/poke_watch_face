import Toybox.Graphics;
import Toybox.Lang;

module Charmander {

    function draw(dc, px, py, look, tick) {
        var ox = look * 5;
        var white = Graphics.COLOR_WHITE;
        var black = Graphics.COLOR_BLACK;
        var blink = (tick == 3);

        // tail curling up on the right, ending in a flame
        Gfx.blob(dc, px + 26, py + 46, 10, 6);
        Gfx.blob(dc, px + 37, py + 40, 8, 6);
        Gfx.blob(dc, px + 43, py + 30, 6, 7);
        Gfx.poly(dc, Gfx.shift([[0, -18], [7, -8], [12, -12], [13, 2], [6, 10], [-6, 10], [-12, 2], [-8, -10], [-3, -6]], px + 46, py + 14), white);
        Gfx.poly(dc, Gfx.shift([[0, -6], [4, 0], [2, 6], [-2, 6], [-4, 0]], px + 46, py + 14), black);

        // feet, body, arms
        Gfx.blob(dc, px - 12, py + 50, 9, 4);
        Gfx.blob(dc, px + 12, py + 50, 9, 4);
        Gfx.blob(dc, px, py + 30, 20, 20);
        Gfx.blob(dc, px, py + 34, 12, 14);                 // belly
        dc.setPenWidth(1);
        dc.drawLine(px - 9, py + 28, px + 9, py + 28);
        dc.drawLine(px - 10, py + 34, px + 10, py + 34);
        dc.drawLine(px - 9, py + 40, px + 9, py + 40);
        dc.setPenWidth(2);
        Gfx.blob(dc, px - 22, py + 28, 5, 8);
        Gfx.blob(dc, px + 22, py + 28, 5, 8);

        // head
        Gfx.blob(dc, px + ox, py - 6, 26, 22);
        var ex = px + ox + look * 2;
        Gfx.eye(dc, ex - 12, py - 10, 4, blink);
        Gfx.eye(dc, ex + 12, py - 10, 4, blink);

        // nostrils + smile
        dc.setColor(black, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(px + ox - 3, py - 1, 1);
        dc.fillCircle(px + ox + 3, py - 1, 1);
        dc.setPenWidth(1);
        dc.drawArc(px + ox, py + 2, 9, Graphics.ARC_COUNTER_CLOCKWISE, 200, 340);
    }
}
