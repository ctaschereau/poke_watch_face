import Toybox.Activity;
import Toybox.ActivityMonitor;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Weather;
import Toybox.WatchUi;

class PokeFaceView extends WatchUi.WatchFace {

    hidden var _anim = null;        // ball + Pokemon animation (Animation.mc)
    hidden var _asleep = false;     // true in low-power mode (trainer fishes instead of walking)
    // ---- layout knobs (176x176 screen) ----
    hidden const HR_LEFT = 6;       // heart-rate icon starts here (left of the steps bar)
    hidden const HEART_W = 14;      // width of resources/drawables/heart.png
    hidden const HR_GAP = 3;        // gap between heart icon / number / the bar
    hidden const BAR_Y = 138;       // centre y of the steps bar
    hidden const BAR_H = 12;        // steps bar height
    hidden const BAR_LABEL_X = 6;   // the bar starts where the old "STEPS:" label ended (keeps its size)
    hidden const BAR_RIGHT = 162;   // right end of the steps bar (and of the numbers below it)
    hidden const STEPS_TEXT_Y = 156;// centre y of the "steps/ goal" numbers
    hidden const STEPS_TEXT_RIGHT = 142;  // right edge of the numbers (bar's right end - 20)
    hidden const STEPS_TEXT_MIN_X = 8;    // numbers must start right of this, else the small font is used
    hidden const STEPS_DIVISOR = 100;      // shown steps and goal are divided by this
    hidden const DEFAULT_GOAL = 10000;
    // battery bar on the left edge (kept away from the corners)
    hidden const BATT_X = 1;
    hidden const BATT_TRACK_W = 2;  // thin track
    hidden const BATT_W = 3;        // level bar
    hidden const BATT_TOP = 40;
    hidden const BATT_BOTTOM = 136;
    hidden const TIME_CX = 74;      // centre x of the time (88 = screen centre; lower = further left)
    hidden const TIME_Y = 96;       // centre y of the time digits
    hidden const TIME_MAX_W = 170;  // fallback built-in font must fit this width
    hidden const TIME_MAX_H = 84;   // ...and this height
    hidden const TRAINER_GAP = 4;   // gap between the time and the trainer sprite (16x16)
    hidden const TRAINER_SIZE = 16;
    hidden const SCREEN_W = 176;
    // ---- battle-scene frames (Gen 1 HP-box style lines) ----
    hidden const FRAME_T = 3;       // line thickness
    hidden const FRAME_BARB_H = 4;  // height of the half-arrow above the line
    hidden const FRAME_BARB_W = 13; // width of the half-arrow at its base
    hidden const STEPS_FRAME_Y = 168;   // top of the bottom line under the steps (3px: 168-170)
    hidden const STEPS_FRAME_TOP = 129; // top of the vertical line on the right of the steps
    hidden const STEPS_FRAME_RIGHT = 170; // right edge (exclusive) of that vertical line
    hidden const STEPS_FRAME_LEFT = 45;   // left end of the bottom line (barb included)
    hidden const DATE_FRAME_X = 8;      // left edge of the vertical line next to the date
    hidden const DATE_FRAME_TOP = 12;   // top of that vertical line
    hidden const DATE_FRAME_Y = 62;     // top of the bottom line under the date/weather
    hidden var _heartIcon = null;   // heart.png
    hidden var _timeFont = null;    // Pokemon (Gen 1) pixel font, 4x  (resources/fonts)
    hidden var _stepFont = null;    // same font, 2x
    hidden var _stepFontSmall = null; // same font, 1x - used when the numbers get too wide

    function initialize() {
        WatchFace.initialize();
        _anim = new PokeAnimation();
    }

    function onLayout(dc) {
        _heartIcon = WatchUi.loadResource(Rez.Drawables.HeartIcon);
        _timeFont = WatchUi.loadResource(Rez.Fonts.TimeFont);
        _stepFont = WatchUi.loadResource(Rez.Fonts.StepFont);
        _stepFontSmall = WatchUi.loadResource(Rez.Fonts.StepFontSmall);
    }

    function onEnterSleep() {
        _asleep = true;
        _anim.setAsleep(true);
    }

    function onExitSleep() {
        _asleep = false;
        _anim.setAsleep(false);
    }

    function onUpdate(dc) {
        _anim.advance();

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        dc.clear();

        var box = subscreenBox();
        drawDate(dc, box);
        drawDateFrame(dc, box);
        drawTime(dc, box);
        drawRows(dc);
        _anim.draw(dc, box);
    }

    // ---------- date + weather, centred between left edge and the subscreen ----------
    hidden function drawDate(dc as Dc, box as Array<Number>) as Void {
        var d = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var cx = box[0] / 2;
        var cy = box[1] + box[3] / 2;
        var str = d.day_of_week + " " + d.month + " " + d.day;
        var font = Graphics.FONT_TINY;
        if (dc.getTextWidthInPixels(str, font) > box[0] - 8) {
            font = Graphics.FONT_XTINY;
        }
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 12, font, str,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        drawWeather(dc, cx, cy + 12);
    }

    // ---------- big time ----------
    hidden function drawTime(dc as Dc, box as Array<Number>) as Void {
        var clock = System.getClockTime();
        var hour = clock.hour;
        if (!System.getDeviceSettings().is24Hour) {
            hour = hour % 12;
            if (hour == 0) { hour = 12; }
        }
        var timeStr = hour.format("%d") + ":" + clock.min.format("%02d");
        var font = (_timeFont != null) ? _timeFont : pickTimeFont(dc, timeStr);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(TIME_CX, TIME_Y, font, timeStr,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        drawTrainer(dc, timeStr, font, clock.sec);
    }

    // trainer to the right of the time: walks (alternating frames, one per second) while awake, fishes asleep
    hidden function drawTrainer(dc, timeStr, font, sec) {
        var timeRight = TIME_CX + dc.getTextWidthInPixels(timeStr, font) / 2;
        var x = timeRight + TRAINER_GAP;
        if (x > SCREEN_W - TRAINER_SIZE - 2) {
            x = SCREEN_W - TRAINER_SIZE - 2;
        }
        Trainer.draw(dc, x, TIME_Y - TRAINER_SIZE / 2, _asleep, sec);
    }

    // biggest built-in digit font that still fits (fallback only, the Pokemon font is used normally)
    hidden function pickTimeFont(dc as Dc, text as String) as Graphics.FontType {
        if (Graphics has :FONT_NUMBER_THAI_HOT && fits(dc, text, Graphics.FONT_NUMBER_THAI_HOT)) {
            return Graphics.FONT_NUMBER_THAI_HOT;
        }
        if (fits(dc, text, Graphics.FONT_NUMBER_HOT)) {
            return Graphics.FONT_NUMBER_HOT;
        }
        return Graphics.FONT_NUMBER_MEDIUM;
    }

    hidden function fits(dc as Dc, text as String, font as Graphics.FontType) as Boolean {
        return dc.getTextWidthInPixels(text, font) <= TIME_MAX_W && dc.getFontHeight(font) <= TIME_MAX_H;
    }

    // ---------- steps bar (bottom) with the heart rate to its left ----------
    hidden function drawRows(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        drawSteps(dc);
        drawStepsFrame(dc);
        drawBatteryBar(dc);
    }

    // x of the left edge so that [icon + gap + text] is centred on cx
    hidden function startX(dc, cx, text, font, iconW) {
        var tw = dc.getTextWidthInPixels(text, font);
        return cx - (iconW + 4 + tw) / 2;
    }

    hidden function drawLabel(dc, x, y, text, font) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, text, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // --- weather ---
    hidden function drawWeather(dc, cx, y) {
        var text = "--";
        var kind = WxIcon.CLOUD;
        if (Toybox has :Weather) {
            var cc = Weather.getCurrentConditions();
            if (cc != null) {
                if (cc.temperature != null) {
                    var t = cc.temperature;
                    if (System.getDeviceSettings().temperatureUnits == System.UNIT_STATUTE) {
                        t = t * 9.0 / 5.0 + 32.0;
                    }
                    text = t.toNumber().format("%d") + "°";
                }
                kind = WxIcon.kindFor(cc.condition);
            }
        }
        var font = Graphics.FONT_SMALL;
        var x0 = startX(dc, cx, text, font, 18);
        WxIcon.draw(dc, x0 + 9, y, kind);
        drawLabel(dc, x0 + 22, y, text, font);
    }

    // --- heart rate ---
    hidden function currentHeartRate() {
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

    // heart icon + number, to the left of the steps bar, vertically centred on the bar.
    // barX is the left edge of the bar; everything must fit between HR_LEFT and barX.
    hidden function drawHeart(dc, barX) {
        var hr = currentHeartRate();
        var text = (hr != null) ? hr.format("%d") : "--";
        var heartIconLeft = barX - HEART_W - 6;
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        
        // TODO : this does not fit for 3 digit HR...
        var textLeft = HR_LEFT;
        dc.drawText(textLeft, BAR_Y, _stepFont, text, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        if (_heartIcon != null) {
            dc.drawBitmap(heartIconLeft, BAR_Y - 6, _heartIcon);   // 14 x 12 px, centred on the bar
        }
    }

    // --- steps: [heart HR] [=====----]  with "steps/ goal" underneath (like a Pokemon HP bar) ---
    hidden function drawSteps(dc) {
        var info = ActivityMonitor.getInfo();
        var steps = info.steps;
        var goal = info.stepGoal;
        if (goal == null || goal <= 0) {
            goal = DEFAULT_GOAL;
        }
        var frac = 0.0;
        if (steps != null) {
            frac = steps.toFloat() / goal.toFloat();
            if (frac > 1.0) { frac = 1.0; }
        }

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);

        // the bar keeps exactly the position/size it had when the "STEPS:" word sat before it
        var barX = BAR_LABEL_X + dc.getTextWidthInPixels("STEPS:", Graphics.FONT_XTINY) + 4;
        var barW = BAR_RIGHT - barX;
        var barTop = BAR_Y - BAR_H / 2;

        // heart rate where the foot icon used to be (left of the bar)
        drawHeart(dc, barX);

        // rounded outline
        dc.setPenWidth(2);
        dc.drawRoundedRectangle(barX, barTop, barW, BAR_H, BAR_H / 2);
        dc.setPenWidth(1);

        // fill (inset so a white gap shows inside the outline)
        var inner = barW - 6;
        var fillW = (inner * frac).toNumber();
        if (fillW > 0) {
            var fillH = BAR_H - 6;
            var r = fillH / 2;
            if (fillW < 2 * r) {
                r = fillW / 2;
            }
            dc.fillRoundedRectangle(barX + 3, barTop + 3, fillW, fillH, r);
        }

        // numbers under the bar, scaled down: "754/ 1000" (the slash glyph carries the space after it)
        var shown = (steps != null) ? (steps / STEPS_DIVISOR).format("%d") : "--";
        var text = shown + "/" + (goal / STEPS_DIVISOR).format("%d");
        var font = (_stepFont != null) ? _stepFont : Graphics.FONT_TINY;
        if (_stepFontSmall != null &&
            STEPS_TEXT_RIGHT - dc.getTextWidthInPixels(text, font) < STEPS_TEXT_MIN_X) {
            font = _stepFontSmall;
        }
        dc.drawText(STEPS_TEXT_RIGHT, STEPS_TEXT_Y, font, text,
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // --- battery: thin level bar on the left edge ---
    hidden function drawBatteryBar(dc) {
        var pct = System.getSystemStats().battery;
        var len = BATT_BOTTOM - BATT_TOP;
        var fillLen = ((pct / 100.0) * len).toNumber();
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(BATT_X, BATT_TOP, BATT_TRACK_W, len);                // track
        dc.fillRectangle(BATT_X, BATT_BOTTOM - fillLen, BATT_W, fillLen);     // level
    }

    // ---------- battle-scene frames ----------
    // half-arrow (right triangle, flat side towards the vertical line) built from 1px-high rows.
    // facingLeft: barb sits at the left end of the line (player box); else at the right end (foe box).
    // lx/rx = left/right end (exclusive) of the horizontal line, ly = top of the line.
    hidden function drawFrameLine(dc, lx, rx, ly, facingLeft) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(lx, ly, rx - lx, FRAME_T);
        for (var i = 0; i < FRAME_BARB_H; i++) {
            var w = 3 + 2 * i;                       // rows widen towards the line
            var y = ly - FRAME_BARB_H + i;
            if (facingLeft) {
                // flat edge at lx + FRAME_BARB_W, point towards the left
                dc.fillRectangle(lx + FRAME_BARB_W - w, y, w, 1);
            } else {
                dc.fillRectangle(rx - FRAME_BARB_W, y, w, 1);
            }
        }
    }

    // player-style box under the steps: line along the bottom, barb on the left, vertical line on the right
    hidden function drawStepsFrame(dc) {
        drawFrameLine(dc, STEPS_FRAME_LEFT, STEPS_FRAME_RIGHT, STEPS_FRAME_Y, true);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(STEPS_FRAME_RIGHT - FRAME_T, STEPS_FRAME_TOP,
            FRAME_T, STEPS_FRAME_Y + FRAME_T - STEPS_FRAME_TOP);
    }

    // foe-style box under the date/weather: vertical line on the left, line along the bottom, barb on the right
    hidden function drawDateFrame(dc as Dc, box as Array<Number>) as Void {
        var rx = box[0] - 12;                         // stop just left of the subscreen
        drawFrameLine(dc, DATE_FRAME_X, rx, DATE_FRAME_Y, false);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(DATE_FRAME_X, DATE_FRAME_TOP, FRAME_T,
            DATE_FRAME_Y + FRAME_T - DATE_FRAME_TOP);
    }

    // ---------- the subscreen area (where the Poke Ball lives) ----------
    hidden function subscreenBox() as Array<Number> {
        var x = 112;
        var y = 6;
        var w = 58;
        var h = 58;
        if (WatchUi has :getSubscreen) {
            var s = WatchUi.getSubscreen();
            if (s != null) {
                x = s.x;
                y = s.y;
                w = s.width;
                h = s.height;
            }
        }
        return [x, y, w, h];
    }
}
