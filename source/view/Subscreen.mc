import Toybox.Lang;
import Toybox.WatchUi;

// The round subscreen of the Instinct (where the Poke Ball lives).
module Subscreen {

    // used if the device does not report its subscreen
    const DEFAULT_X = 112;
    const DEFAULT_Y = 6;
    const DEFAULT_W = 58;
    const DEFAULT_H = 58;

    // [x, y, width, height]
    function bounds() as Array<Number> {
        if (WatchUi has :getSubscreen) {
            var s = WatchUi.getSubscreen();
            if (s != null) {
                return [s.x, s.y, s.width, s.height];
            }
        }
        return [DEFAULT_X, DEFAULT_Y, DEFAULT_W, DEFAULT_H];
    }
}
