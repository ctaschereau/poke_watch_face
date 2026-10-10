import Toybox.Graphics;
import Toybox.Lang;

// Gen 1 battle-scene HP-box edges: a horizontal line with a half-arrow, plus a vertical line at the other end.
module BattleFrame {

    const THICKNESS = 3;   // line thickness
    const ARROW_H = 4;     // height of the half-arrow above the line
    const ARROW_W = 13;    // width of the half-arrow at its base

    // left/right = ends of the horizontal line (right is exclusive), lineY = top of that line,
    // top = top of the vertical line.
    // arrowOnLeft = true : arrow at the left end, vertical line at the right end (player box).
    // arrowOnLeft = false: arrow at the right end, vertical line at the left end (foe box).
    // The arrow is a right triangle (flat side towards the vertical line) built from 1px-high rows.
    function drawEdge(dc as Dc, left as Number, right as Number, top as Number, lineY as Number,
                      arrowOnLeft as Boolean) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(left, lineY, right - left, THICKNESS);

        for (var i = 0; i < ARROW_H; i++) {
            var w = 3 + 2 * i;                 // rows widen towards the line
            var y = lineY - ARROW_H + i;
            if (arrowOnLeft) {
                dc.fillRectangle(left + ARROW_W - w, y, w, 1);
            } else {
                dc.fillRectangle(right - ARROW_W, y, w, 1);
            }
        }

        var verticalX = arrowOnLeft ? right - THICKNESS : left;
        dc.fillRectangle(verticalX, top, THICKNESS, lineY + THICKNESS - top);
    }
}
