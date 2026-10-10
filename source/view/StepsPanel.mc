import Toybox.Activity;
import Toybox.ActivityMonitor;
import Toybox.Graphics;
import Toybox.Lang;

// Bottom block, like a Pokemon HP box:
//   [HR heart] [=====-----]     steps bar with the heart rate (icon + number) to its left
//                 75/ 100       steps / goal underneath, in hundreds of steps
// inside a player-style battle frame.
class StepsPanel {

    // Everything is on the 2 px pixel grid and inside the Instinct's round bezel opening: the right vertical line
    // of the frame is kept well left of the display corner, which is hidden behind the bezel.
    // ---- steps bar ----
    hidden const BAR_CENTER_Y = 132;   // centre y of the bar (and of the heart rate)
    hidden const BAR_H = 14;           // = the height of the 2x pixel digits + 2
    hidden const BAR_RIGHT = 140;      // right end of the bar
    hidden const BAR_X = 80;           // left end of the bar (room for a 3-digit heart rate in the big font)
    hidden const BAR_PEN = 2;          // outline thickness
    hidden const BAR_INSET = 4;        // outline + 2 px gap, then the fill (so the fill is 6 px tall)
    // ---- "steps/goal" numbers under the bar ----
    hidden const NUMBERS_Y = 150;      // vertical centre of the 2x font cell (digits are 12 px tall, at the top)
    hidden const NUMBERS_RIGHT = 140;  // right edge (the bar's right end)
    hidden const NUMBERS_MIN_X = 24;   // the numbers must start right of this, else the small font is used
    hidden const STEPS_DIVISOR = 100;  // shown steps and goal are divided by this (the bar still shows the real progress)
    hidden const DEFAULT_GOAL = 10000; // if the watch reports no step goal
    // ---- heart rate (icon + number), left of the bar ----
    hidden const HEART_W = 14;         // width of resources/drawables/heart.png
    hidden const HEART_H = 12;         // height of resources/drawables/heart.png
    hidden const HEART_BAR_GAP = 4;    // gap between the heart icon and the bar
    hidden const HR_GAP = 3;           // gap between the number and the heart icon
    // ---- frame: line under the steps, half-arrow on the left, vertical line on the right ----
    hidden const FRAME_LEFT = 34;      // left end of the bottom line (arrow included)
    hidden const FRAME_RIGHT = 148;    // right end (exclusive) of the bottom line
    hidden const FRAME_TOP = 123;      // top of the vertical line (2 px above the bar)
    hidden const FRAME_LINE_Y = 160;   // top of the bottom line (2 px: 160-161)

    hidden var _assets as Assets;

    function initialize(assets as Assets) {
        _assets = assets;
    }

    function draw(dc as Dc) as Void {
        var info = ActivityMonitor.getInfo();
        var steps = info.steps;
        var rawGoal = info.stepGoal;
        var goal = DEFAULT_GOAL;
        if (rawGoal != null && rawGoal > 0) {
            goal = rawGoal;
        }

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        drawHeartRate(dc);
        drawBar(dc, progress(steps, goal));
        drawNumbers(dc, steps, goal);
        BattleFrame.drawEdge(dc, FRAME_LEFT, FRAME_RIGHT, FRAME_TOP, FRAME_LINE_Y, true);
    }

    // ---------- steps ----------
    hidden function progress(steps as Number or Null, goal as Number) as Float {
        if (steps == null) {
            return 0.0;
        }
        var frac = steps.toFloat() / goal.toFloat();
        return (frac > 1.0) ? 1.0 : frac;
    }

    // squared outline (corners notched by one 2 px step, like the Gen 1 HP bar ends) with the fill inset inside it
    hidden function drawBar(dc as Dc, frac as Float) as Void {
        var barW = BAR_RIGHT - BAR_X;
        var barTop = BAR_CENTER_Y - BAR_H / 2;
        var pen = BAR_PEN;

        dc.fillRectangle(BAR_X + pen, barTop, barW - 2 * pen, pen);                 // top
        dc.fillRectangle(BAR_X + pen, barTop + BAR_H - pen, barW - 2 * pen, pen);   // bottom
        dc.fillRectangle(BAR_X, barTop + pen, pen, BAR_H - 2 * pen);                // left
        dc.fillRectangle(BAR_X + barW - pen, barTop + pen, pen, BAR_H - 2 * pen);   // right

        var innerW = barW - 2 * BAR_INSET;
        var fillW = (innerW * frac).toNumber();
        if (fillW > 0) {
            dc.fillRectangle(BAR_X + BAR_INSET, barTop + BAR_INSET, fillW, BAR_H - 2 * BAR_INSET);
        }
    }

    // "75/100" under the bar, right-aligned (the slash glyph carries the space after it)
    hidden function drawNumbers(dc as Dc, steps as Number or Null, goal as Number) as Void {
        var shown = (steps != null) ? (steps / STEPS_DIVISOR).format("%d") : "--";
        var text = shown + "/" + (goal / STEPS_DIVISOR).format("%d");
        var font = _assets.fitStepFont(dc, text, NUMBERS_RIGHT - NUMBERS_MIN_X);
        dc.drawText(NUMBERS_RIGHT, NUMBERS_Y, font, text,
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // ---------- heart rate ----------
    hidden function currentHeartRate() as Number or Null {
        var info = Activity.getActivityInfo();
        if (info != null && info.currentHeartRate != null) {
            return info.currentHeartRate;
        }
        if (ActivityMonitor has :getHeartRateHistory) {
            var iter = ActivityMonitor.getHeartRateHistory(1, true);
            var sample = iter.next();
            if (sample != null && sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
                return sample.heartRate;
            }
        }
        return null;
    }

    // number + heart icon, vertically centred on the bar. The number is right-aligned against the icon, always in
    // the big font: BAR_X leaves room for 3 digits (3 x 16 px) between the battery bar and the icon.
    hidden function drawHeartRate(dc as Dc) as Void {
        var hr = currentHeartRate();
        var text = (hr != null) ? hr.format("%d") : "--";
        var iconLeft = BAR_X - HEART_W - HEART_BAR_GAP;
        var textRight = iconLeft - HR_GAP;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(textRight, BAR_CENTER_Y + 1, _assets.stepFont, text,
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawBitmap(iconLeft, BAR_CENTER_Y - HEART_H / 2, _assets.heartIcon);
    }
}
