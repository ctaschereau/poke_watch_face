import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;

// The big clock in the middle of the screen, with the trainer sprite to its right.
class TimePanel {

    // ---- layout knobs (176x176 screen) ----
    hidden const CENTER_X = 74;     // centre x of the time (88 = screen centre; lower = further left)
    hidden const CENTER_Y = 94;     // centre y of the time digits
    hidden const DIGIT_HALF_H = 12; // the 4x digits are 24 px tall, so their bottom edge is CENTER_Y + this
    hidden const TRAINER_GAP = 4;   // gap between the time and the trainer sprite
    hidden const EDGE_MARGIN = 2;   // the trainer's last drawn pixel never gets closer than this to the right edge

    hidden var _assets as Assets;
    hidden var _asleep as Boolean = false;   // low-power mode: the trainer fishes instead of walking

    function initialize(assets as Assets) {
        _assets = assets;
    }

    function setAsleep(asleep as Boolean) as Void {
        _asleep = asleep;
    }

    function draw(dc as Dc) as Void {
        var clock = System.getClockTime();
        var text = formatTime(clock);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(CENTER_X, CENTER_Y, _assets.timeFont, text,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        drawTrainer(dc, text, clock.sec);
    }

    hidden function formatTime(clock as System.ClockTime) as String {
        var hour = clock.hour;
        if (!System.getDeviceSettings().is24Hour) {
            hour = hour % 12;
            if (hour == 0) { hour = 12; }
        }
        return hour.format("%d") + ":" + clock.min.format("%02d");
    }

    // trainer to the right of the time: walks (the two frames alternate each second) while awake, fishes asleep
    hidden function drawTrainer(dc as Dc, text as String, sec as Number) as Void {
        var timeRight = CENTER_X + dc.getTextWidthInPixels(text, _assets.timeFont) / 2;
        var x = timeRight + TRAINER_GAP;
        // the 32x32 box may overlap the screen edge by its empty right columns
        var maxX = dc.getWidth() - Trainer.SIZE + Trainer.RIGHT_BLANK - EDGE_MARGIN;
        if (x > maxX) {
            x = maxX;
        }
        // the trainer's feet stand on the same baseline as the digits (every sprite frame ends on its last row)
        Trainer.draw(dc, x, CENTER_Y + DIGIT_HALF_H - Trainer.SIZE, _asleep, sec);
    }
}
