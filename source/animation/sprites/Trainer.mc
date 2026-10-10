import Toybox.Graphics;
import Toybox.Lang;

// The Pokemon trainer, 32x32 on screen: the original 16x16 monochrome sprites drawn at 2x (nearest neighbour,
// so every sprite pixel becomes a 2x2 block). Each sprite is 16 row masks; bit 15 = leftmost pixel,
// a set bit = black pixel (white / transparent pixels are simply not drawn, the face background is white).
// Walking while the watch is awake (the two walk frames alternate each second),
// fishing while it sleeps: the fishing sprite is the trainer holding a fist forward, and the rod itself
// (a long diagonal pole, the line and a bobber) is drawn on top with lines, because it is wider and taller than
// the 16x16 sprite. The rod leans up and to the left, just clear of the clock digits.
module Trainer {

    const SIZE = 32;          // size on screen
    const SPRITE = 16;        // size of the sprite data below
    const SCALE = 2;          // SIZE / SPRITE
    const RIGHT_BLANK = 4;    // empty pixels at the right of the 32x32 box (sprite columns 14-15 are never used)

    // fishing rod, in screen pixels relative to the top-left of the 32x32 box
    const ROD_GRIP_X = 4;     // where the fist holds the rod
    const ROD_GRIP_Y = 17;
    const ROD_TIP_X = -9;     // the rod tip (left of the box, above it: clear of the clock digits)
    const ROD_TIP_Y = -16;
    const LINE_DROP = 15;     // the line hangs this far below the tip, ending in the bobber
    const BOBBER_R = 3;

    // walk frame 1
    const WALK_A as Array<Number> = [
        0x07E0,
        0x0D50,
        0x1AA8,
        0x3558,
        0x42BC,
        0x35FC,
        0x14FC,
        0x1498,
        0x1010,
        0x0C78,
        0x07E8,
        0x0338,
        0x0328,
        0x05F0,
        0x06A0,
        0x03C0
    ];

    // walk frame 2
    const WALK_B as Array<Number> = [
        0x0000,
        0x07E0,
        0x0AB0,
        0x1558,
        0x32A8,
        0x415C,
        0x3BFC,
        0x14FC,
        0x1498,
        0x1010,
        0x0868,
        0x07F8,
        0x1F98,
        0x3594,
        0x1BEC,
        0x0E18
    ];

    // fishing (watch asleep)
    const FISH as Array<Number> = [
        0x07E0,
        0x0D50,
        0x1AA8,
        0x3558,
        0x42BC,
        0x35FC,
        0x14FC,
        0x1498,
        0x7010,
        0x7C60,
        0x3FB0,
        0x2570,
        0x27F0,
        0x1F70,
        0x06A0,
        0x03C0
    ];

    // x,y = top-left corner. asleep -> fishing sprite; otherwise walk frame chosen by `tick` (even/odd).
    function draw(dc as Dc, x as Number, y as Number, asleep as Boolean, tick as Number) as Void {
        var sprite = FISH;
        if (!asleep) {
            sprite = (tick % 2 == 0) ? WALK_A : WALK_B;
        }
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        if (asleep) {
            drawRod(dc, x, y);
        }
        for (var row = 0; row < SPRITE; row++) {
            var bits = sprite[row];
            var col = 0;
            while (col < SPRITE) {
                if ((bits & (0x8000 >> col)) != 0) {
                    var start = col;                       // horizontal run of black pixels -> one rectangle
                    while (col < SPRITE && (bits & (0x8000 >> col)) != 0) {
                        col++;
                    }
                    dc.fillRectangle(x + start * SCALE, y + row * SCALE, (col - start) * SCALE, SCALE);
                } else {
                    col++;
                }
            }
        }
    }

    // the rod: 2px pole from the fist up to the tip, 1px line hanging down, black-and-white bobber at its end
    function drawRod(dc as Dc, x as Number, y as Number) as Void {
        var tipX = x + ROD_TIP_X;
        var tipY = y + ROD_TIP_Y;
        var bobberY = tipY + LINE_DROP;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawLine(x + ROD_GRIP_X, y + ROD_GRIP_Y, tipX, tipY);
        dc.setPenWidth(1);
        dc.drawLine(tipX, tipY, tipX, bobberY);

        dc.fillCircle(tipX, bobberY, BOBBER_R);                              // bobber: black ...
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(tipX - BOBBER_R + 1, bobberY - BOBBER_R + 1, 2 * BOBBER_R - 1, 2);  // ... with a white top
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(tipX, bobberY, BOBBER_R);
    }
}
