import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;

// Thin battery level bar on the left edge (kept away from the corners).
// When the battery is low the whole bar blinks (once per second) while the watch is awake;
// in low-power mode the face only redraws once a minute, so it stays steady there.
module BatteryBar {

    const X = 1;
    const TRACK_W = 2;    // thin track (full height)
    const LEVEL_W = 3;    // level bar (fills from the bottom)
    const TOP = 40;
    const BOTTOM = 136;
    const LOW_PERCENT = 20;   // at or below this the bar blinks

    function draw(dc as Dc, asleep as Boolean) as Void {
        var percent = System.getSystemStats().battery;
        if (percent <= LOW_PERCENT && !asleep && System.getClockTime().sec % 2 == 1) {
            return;   // blink: the bar is hidden on odd seconds
        }
        var length = BOTTOM - TOP;
        var levelLength = ((percent / 100.0) * length).toNumber();
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(X, TOP, TRACK_W, length);
        dc.fillRectangle(X, BOTTOM - levelLength, LEVEL_W, levelLength);
    }
}
