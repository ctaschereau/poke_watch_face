import Toybox.Graphics;
import Toybox.Lang;

module Squirtle {

    function draw(dc, px, py, look, tick) {
        var ox = look * 5;
        var white = Graphics.COLOR_WHITE;
        var black = Graphics.COLOR_BLACK;
        var blink = (tick == 3);

        // curly tail on the right
        dc.setColor(black, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(4);
        dc.drawArc(px + 30, py + 36, 9, Graphics.ARC_COUNTER_CLOCKWISE, 90, 340);
        dc.setPenWidth(2);

        // feet, dark shell, light belly with plates
        Gfx.blob(dc, px - 12, py + 50, 9, 4);
        Gfx.blob(dc, px + 12, py + 50, 9, 4);
        dc.setColor(black, Graphics.COLOR_TRANSPARENT);
        dc.fillEllipse(px, py + 30, 26, 22);                 // shell
        Gfx.blob(dc, px, py + 32, 17, 18);                   // belly
        dc.setPenWidth(1);
        dc.drawLine(px - 14, py + 26, px + 14, py + 26);
        dc.drawLine(px - 16, py + 32, px + 16, py + 32);
        dc.drawLine(px - 14, py + 38, px + 14, py + 38);
        dc.drawLine(px, py + 20, px, py + 44);
        dc.setPenWidth(2);

        // arms
        Gfx.blob(dc, px - 24, py + 26, 5, 8);
        Gfx.blob(dc, px + 24, py + 26, 5, 8);

        // round head
        Gfx.blob(dc, px + ox, py - 6, 24, 22);
        var ex = px + ox + look * 2;
        Gfx.eye(dc, ex - 11, py - 8, 4, blink);
        Gfx.eye(dc, ex + 11, py - 8, 4, blink);

        // tiny nostrils + smile
        dc.setColor(black, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(px + ox - 2, py - 1, 1);
        dc.fillCircle(px + ox + 2, py - 1, 1);
        dc.setPenWidth(1);
        dc.drawArc(px + ox, py + 1, 10, Graphics.ARC_COUNTER_CLOCKWISE, 205, 335);
    }
}
