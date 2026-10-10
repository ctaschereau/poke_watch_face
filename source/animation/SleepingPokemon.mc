import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

// Night mode: between NIGHT_START and NIGHT_END the Poke Ball in the subscreen is replaced by a sleeping Snorlax
// (resources/drawables/snorlax_sleep.png, 40x30) with "Z z Z" floating above its head, and the ball never opens.
// While the watch is awake the Zs appear one by one (1, 2, 3, 1, ... each second); in low-power mode all three show.
// The subscreen is a circle, so the sprite and the Zs are placed relative to its centre and kept inside it.
class SleepingPokemon {

    // night = NIGHT_START:00 until NIGHT_END:00 (24h clock; works across midnight)
    hidden const NIGHT_START = 22;
    hidden const NIGHT_END = 6;

    hidden const SPRITE_DY = 9;     // sprite centre is this far below the subscreen centre

    // the three Zs, bottom-left to top-right: size (px) and top-left corner relative to the subscreen centre
    hidden const Z_SIZE as Array<Number> = [4, 5, 6];
    hidden const Z_DX as Array<Number> = [2, 5, 8];
    hidden const Z_DY as Array<Number> = [-9, -16, -24];

    hidden var _bitmap as WatchUi.BitmapResource? = null;

    function isNight() as Boolean {
        var hour = System.getClockTime().hour;
        if (NIGHT_START > NIGHT_END) {
            return hour >= NIGHT_START || hour < NIGHT_END;
        }
        return hour >= NIGHT_START && hour < NIGHT_END;
    }

    // box = subscreen [x, y, w, h]; lowPower = the watch is in low-power mode (no per-second animation)
    function draw(dc as Dc, box as Array<Number>, lowPower as Boolean) as Void {
        var cx = box[0] + box[2] / 2;
        var cy = box[1] + box[3] / 2;

        if (_bitmap == null) {
            _bitmap = WatchUi.loadResource(Rez.Drawables.SnorlaxSleep) as WatchUi.BitmapResource;
        }
        var bmp = _bitmap;
        if (bmp != null) {
            dc.drawBitmap(cx - bmp.getWidth() / 2, cy - bmp.getHeight() / 2 + SPRITE_DY, bmp);
        }

        var shown = 3;
        if (!lowPower) {
            shown = 1 + System.getClockTime().sec % 3;
        }
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        for (var i = 0; i < shown; i++) {
            drawZ(dc, cx + Z_DX[i], cy + Z_DY[i], Z_SIZE[i]);
        }
    }

    // call when it is day again
    function release() as Void {
        _bitmap = null;
    }

    // a "Z" with its top-left corner at (x, y)
    hidden function drawZ(dc as Dc, x as Number, y as Number, size as Number) as Void {
        dc.drawLine(x, y, x + size, y);
        dc.drawLine(x + size, y, x, y + size);
        dc.drawLine(x, y + size, x + size, y + size);
    }
}
