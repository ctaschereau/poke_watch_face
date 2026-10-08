import Toybox.Graphics;
import Toybox.Lang;

module Bulbasaur {

    function draw(dc, px, py, look, tick) {
        var ox = look * 5;
        var white = Graphics.COLOR_WHITE;
        var black = Graphics.COLOR_BLACK;
        var blink = (tick == 3);
        var bx = px + ox / 2;

        // bulb peeking up behind the head, with its sprout
        Gfx.blob(dc, bx, py - 34, 22, 20);
        Gfx.poly(dc, Gfx.shift([[-5, -52], [0, -62], [5, -52]], bx, py), black);
        dc.setPenWidth(1);
        dc.drawLine(bx - 8, py - 51, bx - 12, py - 40);
        dc.drawLine(bx + 8, py - 51, bx + 12, py - 40);
        dc.drawLine(bx, py - 50, bx, py - 38);
        dc.setPenWidth(2);

        // four stubby legs, then the wide body
        Gfx.blob(dc, px - 20, py + 50, 8, 5);
        Gfx.blob(dc, px + 20, py + 50, 8, 5);
        Gfx.blob(dc, px - 8, py + 51, 7, 4);
        Gfx.blob(dc, px + 8, py + 51, 7, 4);
        Gfx.blob(dc, px, py + 32, 30, 18);

        // dark spots on the back
        dc.setColor(black, Graphics.COLOR_TRANSPARENT);
        dc.fillEllipse(px - 15, py + 28, 4, 3);
        dc.fillEllipse(px + 13, py + 37, 5, 3);
        dc.fillEllipse(px + 3, py + 25, 3, 2);

        // pointy ears, then the head
        Gfx.poly(dc, Gfx.shift([[-22, -14], [-32, -30], [-10, -20]], px + ox, py), white);
        Gfx.poly(dc, Gfx.shift([[22, -14], [32, -30], [10, -20]], px + ox, py), white);
        Gfx.blob(dc, px + ox, py - 4, 26, 20);

        // big eyes, nostrils, wide mouth
        var ex = px + ox + look * 2;
        Gfx.eye(dc, ex - 12, py - 6, 4, blink);
        Gfx.eye(dc, ex + 12, py - 6, 4, blink);
        dc.setColor(black, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(px + ox - 2, py - 1, 1);
        dc.fillCircle(px + ox + 2, py - 1, 1);
        dc.setPenWidth(1);
        dc.drawLine(px + ox - 9, py + 6, px + ox + 9, py + 6);
        dc.drawLine(px + ox - 9, py + 6, px + ox - 11, py + 3);
        dc.drawLine(px + ox + 9, py + 6, px + ox + 11, py + 3);
    }
}
