import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

// The Poke Ball drawn in the subscreen (closed, or lid swung open).
module PokeBall {

    // box = [x, y, w, h] of the subscreen
    function draw(dc, box, closed) {
        var cx = box[0] + box[2] / 2;
        var cy = box[1] + box[3] / 2;
        var r = ((box[2] < box[3]) ? box[2] : box[3]) / 2 - 7;
        var black = Graphics.COLOR_BLACK;
        var white = Graphics.COLOR_WHITE;

        dc.setPenWidth(2);

        if (closed) {
            dc.setColor(black, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(cx, cy, r);                                  // whole ball black
            dc.setColor(white, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(cx - r - 1, cy + 2, 2 * r + 3, r + 2);    // bottom half white
            dc.setColor(black, Graphics.COLOR_TRANSPARENT);
            dc.drawCircle(cx, cy, r);                                  // outline
            dc.fillRectangle(cx - r, cy - 1, 2 * r + 1, 3);            // centre band
            dc.fillCircle(cx, cy, r / 3 + 2);                          // button
            dc.setColor(white, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(cx, cy, r / 3 - 1);
            dc.drawArc(cx, cy, r - 5, Graphics.ARC_COUNTER_CLOCKWISE, 120, 160); // shine
        } else {
            // bottom half stays put
            dc.setColor(black, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(cx, cy, r, Graphics.ARC_COUNTER_CLOCKWISE, 180, 360);
            dc.drawLine(cx - r, cy, cx + r, cy);

            // lid: black half-disc hinged on the right, swung open 30 degrees
            var hx = cx + r;
            var hy = cy;
            var ang = 30.0 * Math.PI / 180.0;
            var cs = Math.cos(ang);
            var sn = Math.sin(ang);
            var pts = [];
            for (var a = 180; a <= 360; a += 15) {
                var rad = a * Math.PI / 180.0;
                var dx = cx + r * Math.cos(rad) - hx;
                var dy = r * Math.sin(rad);
                pts.add([(hx + dx * cs - dy * sn).toNumber(),
                         (hy + dx * sn + dy * cs).toNumber()]);
            }
            dc.fillPolygon(pts);
        }
        dc.setPenWidth(1);
    }
}
