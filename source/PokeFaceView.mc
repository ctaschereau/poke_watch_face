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
    // ---- layout knobs (176x176 screen) ----
    hidden const HR_CX = 159;       // centre x of the heart-rate column (right of the time)
    hidden const HR_Y = 97;         // centre y of the heart-rate column
    hidden const HR_MAX_W = 30;     // number switches to the smaller font above this width
    hidden const BAR_Y = 138;       // centre y of the steps bar
    hidden const BAR_H = 12;        // steps bar height
    hidden const BAR_LABEL_X = 6;   // the bar starts where the old "STEPS:" label ended (keeps its size)
    hidden const BAR_RIGHT = 168;   // right end of the steps bar (and of the numbers below it)
    hidden const STEPS_TEXT_Y = 158;// centre y of the "steps/ goal" numbers
    hidden const STEPS_TEXT_RIGHT = 148;  // right edge of the numbers (bar's right end - 20)
    hidden const STEPS_TEXT_MIN_X = 8;    // numbers must start right of this, else the small font is used
    hidden const STEPS_DIVISOR = 100;      // shown steps and goal are divided by this
    hidden const DEFAULT_GOAL = 10000;
    // battery bar on the left edge (kept away from the corners)
    hidden const BATT_X = 1;
    hidden const BATT_W = 2;
    hidden const BATT_TOP = 40;
    hidden const BATT_BOTTOM = 136;
    hidden const TIME_CX = 74;      // centre x of the time (88 = screen centre; lower = further left)
    hidden const TIME_Y = 96;       // centre y of the time digits
    hidden const TIME_MAX_W = 170;  // fallback built-in font must fit this width
    hidden const TIME_MAX_H = 84;   // ...and this height
    hidden var _timeFont = null;    // Pokemon (Gen 1) pixel font, 4x  (resources/fonts)
    hidden var _stepFont = null;    // same font, 2x
    hidden var _stepFontSmall = null; // same font, 1x - used when the numbers get too wide

    function initialize() {
        WatchFace.initialize();
        _anim = new PokeAnimation();
    }

    function onLayout(dc) {
        _timeFont = WatchUi.loadResource(Rez.Fonts.TimeFont);
        _stepFont = WatchUi.loadResource(Rez.Fonts.StepFont);
        _stepFontSmall = WatchUi.loadResource(Rez.Fonts.StepFontSmall);
    }

    function onEnterSleep() {
        _anim.setAsleep(true);
    }

    function onExitSleep() {
        _anim.setAsleep(false);
    }

    function onUpdate(dc) {
        _anim.advance();

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        dc.clear();

        var box = subscreenBox();
        drawDate(dc, box);
        drawTime(dc, box);
        drawRows(dc);
        _anim.draw(dc, box);
    }

    // ---------- date + weather, centred between left edge and the subscreen ----------
    hidden function drawDate(dc, box) {
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
    hidden function drawTime(dc, box) {
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
    }

    // biggest digit font that still fits
    hidden function pickTimeFont(dc, text) {
        var fonts = [];
        if (Graphics has :FONT_NUMBER_THAI_HOT) {
            fonts.add(Graphics.FONT_NUMBER_THAI_HOT);
        }
        fonts.add(Graphics.FONT_NUMBER_HOT);
        fonts.add(Graphics.FONT_NUMBER_MEDIUM);
        for (var i = 0; i < fonts.size(); i++) {
            var f = fonts[i];
            if (dc.getTextWidthInPixels(text, f) <= TIME_MAX_W && dc.getFontHeight(f) <= TIME_MAX_H) {
                return f;
            }
        }
        return Graphics.FONT_NUMBER_MEDIUM;
    }

    // ---------- heart rate (right of the time) + steps bar (bottom) ----------
    hidden function drawRows(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        drawHeart(dc, HR_CX, HR_Y);
        drawSteps(dc);
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
        var kind = 2;
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
                kind = weatherKind(cc.condition);
            }
        }
        var font = Graphics.FONT_SMALL;
        var x0 = startX(dc, cx, text, font, 18);
        drawWeatherIcon(dc, x0 + 9, y, kind);
        drawLabel(dc, x0 + 22, y, text, font);
    }

    // 0 sun, 1 partly, 2 cloud, 3 rain, 4 snow, 5 storm, 6 fog/wind
    hidden function weatherKind(c) {
        if (c == null) { return 2; }
        if ([0, 23, 40].indexOf(c) >= 0) { return 0; }
        if ([1, 22, 52].indexOf(c) >= 0) { return 1; }
        if ([3, 11, 13, 14, 15, 24, 25, 26, 27, 31, 45, 49].indexOf(c) >= 0) { return 3; }
        if ([4, 7, 10, 16, 17, 18, 19, 21, 34, 43, 44, 46, 47, 48, 50, 51].indexOf(c) >= 0) { return 4; }
        if ([6, 12, 28, 32, 36, 41, 42].indexOf(c) >= 0) { return 5; }
        if ([5, 8, 9, 29, 30, 33, 35, 37, 38, 39].indexOf(c) >= 0) { return 6; }
        return 2;
    }

    hidden function drawCloud(dc, x, y) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x - 4, y + 1, 4);
        dc.fillCircle(x + 1, y - 2, 5);
        dc.fillCircle(x + 5, y + 2, 4);
        dc.fillRectangle(x - 6, y + 2, 13, 4);
    }

    hidden function drawWeatherIcon(dc, x, y, kind) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        if (kind == 0 || kind == 1) {
            var sx = (kind == 0) ? x : x - 4;
            var sy = (kind == 0) ? y : y - 4;
            var r = (kind == 0) ? 4 : 3;
            dc.fillCircle(sx, sy, r);
            var rays = [[0, -1], [1, -1], [1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1]];
            for (var i = 0; i < rays.size(); i++) {
                var dx = rays[i][0];
                var dy = rays[i][1];
                dc.drawLine(sx + dx * (r + 2), sy + dy * (r + 2), sx + dx * (r + 4), sy + dy * (r + 4));
            }
            if (kind == 1) { drawCloud(dc, x + 2, y + 3); }
        } else if (kind == 2) {
            drawCloud(dc, x, y + 1);
        } else if (kind == 3) {
            drawCloud(dc, x, y - 3);
            dc.drawLine(x - 4, y + 4, x - 5, y + 8);
            dc.drawLine(x, y + 4, x - 1, y + 8);
            dc.drawLine(x + 4, y + 4, x + 3, y + 8);
        } else if (kind == 4) {
            drawCloud(dc, x, y - 3);
            dc.fillCircle(x - 4, y + 6, 1);
            dc.fillCircle(x, y + 8, 1);
            dc.fillCircle(x + 4, y + 6, 1);
        } else if (kind == 5) {
            drawCloud(dc, x, y - 3);
            dc.drawLine(x + 1, y + 3, x - 2, y + 6);
            dc.drawLine(x - 2, y + 6, x + 2, y + 6);
            dc.drawLine(x + 2, y + 6, x - 1, y + 10);
        } else {
            dc.drawLine(x - 7, y - 4, x + 7, y - 4);
            dc.drawLine(x - 7, y, x + 7, y);
            dc.drawLine(x - 7, y + 4, x + 7, y + 4);
        }
        dc.setPenWidth(1);
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

    // heart icon stacked above the number, centred on cx
    hidden function drawHeart(dc, cx, y) {
        var hr = currentHeartRate();
        var text = (hr != null) ? hr.format("%d") : "--";
        var font = Graphics.FONT_TINY;
        if (dc.getTextWidthInPixels(text, font) > HR_MAX_W) {
            font = Graphics.FONT_XTINY;
        }
        var x0 = cx - 7;
        var iy = y - 12;
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x0 + 4, iy - 2, 4);
        dc.fillCircle(x0 + 10, iy - 2, 4);
        dc.fillPolygon([[x0, iy], [x0 + 14, iy], [x0 + 7, iy + 8]]);
        dc.drawText(cx, y + 9, font, text,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // --- steps: [foot] [=====----]  with "steps/ goal" underneath (like a Pokemon HP bar) ---
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

        // foot icon where the word used to be (right next to the bar)
        drawFoot(dc, barX - 11, BAR_Y);

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

    // footprint icon, about 10 x 18 px, centred on cx,cy
    hidden function drawFoot(dc, cx, cy) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillEllipse(cx, cy - 1, 4, 6);          // ball of the foot
        dc.fillEllipse(cx + 1, cy + 6, 3, 3);      // heel
        dc.fillCircle(cx - 2, cy - 9, 2);          // big toe
        dc.fillCircle(cx + 2, cy - 9, 1);          // other toes
        dc.fillCircle(cx + 4, cy - 7, 1);
        dc.fillCircle(cx + 5, cy - 4, 1);
    }

    // --- battery: thin level bar on the left edge ---
    hidden function drawBatteryBar(dc) {
        var pct = System.getSystemStats().battery;
        var len = BATT_BOTTOM - BATT_TOP;
        var fillLen = ((pct / 100.0) * len).toNumber();
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(BATT_X, BATT_TOP, 1, len);                           // 1px track
        dc.fillRectangle(BATT_X, BATT_BOTTOM - fillLen, BATT_W, fillLen);     // 2px level
    }

    // ---------- the subscreen area (where the Poke Ball lives) ----------
    hidden function subscreenBox() {
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
