import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;

// Thin battery level bar on the left edge (kept inside the round bezel opening: the display corners are hidden).
module BatteryBar {

    const X = 2;
    const TRACK_W = 2;    // thin track (full height)
    const LEVEL_W = 3;    // level bar (fills from the bottom)
    const TOP = 44;
    const BOTTOM = 132;

    function draw(dc as Dc) as Void {
        var percent = System.getSystemStats().battery;
        var length = BOTTOM - TOP;
        var levelLength = ((percent / 100.0) * length).toNumber();
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(X, TOP, TRACK_W, length);
        dc.fillRectangle(X, BOTTOM - levelLength, LEVEL_W, levelLength);
    }
}
