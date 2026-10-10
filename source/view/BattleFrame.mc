import Toybox.Graphics;
import Toybox.Lang;

// Gen 1 battle-scene HP-box edges: a horizontal line with a stepped half-arrow, plus a vertical line at the other end.
// Everything is on the face's 2 px pixel grid (the same grid as the 2x pixel font): 2 px lines, 2 px-high arrow rows.
module BattleFrame {

    const THICKNESS = 2;   // line thickness (1 game pixel at 2x)
    const ARROW_H = 4;     // height of the half-arrow above the line (2 rows of 2 px)
    const ARROW_W = 12;    // width of the half-arrow at its base (rows are 6 and 12 px wide)

    // left/right = ends of the horizontal line (right is exclusive), lineY = top of that line,
    // top = top of the vertical line.
    // arrowOnLeft = true : arrow at the left end, vertical line at the right end (player box).
    // arrowOnLeft = false: arrow at the right end, vertical line at the left end (foe box).
    // The arrow is a right triangle (flat side towards the vertical line) built from two 2 px-high rows.
    function drawEdge(dc as Dc, left as Number, right as Number, top as Number, lineY as Number,
                      arrowOnLeft as Boolean) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(left, lineY, right - left, THICKNESS);

        for (var i = 0; i < 2; i++) {
            var w = 6 * (i + 1);               // rows widen towards the line: 6, 12
            var y = lineY - ARROW_H + 2 * i;
            if (arrowOnLeft) {
                dc.fillRectangle(left + ARROW_W - w, y, w, 2);
            } else {
                dc.fillRectangle(right - ARROW_W, y, w, 2);
            }
        }

        var verticalX = arrowOnLeft ? right - THICKNESS : left;
        dc.fillRectangle(verticalX, top, THICKNESS, lineY + THICKNESS - top);
    }
}
