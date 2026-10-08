import Toybox.Graphics;
import Toybox.Lang;

module Eevee {

    function draw(dc, px, py, look, tick) {
        var ox = look * 5;
        var white = Graphics.COLOR_WHITE;
        var black = Graphics.COLOR_BLACK;
        var blink = (tick == 3);

        // bushy tail with a tuft on top
        Gfx.blob(dc, px + 28, py + 44, 12, 7);
        Gfx.blob(dc, px + 38, py + 36, 10, 9);
        Gfx.poly(dc, Gfx.shift([[-8, 12], [-10, -2], [-4, -6], [-4, -16], [4, -8], [10, -14], [12, 2], [8, 12]], px + 42, py + 22), white);

        // paws, body
        Gfx.blob(dc, px - 10, py + 50, 7, 4);
        Gfx.blob(dc, px + 10, py + 50, 7, 4);
        Gfx.blob(dc, px, py + 32, 20, 18);

        // fluffy neck ruff
        Gfx.poly(dc, Gfx.shift([[-27, 0], [-26, 12], [-20, 10], [-15, 22], [-8, 14], [0, 24], [8, 14], [15, 22], [20, 10], [26, 12], [27, 0]], px, py + 4), white);

        // tall ears with dark insides, behind the head
        Gfx.poly(dc, Gfx.shift([[-24, -12], [-34, -52], [-8, -24]], px + ox, py), white);
        Gfx.poly(dc, Gfx.shift([[24, -12], [34, -52], [8, -24]], px + ox, py), white);
        Gfx.poly(dc, Gfx.shift([[-24, -26], [-29, -42], [-17, -30]], px + ox, py), black);
        Gfx.poly(dc, Gfx.shift([[24, -26], [29, -42], [17, -30]], px + ox, py), black);

        // head with cheek fluff
        Gfx.blob(dc, px + ox, py - 6, 26, 20);
        Gfx.poly(dc, Gfx.shift([[-26, -4], [-33, 1], [-24, 6]], px + ox, py), white);
        Gfx.poly(dc, Gfx.shift([[26, -4], [33, 1], [24, 6]], px + ox, py), white);

        // big eyes, nose, mouth
        var ex = px + ox + look * 2;
        Gfx.eye(dc, ex - 11, py - 8, 4, blink);
        Gfx.eye(dc, ex + 11, py - 8, 4, blink);
        dc.setColor(black, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(px + ox, py - 1, 2);
        dc.setPenWidth(1);
        dc.drawLine(px + ox - 5, py + 3, px + ox - 2, py + 6);
        dc.drawLine(px + ox - 2, py + 6, px + ox, py + 3);
        dc.drawLine(px + ox, py + 3, px + ox + 2, py + 6);
        dc.drawLine(px + ox + 2, py + 6, px + ox + 5, py + 3);
    }
}
