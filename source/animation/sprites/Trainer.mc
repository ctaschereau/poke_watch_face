import Toybox.Graphics;
import Toybox.Lang;

// The Pokemon trainer, 16x16 monochrome. Each sprite is 16 row masks; bit 15 = leftmost pixel,
// a set bit = black pixel (white / transparent pixels are simply not drawn, the face background is white).
// Walking while the watch is awake (the two walk frames alternate each second),
// fishing while it sleeps.
module Trainer {

    const SIZE = 16;

    // walk frame 1
    const WALK_A = [
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
    const WALK_B = [
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
    const FISH = [
        0x07E0,
        0x0D50,
        0x1AA8,
        0x3558,
        0x42BC,
        0x35FC,
        0x14FC,
        0x1498,
        0xD010,
        0xFC60,
        0x3FB0,
        0x2570,
        0x27F0,
        0x1F70,
        0x06A0,
        0x03C0
    ];

    // x,y = top-left corner. asleep -> fishing sprite; otherwise walk frame chosen by `tick` (even/odd).
    function draw(dc, x, y, asleep, tick) {
        var sprite = FISH;
        if (!asleep) {
            sprite = (tick % 2 == 0) ? WALK_A : WALK_B;
        }
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        for (var row = 0; row < SIZE; row++) {
            var bits = sprite[row];
            var col = 0;
            while (col < SIZE) {
                if ((bits & (0x8000 >> col)) != 0) {
                    var start = col;                       // horizontal run of black pixels -> one rectangle
                    while (col < SIZE && (bits & (0x8000 >> col)) != 0) {
                        col++;
                    }
                    dc.fillRectangle(x + start, y + row, col - start, 1);
                } else {
                    col++;
                }
            }
        }
    }
}
