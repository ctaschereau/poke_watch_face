import Toybox.Graphics;
import Toybox.Lang;

// Small drawing helpers shared by the ball and all Pokemon sprites.
module Gfx {

    function shift(pts, dx, dy) {
        var out = [];
        for (var i = 0; i < pts.size(); i++) {
            out.add([pts[i][0] + dx, pts[i][1] + dy]);
        }
        return out;
    }

    // filled polygon with a black outline
    function poly(dc, pts, fill) {
        dc.setColor(fill, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(pts);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        var n = pts.size();
        for (var i = 0; i < n; i++) {
            var a = pts[i];
            var c = pts[(i + 1) % n];
            dc.drawLine(a[0], a[1], c[0], c[1]);
        }
    }

    // white ellipse with a black outline
    function blob(dc, x, y, rx, ry) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.fillEllipse(x, y, rx, ry);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawEllipse(x, y, rx, ry);
    }

    // black round eye with a white highlight; a short line when blinking
    function eye(dc, x, y, r, blink) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        if (blink) {
            dc.drawLine(x - r, y, x + r, y);
        } else {
            dc.fillCircle(x, y, r);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(x + 1, y - 1, (r > 3) ? 2 : 1);
        }
    }
}
